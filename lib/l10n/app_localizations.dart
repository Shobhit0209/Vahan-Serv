import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @langselected.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langselected;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @chooselanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooselanguage;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Select Your Role'**
  String get role;

  /// No description provided for @cce.
  ///
  /// In en, this message translates to:
  /// **'CCE (Car Care Expert)'**
  String get cce;

  /// No description provided for @carOwner.
  ///
  /// In en, this message translates to:
  /// **'Car Owner'**
  String get carOwner;

  /// No description provided for @findme.
  ///
  /// In en, this message translates to:
  /// **'Find Me'**
  String get findme;

  /// No description provided for @cceid.
  ///
  /// In en, this message translates to:
  /// **'Enter your CCE ID'**
  String get cceid;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'CCE ID'**
  String get id;

  /// No description provided for @doj.
  ///
  /// In en, this message translates to:
  /// **'D.O.J'**
  String get doj;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @notyou.
  ///
  /// In en, this message translates to:
  /// **'Not you?'**
  String get notyou;

  /// No description provided for @mobilenoverify.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number Verification'**
  String get mobilenoverify;

  /// No description provided for @entermobile.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number for verification through OTP.'**
  String get entermobile;

  /// No description provided for @getotp.
  ///
  /// In en, this message translates to:
  /// **'Get OTP'**
  String get getotp;

  /// No description provided for @loginusingotp.
  ///
  /// In en, this message translates to:
  /// **'Login using OTP'**
  String get loginusingotp;

  /// No description provided for @enterotp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP received on your mobile number'**
  String get enterotp;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @com.
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get com;

  /// No description provided for @pen.
  ///
  /// In en, this message translates to:
  /// **'Pending Tasks'**
  String get pen;

  /// No description provided for @tt.
  ///
  /// In en, this message translates to:
  /// **'Total Tasks'**
  String get tt;

  /// No description provided for @tetm.
  ///
  /// In en, this message translates to:
  /// **'Total earning this month'**
  String get tetm;

  /// No description provided for @tetd.
  ///
  /// In en, this message translates to:
  /// **'Total earning today'**
  String get tetd;

  /// No description provided for @totalcust.
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get totalcust;

  /// No description provided for @todaydate.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Date'**
  String get todaydate;

  /// No description provided for @dailyassignedtasks.
  ///
  /// In en, this message translates to:
  /// **'Daily Assigned Tasks'**
  String get dailyassignedtasks;

  /// No description provided for @refferal1.
  ///
  /// In en, this message translates to:
  /// **'Invite your friends to become '**
  String get refferal1;

  /// No description provided for @refferal2.
  ///
  /// In en, this message translates to:
  /// **' & you can '**
  String get refferal2;

  /// No description provided for @refferal3.
  ///
  /// In en, this message translates to:
  /// **'earn ₹50 '**
  String get refferal3;

  /// No description provided for @refferal4.
  ///
  /// In en, this message translates to:
  /// **'on each refferal.'**
  String get refferal4;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notification;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @earninghistory.
  ///
  /// In en, this message translates to:
  /// **'Earning History'**
  String get earninghistory;

  /// No description provided for @earningsum.
  ///
  /// In en, this message translates to:
  /// **'Earning Summary'**
  String get earningsum;

  /// No description provided for @payouthistory.
  ///
  /// In en, this message translates to:
  /// **'Payout History'**
  String get payouthistory;

  /// No description provided for @searchbyname.
  ///
  /// In en, this message translates to:
  /// **'Search by name, amount, date, year'**
  String get searchbyname;

  /// No description provided for @nonotiyet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get nonotiyet;

  /// No description provided for @markallasread.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markallasread;

  /// No description provided for @clearall.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearall;

  /// No description provided for @clearallnoti.
  ///
  /// In en, this message translates to:
  /// **'Clear All Notifications'**
  String get clearallnoti;

  /// No description provided for @questionforclearing.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all notifications?'**
  String get questionforclearing;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @mngcust.
  ///
  /// In en, this message translates to:
  /// **'Manage Customers'**
  String get mngcust;

  /// No description provided for @continfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get continfo;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @hANDs.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get hANDs;

  /// No description provided for @aboutapp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutapp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @questionforlogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get questionforlogout;

  /// No description provided for @mngcustomerprofile.
  ///
  /// In en, this message translates to:
  /// **'Manage Customer'**
  String get mngcustomerprofile;

  /// No description provided for @imgupldsentence.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Images After Service'**
  String get imgupldsentence;

  /// No description provided for @flagcust.
  ///
  /// In en, this message translates to:
  /// **'Flag Customer'**
  String get flagcust;

  /// No description provided for @submitforreview.
  ///
  /// In en, this message translates to:
  /// **'Submit For Review'**
  String get submitforreview;

  /// No description provided for @shortnote.
  ///
  /// In en, this message translates to:
  /// **'Write a short note about your reason.'**
  String get shortnote;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @trainingresources.
  ///
  /// In en, this message translates to:
  /// **'Training Resources'**
  String get trainingresources;

  /// No description provided for @markinactive.
  ///
  /// In en, this message translates to:
  /// **'Note- This will mark you Inactive and absent for today.\nYou will be able to mark yourself active only after 10 hours from now.\nDo you want to mark yourself Inactive for today?'**
  String get markinactive;

  /// No description provided for @markactive.
  ///
  /// In en, this message translates to:
  /// **'You will be marked Active for today. Do you want to mark yourself active for today?'**
  String get markactive;

  /// No description provided for @masin.
  ///
  /// In en, this message translates to:
  /// **'Mark as Inactive'**
  String get masin;

  /// No description provided for @masact.
  ///
  /// In en, this message translates to:
  /// **'Mark as Active'**
  String get masact;

  /// No description provided for @cannotmarkactive.
  ///
  /// In en, this message translates to:
  /// **'Cannot Mark Active'**
  String get cannotmarkactive;

  /// No description provided for @markactivein.
  ///
  /// In en, this message translates to:
  /// **'You can mark yourself active again in'**
  String get markactivein;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
