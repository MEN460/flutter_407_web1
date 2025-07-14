//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flight.g.dart';

/// Flight
///
/// Properties:
/// * [id] 
/// * [origin] 
/// * [destination] 
/// * [departureTime] 
/// * [arrivalTime] 
/// * [seatsAvailable] 
@BuiltValue()
abstract class Flight implements Built<Flight, FlightBuilder> {
  @BuiltValueField(wireName: r'id')
  int? get id;

  @BuiltValueField(wireName: r'origin')
  String? get origin;

  @BuiltValueField(wireName: r'destination')
  String? get destination;

  @BuiltValueField(wireName: r'departure_time')
  DateTime? get departureTime;

  @BuiltValueField(wireName: r'arrival_time')
  DateTime? get arrivalTime;

  @BuiltValueField(wireName: r'seats_available')
  int? get seatsAvailable;

  Flight._();

  factory Flight([void updates(FlightBuilder b)]) = _$Flight;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlightBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Flight> get serializer => _$FlightSerializer();
}

class _$FlightSerializer implements PrimitiveSerializer<Flight> {
  @override
  final Iterable<Type> types = const [Flight, _$Flight];

  @override
  final String wireName = r'Flight';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Flight object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(int),
      );
    }
    if (object.origin != null) {
      yield r'origin';
      yield serializers.serialize(
        object.origin,
        specifiedType: const FullType(String),
      );
    }
    if (object.destination != null) {
      yield r'destination';
      yield serializers.serialize(
        object.destination,
        specifiedType: const FullType(String),
      );
    }
    if (object.departureTime != null) {
      yield r'departure_time';
      yield serializers.serialize(
        object.departureTime,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.arrivalTime != null) {
      yield r'arrival_time';
      yield serializers.serialize(
        object.arrivalTime,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.seatsAvailable != null) {
      yield r'seats_available';
      yield serializers.serialize(
        object.seatsAvailable,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Flight object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FlightBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.id = valueDes;
          break;
        case r'origin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.origin = valueDes;
          break;
        case r'destination':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.destination = valueDes;
          break;
        case r'departure_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.departureTime = valueDes;
          break;
        case r'arrival_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.arrivalTime = valueDes;
          break;
        case r'seats_available':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.seatsAvailable = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Flight deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlightBuilder();
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

