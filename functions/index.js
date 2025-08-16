const {onSchedule} = require('firebase-functions/v2/scheduler');
const {onCall} = require('firebase-functions/v2/https');
const {onDocumentUpdated} = require('firebase-functions/v2/firestore');
const {initializeApp} = require('firebase-admin/app');
const {getFirestore, Timestamp, FieldValue} = require('firebase-admin/firestore');
const {getStorage} = require('firebase-admin/storage');

// Initialize Firebase Admin
initializeApp();

const db = getFirestore();
const bucket = getStorage().bucket();

// Cloud Function that runs daily to check and delete old images
exports.deleteOldImages = onSchedule({
  schedule: '0 2 * * *', // Runs daily at 2 AM UTC
  timeZone: 'UTC',
  region: 'us-central1'
}, async (context) => {
  try {
    console.log('Starting cleanup of old images...');
    
    // Calculate the cutoff date (45 days ago)
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 45);
    
    console.log(`Deleting images uploaded before: ${cutoffDate.toISOString()}`);
    
    // Get all documents from assignedCustomers collection
    const customersSnapshot = await db.collection('assignedCustomers').get();
    
    if (customersSnapshot.empty) {
      console.log('No customer documents found.');
      return null;
    }
    
    console.log(`Processing ${customersSnapshot.docs.length} customer documents...`);
    
    let totalDeletedCount = 0;
    let totalErrorCount = 0;
    let documentsUpdated = 0;
    
    // Process each customer document
    for (const customerDoc of customersSnapshot.docs) {
      try {
        const customerData = customerDoc.data();
        const customerId = customerDoc.id;
        
        if (!customerData.serviceImages || !Array.isArray(customerData.serviceImages)) {
          console.log(`Customer ${customerId} has no serviceImages array`);
          continue;
        }
        
        const serviceImages = customerData.serviceImages;
        const imagesToKeep = [];
        let deletedFromThisDoc = 0;
        
        // Check each image in the serviceImages array
        for (const imageItem of serviceImages) {
          try {
            // Convert uploadedDate to Date object for comparison
            let imageDate;
            if (imageItem.uploadedDate) {
              if (imageItem.uploadedDate.toDate) {
                // It's a Firestore Timestamp
                imageDate = imageItem.uploadedDate.toDate();
              } else if (imageItem.uploadedDate instanceof Date) {
                // It's already a Date
                imageDate = imageItem.uploadedDate;
              } else if (typeof imageItem.uploadedDate === 'string') {
                // It's a string date
                imageDate = new Date(imageItem.uploadedDate);
              } else {
                console.log(`Invalid date format for image in customer ${customerId}`);
                imagesToKeep.push(imageItem); // Keep if date is invalid
                continue;
              }
            } else {
              console.log(`No uploadedDate found for image in customer ${customerId}`);
              imagesToKeep.push(imageItem); // Keep if no date
              continue;
            }
            
            // Check if image is older than cutoff date
            if (imageDate < cutoffDate) {
              console.log(`Deleting old image from customer ${customerId}, uploaded: ${imageDate.toISOString()}`);
              
              // Delete from Firebase Storage
              if (imageItem.imageUrl) {
                try {
                  const downloadURL = imageItem.imageUrl;
                  const url = new URL(downloadURL);
                  const pathWithEncoding = url.pathname.split('/o/')[1];
                  const pathPart = pathWithEncoding.split('?')[0];
                  const decodedPath = decodeURIComponent(pathPart);
                  
                  const file = bucket.file(decodedPath);
                  const [exists] = await file.exists();
                  
                  if (exists) {
                    await file.delete();
                    console.log(`Deleted storage file: ${decodedPath}`);
                  } else {
                    console.log(`Storage file not found: ${decodedPath}`);
                  }
                } catch (urlError) {
                  console.error(`Error parsing/deleting URL for customer ${customerId}:`, urlError);
                  totalErrorCount++;
                }
              }
              
              deletedFromThisDoc++;
              totalDeletedCount++;
            } else {
              // Keep this image (it's not old enough)
              imagesToKeep.push(imageItem);
            }
            
          } catch (imageError) {
            console.error(`Error processing image in customer ${customerId}:`, imageError);
            totalErrorCount++;
            // Keep the image if there's an error processing it
            imagesToKeep.push(imageItem);
          }
        }
        
        // Update the document if any images were deleted
        if (deletedFromThisDoc > 0) {
          await customerDoc.ref.update({
            serviceImages: imagesToKeep,
            lastUpdated: FieldValue.serverTimestamp()
          });
          
          documentsUpdated++;
          console.log(`Updated customer ${customerId}: removed ${deletedFromThisDoc} images, ${imagesToKeep.length} images remaining`);
        }
        
      } catch (customerError) {
        console.error(`Error processing customer ${customerDoc.id}:`, customerError);
        totalErrorCount++;
      }
    }
    
    console.log(`Cleanup completed. Total deleted: ${totalDeletedCount}, Documents updated: ${documentsUpdated}, Errors: ${totalErrorCount}`);
    
    // Log the cleanup results
    await db.collection('cleanupLogs').add({
      timestamp: FieldValue.serverTimestamp(),
      totalDeletedCount,
      documentsUpdated,
      totalErrorCount,
      cutoffDate: Timestamp.fromDate(cutoffDate),
      type: 'automated'
    });
    
    return { 
      totalDeletedCount, 
      documentsUpdated, 
      totalErrorCount 
    };
    
  } catch (error) {
    console.error('Error in cleanup function:', error);
    throw error;
  }
});

