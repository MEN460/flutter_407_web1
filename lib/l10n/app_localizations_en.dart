// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Kenya Airways';

  @override
  String get appDescription => 'Book your flights with Kenya Airways, the pride of Africa. Enjoy seamless online booking, manage your trips, and experience world-class service.';

  @override
  String get appVersion => '1.0.0';

  @override
  String get appAuthor => 'Kenya Airways Ltd.';

  @override
  String get appTitle => 'Kenya Airways Online Booking';

  @override
  String get appSubtitle => 'Fly with Pride';

  @override
  String get homeTitle => 'Welcome to Kenya Airways';

  @override
  String get homeSubtitle => 'Your gateway to the world';

  @override
  String get registerTitle => 'Create New Account';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get emailHint => 'Enter your email address';

  @override
  String get emailHelper => 'We\'ll use this to send booking confirmations';

  @override
  String get emailRequired => 'Email address is required';

  @override
  String get emailInvalidFormat => 'Please enter a valid email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get registerButton => 'Register';

  @override
  String get logoutButton => 'Sign Out';

  @override
  String get guestOption => 'Continue as Guest';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get flightSearch => 'Flight Search';

  @override
  String get destinationLabel => 'To';

  @override
  String get departureLabel => 'Departure Date';

  @override
  String get returnLabel => 'Return Date';

  @override
  String get oneWay => 'One Way';

  @override
  String get roundTrip => 'Round Trip';

  @override
  String get passengersLabel => 'Passengers';

  @override
  String get classLabel => 'Cabin Class';

  @override
  String get economyClass => 'Economy';

  @override
  String get middleClass => 'Middle';

  @override
  String get executiveClass => 'Executive';

  @override
  String get searchButton => 'Search Flights';

  @override
  String get noFlightsFound => 'No flights match your criteria';

  @override
  String priceFrom(String price) {
    return 'From $price';
  }

  @override
  String seatsAvailable(int count) {
    return '$count seats left';
  }

  @override
  String get flightDetails => 'Flight Details';

  @override
  String get flightDetailsSubtitle => 'Review your flight details before booking';

  @override
  String get flightDetailsDescription => 'Please review the flight details below before proceeding to booking.';

  @override
  String get flightNumber => 'Flight No';

  @override
  String get duration => 'Duration';

  @override
  String get directFlight => 'Direct';

  @override
  String get connectingFlight => 'Connecting';

  @override
  String get selectFlight => 'Select';

  @override
  String get flightResults => 'Available Flights';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get bookingDetails => 'Booking Details';

  @override
  String get cancelBooking => 'Cancel Booking';

  @override
  String get rescheduleBooking => 'Change Flight';

  @override
  String get cancellationPolicy => 'Cancellation Policy';

  @override
  String get cancelConfirm => 'Are you sure you want to cancel this booking?';

  @override
  String get cancelSuccess => 'Booking successfully cancelled';

  @override
  String get rescheduleConfirm => 'Are you sure you want to change your flight?';

  @override
  String get rescheduleSuccess => 'Flight successfully changed';

  @override
  String get downloadTicket => 'Download E-Ticket';

  @override
  String get passengerInfo => 'Passenger Information';

  @override
  String get passengerTitle => 'Title';

  @override
  String get mr => 'Mr';

  @override
  String get mrs => 'Mrs';

  @override
  String get ms => 'Ms';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get passportNumber => 'Passport Number';

  @override
  String get specialAssistance => 'Require special assistance?';

  @override
  String get mealPreference => 'Meal Preference';

  @override
  String get savePassenger => 'Save Information';

  @override
  String get paymentTitle => 'Complete Payment';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get cardHolder => 'Cardholder Name';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get cvv => 'CVV';

  @override
  String get payNow => 'Pay Now';

  @override
  String get paymentSuccess => 'Payment Successful!';

  @override
  String confirmationSent(String email) {
    return 'Confirmation sent to $email';
  }

  @override
  String get paymentError => 'Payment failed. Please check your details and try again.';

  @override
  String get paymentGateway => 'Payment Gateway';

  @override
  String get paymentProcessing => 'Processing your payment...';

  @override
  String get statusOnTime => 'On Time';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusDelayed => 'Delayed';

  @override
  String get statusBoarding => 'Boarding';

  @override
  String get statusDeparted => 'Departed';

  @override
  String get onTime => 'On Time';

  @override
  String get delay => 'Delay';

  @override
  String get cancellation => 'Cancellation';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get continueLabel => 'Continue';

  @override
  String get submitButton => 'Submit';

  @override
  String get submittingButton => 'Submitting...';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get faq => 'Frequently Asked Questions';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get feedbackTitle => 'Share Your Feedback';

  @override
  String get feedbackPrompt => 'How was your experience?';

  @override
  String get thankYouFeedback => 'Thank you for your feedback!';

  @override
  String get ticketSubject => 'Subject';

  @override
  String get ticketMessage => 'Message';

  @override
  String get submitTicket => 'Submit Support Ticket';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get commentsLabel => 'Comments';

  @override
  String get submitFeedback => 'Submit Feedback';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get flightManagement => 'Flight Schedules';

  @override
  String get reports => 'System Reports';

  @override
  String get helpContent => 'Help Articles';

  @override
  String get passengerManifest => 'Passenger Manifest';

  @override
  String get supportTickets => 'Support Tickets';

  @override
  String get crewDashboard => 'Crew Dashboard';

  @override
  String get flightMonitoring => 'Flight Monitoring';

  @override
  String get updateStatus => 'Update Status';

  @override
  String get boardingStatus => 'Boarding Status';

  @override
  String get checkInDesk => 'Check-in Desk';

  @override
  String capacityWarning(int current, int max) {
    return 'Capacity: $current/$max';
  }

  @override
  String get bookingInquiryTitle => 'Booking Inquiry';

  @override
  String get bookingInquirySubtitle => 'Need help with your booking? We\'re here to assist you with any questions or concerns.';

  @override
  String get bookingIdLabel => 'Booking ID';

  @override
  String get bookingIdHint => 'Enter your booking reference (e.g., KQ123ABC)';

  @override
  String get bookingIdHelper => 'This is your 6-character confirmation code';

  @override
  String get bookingIdRequired => 'Please enter your booking ID';

  @override
  String get bookingIdTooShort => 'Booking ID must be at least 6 characters';

  @override
  String get bookingIdInvalidFormat => 'Booking ID must contain only letters and numbers';

  @override
  String get inquiryDetails => 'Inquiry Details';

  @override
  String get inquiryHint => 'Please describe your issue or question in detail...';

  @override
  String get inquiryHelper => 'Please be as specific as possible to help us assist you better';

  @override
  String get inquiryRequired => 'Please describe your inquiry';

  @override
  String get inquiryTooShort => 'Please provide more details (minimum 20 characters)';

  @override
  String get inquirySubmittedTitle => 'Inquiry Submitted';

  @override
  String get inquirySubmittedMessage => 'Your inquiry has been submitted successfully. We will get back to you within 24-48 hours.';

  @override
  String get okButton => 'OK';

  @override
  String get faqSectionTitle => 'Frequently Asked Questions';

  @override
  String get faqQuestion1 => 'How do I modify my booking?';

  @override
  String get faqAnswer1 => 'You can modify your booking up to 24 hours before departure through our app or website. Changes may be subject to fare differences and fees.';

  @override
  String get faqQuestion2 => 'What is your cancellation policy?';

  @override
  String get faqAnswer2 => 'Cancellations made more than 48 hours before departure receive a full refund. Later cancellations may incur fees based on ticket type.';

  @override
  String get faqQuestion3 => 'How long does it take to get a response?';

  @override
  String get faqAnswer3 => 'We typically respond to inquiries within 24-48 hours during business days. Urgent matters are prioritized.';

  @override
  String get faqQuestion4 => 'How do I contact customer support?';

  @override
  String get faqAnswer4 => 'You can contact customer support through this app, call our hotline, or visit our service desk at the airport.';

  @override
  String get faqQuestion5 => 'What if I lose my ticket?';

  @override
  String get faqAnswer5 => 'If you lose your ticket, contact customer support immediately with your booking ID. We can resend your e-ticket or help you at check-in.';

  @override
  String get alternativeContactTitle => 'Other Ways to Reach Us';

  @override
  String get phoneSupport => 'Phone Support';

  @override
  String get phoneSupportNumber => '+254 20 327 4747';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get emailSupportAddress => 'support@kenya-airways.com';

  @override
  String get inquiryTypeLabel => 'Inquiry Type';

  @override
  String get selectInquiryType => 'Select inquiry type';

  @override
  String get inquiryTypeRequired => 'Please select an inquiry type';

  @override
  String get inquiryTypeGeneral => 'General Inquiry';

  @override
  String get inquiryTypeRefund => 'Refund Request';

  @override
  String get inquiryTypeModification => 'Flight Modification';

  @override
  String get inquiryTypeBaggage => 'Baggage Issue';

  @override
  String get inquiryTypeCheckin => 'Check-in Support';

  @override
  String get inquiryTypeComplaint => 'Complaint';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get networkError => 'Network error occurred. Please check your connection and try again.';

  @override
  String get timeoutError => 'Request timed out. Please try again later.';

  @override
  String get bookingNotFoundError => 'Booking not found. Please check your booking ID and try again.';

  @override
  String get authenticationError => 'Authentication failed. Please try again or contact support.';

  @override
  String get generalError => 'Something went wrong. Please try again later.';

  @override
  String get bookingError => 'Error processing your booking. Please try again later.';

  @override
  String get flightSearchError => 'Error searching for flights. Please check your criteria and try again.';

  @override
  String get sessionExpired => 'Session expired. Please log in again';

  @override
  String get inquiryTypeCancellation => 'Booking Cancellation';

  @override
  String get inquiryTypeSeatChange => 'Seat Change';

  @override
  String get inquiryTypeFlightChange => 'Flight Change';

  @override
  String get inquiryTypeSpecialAssistance => 'Special Assistance';

  @override
  String get inquiryTypeFeedback => 'Feedback';

  @override
  String get inquiryTypeOther => 'Other';

  @override
  String get priorityLabel => 'Priority Level';

  @override
  String get selectPriority => 'Select Priority';

  @override
  String get priorityLow => 'Low Priority';

  @override
  String get priorityMedium => 'Medium Priority';

  @override
  String get priorityHigh => 'High Priority';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get optionalField => 'Optional';

  @override
  String get loginRequiredError => 'Login required. Please log in to continue.';

  @override
  String get resetButton => 'Reset';

  @override
  String get inquiryTypeUnknown => 'Unknown Inquiry Type';
}
