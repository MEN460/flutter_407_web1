//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:kenya_airways_flutter_sdk/src/date_serializer.dart';
import 'package:kenya_airways_flutter_sdk/src/model/date.dart';

import 'package:kenya_airways_flutter_sdk/src/model/auth_login_post_request.dart';
import 'package:kenya_airways_flutter_sdk/src/model/auth_register_post_request.dart';
import 'package:kenya_airways_flutter_sdk/src/model/auth_tokens.dart';
import 'package:kenya_airways_flutter_sdk/src/model/booking.dart';
import 'package:kenya_airways_flutter_sdk/src/model/booking_request.dart';
import 'package:kenya_airways_flutter_sdk/src/model/flight.dart';
import 'package:kenya_airways_flutter_sdk/src/model/inquiry.dart';
import 'package:kenya_airways_flutter_sdk/src/model/ticket_request.dart';
import 'package:kenya_airways_flutter_sdk/src/model/user.dart';

part 'serializers.g.dart';

@SerializersFor([
  AuthLoginPostRequest,
  AuthRegisterPostRequest,
  AuthTokens,
  Booking,
  BookingRequest,
  Flight,
  Inquiry,
  TicketRequest,
  User,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Booking)]),
        () => ListBuilder<Booking>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Inquiry)]),
        () => ListBuilder<Inquiry>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Flight)]),
        () => ListBuilder<Flight>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
