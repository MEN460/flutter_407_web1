import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  String get flightSearch;
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
    Locale('en')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Kenya Airways'**
  String get appName;

  /// Description of the Kenya Airways app
  ///
  /// In en, this message translates to:
  /// **'Book your flights with Kenya Airways, the pride of Africa. Enjoy seamless online booking, manage your trips, and experience world-class service.'**
  String get appDescription;

  /// The version of the application
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get appVersion;

  /// The author of the application
  ///
  /// In en, this message translates to:
  /// **'Kenya Airways Ltd.'**
  String get appAuthor;

  /// Main title for the app
  ///
  /// In en, this message translates to:
  /// **'Kenya Airways Online Booking'**
  String get appTitle;

  /// Subtitle for the app
  ///
  /// In en, this message translates to:
  /// **'Fly with Pride'**
  String get appSubtitle;

  /// Title for the home page
  ///
  /// In en, this message translates to:
  /// **'Welcome to Kenya Airways'**
  String get homeTitle;

  /// Subtitle for the home page
  ///
  /// In en, this message translates to:
  /// **'Your gateway to the world'**
  String get homeSubtitle;

  /// Title for the registration page
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get registerTitle;

  /// Label for email input
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// Label for password input
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Title for available flights
  ///
  /// In en, this message translates to:
  /// **'Available Flights'**
  String get flightResults;

  /// Label for flight duration
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Label for flight number
  ///
  /// In en, this message translates to:
  /// **'Flight No'**
  String get flightNumber;

  /// Label for direct flights
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get directFlight;

  /// Title for my bookings section
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// Title for booking details section
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// Title for flight information section
  ///
  /// In en, this message translates to:
  /// **'Flight Information'**
  String get flightInfo;

  /// Title for passenger information section
  ///
  /// In en, this message translates to:
  /// **'Passenger Information'**
  String get passengerInfo;

  /// Label for passenger title
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get passengerTitle;

  /// Title Mr
  ///
  /// In en, this message translates to:
  /// **'Mr'**
  String get mr;

  /// Title Mrs
  ///
  /// In en, this message translates to:
  /// **'Mrs'**
  String get mrs;

  /// Title Ms
  ///
  /// In en, this message translates to:
  /// **'Ms'**
  String get ms;

  /// Title for payment section
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get paymentTitle;

  /// Label for card number
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// Label for cardholder name
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardHolder;

  /// Label for card expiry date
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// Message when payment is successful
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccess;

  /// Payment confirmation message
  ///
  /// In en, this message translates to:
  /// **'Confirmation sent to {email}'**
  String confirmationSent(String email);

  /// Message when payment fails
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please check your details and try again.'**
  String get paymentError;

  /// Label for payment gateway
  ///
  /// In en, this message translates to:
  /// **'Payment Gateway'**
  String get paymentGateway;

  /// Label for passport number
  ///
  /// In en, this message translates to:
  /// **'Passport Number'**
  String get passportNumber;

  /// Label for special assistance
  ///
  /// In en, this message translates to:
  /// **'Require special assistance?'**
  String get specialAssistance;

  /// Label for meal preference
  ///
  /// In en, this message translates to:
  /// **'Meal Preference'**
  String get mealPreference;

  /// Button text to save passenger information
  ///
  /// In en, this message translates to:
  /// **'Save Information'**
  String get savePassenger;

  /// Confirmation message for cancelling booking
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking?'**
  String get cancelConfirm;

  /// Message when booking is cancelled
  ///
  /// In en, this message translates to:
  /// **'Booking successfully cancelled'**
  String get cancelSuccess;

  /// Capacity warning for employees
  ///
  /// In en, this message translates to:
  /// **'Capacity: {current}/{max}'**
  String capacityWarning(int current, int max);

  /// Button text to download e-ticket
  ///
  /// In en, this message translates to:
  /// **'Download E-Ticket'**
  String get downloadTicket;

  /// Title for help center
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// Title for FAQ section
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faq;

  /// Title for contact support
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// Title for feedback section
  ///
  /// In en, this message translates to:
  /// **'Share Your Feedback'**
  String get feedbackTitle;

  /// Prompt for feedback
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get feedbackPrompt;

  /// Button to cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button to go back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Button to go to next step
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Status label for on time
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get statusOnTime;

  /// Status label for confirmed
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// Status label for pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Shows the starting price for a flight
  ///
  /// In en, this message translates to:
  /// **'From {price}'**
  String priceFrom(String price);

  /// Seat availability indicator
  ///
  /// In en, this message translates to:
  /// **'{count} seats left'**
  String seatsAvailable(int count);

  /// Message when session expires
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again'**
  String get sessionExpired;

  /// Message after feedback is submitted
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouFeedback;

  /// Label for ticket subject
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get ticketSubject;

  /// Label for ticket message
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get ticketMessage;

  /// Button to submit form
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// Confirmation message for changing flight
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change your flight?'**
  String get rescheduleConfirm;

  /// Message when flight is changed
  ///
  /// In en, this message translates to:
  /// **'Flight successfully changed'**
  String get rescheduleSuccess;

  /// Message when no flights match criteria
  ///
  /// In en, this message translates to:
  /// **'No flights match your criteria'**
  String get noFlightsFound;

  /// Title for flight details section
  ///
  /// In en, this message translates to:
  /// **'Flight Details'**
  String get flightDetails;

  /// Subtitle for flight details section
  ///
  /// In en, this message translates to:
  /// **'Review your flight details before booking'**
  String get flightDetailsSubtitle;

  /// Description for flight details section
  ///
  /// In en, this message translates to:
  /// **'Please review the flight details below before proceeding to booking.'**
  String get flightDetailsDescription;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Text for login button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// Text for register button
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// Text for logout button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logoutButton;

  /// Option to continue as guest
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get guestOption;

  /// Label for destination input
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get destinationLabel;

  /// Label for departure date
  ///
  /// In en, this message translates to:
  /// **'Departure Date'**
  String get departureLabel;

  /// Label for return date
  ///
  /// In en, this message translates to:
  /// **'Return Date'**
  String get returnLabel;

  /// Label for one-way trip
  ///
  /// In en, this message translates to:
  /// **'One Way'**
  String get oneWay;

  /// Label for round trip
  ///
  /// In en, this message translates to:
  /// **'Round Trip'**
  String get roundTrip;

  /// Label for passengers selector
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengersLabel;

  /// Label for cabin class selector
  ///
  /// In en, this message translates to:
  /// **'Cabin Class'**
  String get classLabel;

  /// Economy class label
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get economyClass;

  /// Middle class label
  ///
  /// In en, this message translates to:
  /// **'Middle'**
  String get middleClass;

  /// Executive class label
  ///
  /// In en, this message translates to:
  /// **'Executive'**
  String get executiveClass;

  /// Search flights button text
  ///
  /// In en, this message translates to:
  /// **'Search Flights'**
  String get searchButton;

  /// Label for connecting flights
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get connectingFlight;

  /// Button to select flight
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectFlight;

  /// Title for cancellation policy
  ///
  /// In en, this message translates to:
  /// **'Cancellation Policy'**
  String get cancellationPolicy;

  /// Button to cancel booking
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// Button to reschedule booking
  ///
  /// In en, this message translates to:
  /// **'Change Flight'**
  String get rescheduleBooking;

  /// Label for first name
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Label for last name
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Label for phone number
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Label for CVV code
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// Button to complete payment
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// Title for admin dashboard
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// Title for flight management
  ///
  /// In en, this message translates to:
  /// **'Flight Schedules'**
  String get flightManagement;

  /// Title for reports section
  ///
  /// In en, this message translates to:
  /// **'System Reports'**
  String get reports;

  /// Title for help articles
  ///
  /// In en, this message translates to:
  /// **'Help Articles'**
  String get helpContent;

  /// Title for passenger manifest
  ///
  /// In en, this message translates to:
  /// **'Passenger Manifest'**
  String get passengerManifest;

  /// Title for support tickets
  ///
  /// In en, this message translates to:
  /// **'Support Tickets'**
  String get supportTickets;

  /// Title for crew dashboard
  ///
  /// In en, this message translates to:
  /// **'Crew Dashboard'**
  String get crewDashboard;

  /// Title for flight monitoring
  ///
  /// In en, this message translates to:
  /// **'Flight Monitoring'**
  String get flightMonitoring;

  /// Button to update flight status
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// Status label for delay
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get delay;

  /// Status label for cancellation
  ///
  /// In en, this message translates to:
  /// **'Cancellation'**
  String get cancellation;

  /// Status label for on time
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get onTime;

  /// Title for boarding status
  ///
  /// In en, this message translates to:
  /// **'Boarding Status'**
  String get boardingStatus;

  /// Title for check-in desk
  ///
  /// In en, this message translates to:
  /// **'Check-in Desk'**
  String get checkInDesk;

  /// Button to submit support ticket
  ///
  /// In en, this message translates to:
  /// **'Submit Support Ticket'**
  String get submitTicket;

  /// Label for rating input
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// Label for comments input
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsLabel;

  /// Button to submit feedback
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// Button label for continuing to the next screen
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Generic success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Button to retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Validation message for email
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// Validation message for password mismatch
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// Status label for cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// Status label for completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Status label for delayed
  ///
  /// In en, this message translates to:
  /// **'Delayed'**
  String get statusDelayed;

  /// Status label for boarding
  ///
  /// In en, this message translates to:
  /// **'Boarding'**
  String get statusBoarding;

  /// Status label for departed
  ///
  /// In en, this message translates to:
  /// **'Departed'**
  String get statusDeparted;

  String get bookingInquiryTitle;

  String get bookingIdLabel;

  String get bookingIdHint;

  String get bookingIdRequired;

  String get inquiryDetails;

  String get inquiryHint;

  String get inquiryRequired;

  String get inquiryTooShort;

  String get faqSectionTitle;

  String get faqQuestion1;

  String get faqAnswer1;

  String get faqQuestion2;

  String get faqAnswer2;

  String get faqQuestion3;

  String get faqAnswer3;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
