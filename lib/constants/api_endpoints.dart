class ApiEndpoints {
  static const baseUrl = 'http://localhost:5000'; // Change for production

  // Storage keys
  static const jwtStorageKey = 'ka_jwt_token';
  static const userStorageKey = 'ka_user_data';

  // -----------------------
  // AUTH
  // -----------------------
  static const login = '/auth/login';
  static const register = '/auth/register';
  // NOTE: refreshToken is not in OpenAPI but add if Flask supports it
  static const refreshToken = '/auth/refresh';

  // -----------------------
  // 🛫 Flights
  static const flights = '/flights/';
  static String flightById(int flightId) => '/flights/$flightId';
  static String flightSeats(int flightId) => '/flights/$flightId/seats';
  static String flightStatus(String flightId) => '/flights/$flightId/status';
  static String flightPassengers(int flightId) => '/flights/$flightId/passengers';
  static String notifyAboutFlight(int flightId) => '/flights/$flightId/notify';

  // -----------------------
   // 📖 Bookings
  static const bookings = '/bookings/';
  static String bookingById(int id) => '/bookings/$id';
  static String bookingInquiry(int bookingId) => '/bookings/$bookingId/inquiry';
  static String bookingCheckIn(int bookingId) => '/bookings/$bookingId/check-in';
  static String cancelBooking(int bookingId) => '/bookings/$bookingId/cancel';
  static String updateBooking(int bookingId) => '/bookings/$bookingId/update';

  // -----------------------
  // 💬 Help Desk
  static const helpTickets = '/help/tickets';
  static String helpTicketById(int id) => '/help/tickets/$id';
  static String updateHelpTicket(int id) => '/help/tickets/$id/update';
   static const helpTicketsAdmin = '/help/tickets/admin';
  static const knowledgeBase = '/help/knowledge';
  static String knowledgeArticle(int id) => '/help/knowledge/$id';

  // -----------------------
  // 📝 Feedback
  static const feedback = '/feedback/';
  static String feedbackById(int feedbackId) => '/feedback/$feedbackId';
  static const adminFeedback = '/feedback/admin';

  // ----------------------
  // 👨‍💼 Admin
  static const adminUsers = '/admin/users';
  static String adminUserById(int userId) => '/admin/users/$userId';
  static String adminUpdateUserRole(int userId) => '/admin/users/$userId/role';
  static String adminLockUser(int userId) => '/admin/users/$userId/lock';
  static String adminUnlockUser(int userId) => '/admin/users/$userId/unlock';

  // 👨‍💼 Admin Logs
  static const adminSystemLogs = '/admin/logs';
  static const adminLogs = '/admin/logs';

  static const adminCreateFlight = '/admin/flights';
  static String adminAssignFlight(int flightId) =>
      '/admin/flights/$flightId/assign';
  static String adminFlightSeats(int flightId) =>
      '/admin/flights/$flightId/seats';
  static const adminBookingReport = '/admin/reports/bookings';
  static const adminFlightReport = '/admin/reports/flights';
  static const adminUserReport = '/admin/reports/users';
  static const adminDashboardReport = '/admin/reports/dashboard';

  // 👷 Employee
  static const employeeFlights = '/employee/flights';
  static String employeeUpdateFlightStatus(int flightId) =>
      '/employee/flights/$flightId/update-status';
  static String employeePassengerList(int flightId) =>
      '/employee/flights/$flightId/passengers';
  static String employeeCheckInPassenger(int flightId, int userId) =>
      '/employee/flights/$flightId/passengers/$userId/check-in';
}

