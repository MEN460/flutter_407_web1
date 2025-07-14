//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'booking_request.g.dart';

/// BookingRequest
///
/// Properties:
/// * [flightId] 
/// * [seatNumber] 
@BuiltValue()
abstract class BookingRequest implements Built<BookingRequest, BookingRequestBuilder> {
  @BuiltValueField(wireName: r'flight_id')
  int get flightId;

  @BuiltValueField(wireName: r'seat_number')
  String get seatNumber;

  BookingRequest._();

  factory BookingRequest([void updates(BookingRequestBuilder b)]) = _$BookingRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BookingRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BookingRequest> get serializer => _$BookingRequestSerializer();
}

class _$BookingRequestSerializer implements PrimitiveSerializer<BookingRequest> {
  @override
  final Iterable<Type> types = const [BookingRequest, _$BookingRequest];

  @override
  final String wireName = r'BookingRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BookingRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'flight_id';
    yield serializers.serialize(
      object.flightId,
      specifiedType: const FullType(int),
    );
    yield r'seat_number';
    yield serializers.serialize(
      object.seatNumber,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BookingRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BookingRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'flight_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.flightId = valueDes;
          break;
        case r'seat_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.seatNumber = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BookingRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BookingRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