// Manual trigger function for testing
exports.manualDeleteOldImages = onCall({
  // Add CORS and other options if needed
  cors: true,
  region: 'us-central1'
}, async (request) => {
  // Add authentication check if needed
  // if (!request.auth) {
  //   throw new HttpsError('unauthenticated', 'Must be authenticated');
  // }
  
  try {
    console.log('Starting manual cleanup...');
    
    const daysOld = request.data.daysOld || 45;
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - daysOld);
    
    console.log(`Manual cleanup: Deleting images older than ${daysOld} days (before ${cutoffDate.toISOString()})`);
    
    const customersSnapshot = await db.collection('assignedCustomers').get();
    
    if (customersSnapshot.empty) {
      return { 
        message: 'No customer documents found.', 
        totalDeletedCount: 0,
        documentsUpdated: 0 
      };
    }
    
    let totalDeletedCount = 0;
    let documentsUpdated = 0;
    let totalErrorCount = 0;
    
    for (const customerDoc of customersSnapshot.docs) {
      try {
        const customerData = customerDoc.data();
        const customerId = customerDoc.id;
        
        if (!customerData.serviceImages || !Array.isArray(customerData.serviceImages)) {
          continue;
        }
        
        const serviceImages = customerData.serviceImages;
        const imagesToKeep = [];
        let deletedFromThisDoc = 0;
        
        for (const imageItem of serviceImages) {
          try {
            let imageDate;
            
            if (imageItem.uploadedDate) {
              if (imageItem.uploadedDate.toDate) {
                imageDate = imageItem.uploadedDate.toDate();
              } else if (imageItem.uploadedDate instanceof Date) {
                imageDate = imageItem.uploadedDate;
              } else if (typeof imageItem.uploadedDate === 'string') {
                imageDate = new Date(imageItem.uploadedDate);
              } else {
                imagesToKeep.push(imageItem);
                continue;
              }
            } else {
              imagesToKeep.push(imageItem);
              continue;
            }
            
            if (imageDate < cutoffDate) {
              // Delete from Storage
              if (imageItem.imageUrl) {
                try {
                  const downloadURL = imageItem.imageUrl;
                  const url = new URL(downloadURL);
                  const pathWithEncoding = url.pathname.split('/o/')[1];
                  const pathPart = pathWithEncoding.split('?')[0];
                  const decodedPath = decodeURIComponent(pathPart);
                  
                  const file = bucket.file(decodedPath);
                  const [exists] = await file.exists();
                  if (exists) {
                    await file.delete();
                  }
                } catch (urlError) {
                  console.error(`Manual cleanup URL error for ${customerId}:`, urlError);
                  totalErrorCount++;
                }
              }
              
              deletedFromThisDoc++;
              totalDeletedCount++;
            } else {
              imagesToKeep.push(imageItem);
            }
            
          } catch (imageError) {
            console.error(`Manual cleanup image error in ${customerId}:`, imageError);
            totalErrorCount++;
            imagesToKeep.push(imageItem);
          }
        }
        
        // Update document if images were deleted
        if (deletedFromThisDoc > 0) {
          await customerDoc.ref.update({
            serviceImages: imagesToKeep,
            lastUpdated: FieldValue.serverTimestamp()
          });
          documentsUpdated++;
        }
        
      } catch (customerError) {
        console.error(`Manual cleanup customer error ${customerDoc.id}:`, customerError);
        totalErrorCount++;
      }
    }
    
    // Log manual cleanup
    await db.collection('cleanupLogs').add({
      timestamp: FieldValue.serverTimestamp(),
      totalDeletedCount,
      documentsUpdated,
      totalErrorCount,
      cutoffDate: Timestamp.fromDate(cutoffDate),
      daysOld,
      type: 'manual',
      triggeredBy: request.auth ? request.auth.uid : 'anonymous'
    });
    
    return { 
      message: `Successfully processed ${documentsUpdated} customers and deleted ${totalDeletedCount} old images.`, 
      totalDeletedCount,
      documentsUpdated,
      totalErrorCount,
      daysOld
    };
    
  } catch (error) {
    console.error('Manual cleanup error:', error);
    throw error;
  }
});
