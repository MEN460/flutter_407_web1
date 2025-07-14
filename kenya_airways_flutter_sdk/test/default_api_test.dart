import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for DefaultApi
void main() {
  final instance = Openapi().getDefaultApi();

  group(DefaultApi, () {
    // Login user
    //
    //Future<AuthTokens> authLoginPost(AuthLoginPostRequest authLoginPostRequest) async
    test('test authLoginPost', () async {
      // TODO
    });

    // Register a new user
    //
    //Future<JsonObject> authRegisterPost(AuthRegisterPostRequest authRegisterPostRequest) async
    test('test authRegisterPost', () async {
      // TODO
    });

    // Get user's bookings
    //
    //Future<BuiltList<Booking>> bookingsGet() async
    test('test bookingsGet', () async {
      // TODO
    });

    // Create a booking
    //
    //Future<JsonObject> bookingsPost(BookingRequest bookingRequest) async
    test('test bookingsPost', () async {
      // TODO
    });

    // List all flights
    //
    //Future<BuiltList<Flight>> flightsGet() async
    test('test flightsGet', () async {
      // TODO
    });

    // Get user's help tickets
    //
    //Future<BuiltList<Inquiry>> helpTicketsGet() async
    test('test helpTicketsGet', () async {
      // TODO
    });

    // Submit help ticket
    //
    //Future<JsonObject> helpTicketsPost(TicketRequest ticketRequest) async
    test('test helpTicketsPost', () async {
      // TODO
    });

  });
}
