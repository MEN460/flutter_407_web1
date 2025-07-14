// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Flight extends Flight {
  @override
  final int? id;
  @override
  final String? origin;
  @override
  final String? destination;
  @override
  final DateTime? departureTime;
  @override
  final DateTime? arrivalTime;
  @override
  final int? seatsAvailable;

  factory _$Flight([void Function(FlightBuilder)? updates]) =>
      (FlightBuilder()..update(updates))._build();

  _$Flight._(
      {this.id,
      this.origin,
      this.destination,
      this.departureTime,
      this.arrivalTime,
      this.seatsAvailable})
      : super._();
  @override
  Flight rebuild(void Function(FlightBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlightBuilder toBuilder() => FlightBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Flight &&
        id == other.id &&
        origin == other.origin &&
        destination == other.destination &&
        departureTime == other.departureTime &&
        arrivalTime == other.arrivalTime &&
        seatsAvailable == other.seatsAvailable;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, origin.hashCode);
    _$hash = $jc(_$hash, destination.hashCode);
    _$hash = $jc(_$hash, departureTime.hashCode);
    _$hash = $jc(_$hash, arrivalTime.hashCode);
    _$hash = $jc(_$hash, seatsAvailable.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Flight')
          ..add('id', id)
          ..add('origin', origin)
          ..add('destination', destination)
          ..add('departureTime', departureTime)
          ..add('arrivalTime', arrivalTime)
          ..add('seatsAvailable', seatsAvailable))
        .toString();
  }
}

class FlightBuilder implements Builder<Flight, FlightBuilder> {
  _$Flight? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _origin;
  String? get origin => _$this._origin;
  set origin(String? origin) => _$this._origin = origin;

  String? _destination;
  String? get destination => _$this._destination;
  set destination(String? destination) => _$this._destination = destination;

  DateTime? _departureTime;
  DateTime? get departureTime => _$this._departureTime;
  set departureTime(DateTime? departureTime) =>
      _$this._departureTime = departureTime;

  DateTime? _arrivalTime;
  DateTime? get arrivalTime => _$this._arrivalTime;
  set arrivalTime(DateTime? arrivalTime) => _$this._arrivalTime = arrivalTime;

  int? _seatsAvailable;
  int? get seatsAvailable => _$this._seatsAvailable;
  set seatsAvailable(int? seatsAvailable) =>
      _$this._seatsAvailable = seatsAvailable;

  FlightBuilder() {
    Flight._defaults(this);
  }

  FlightBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _origin = $v.origin;
      _destination = $v.destination;
      _departureTime = $v.departureTime;
      _arrivalTime = $v.arrivalTime;
      _seatsAvailable = $v.seatsAvailable;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Flight other) {
    _$v = other as _$Flight;
  }

  @override
  void update(void Function(FlightBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Flight build() => _build();

  _$Flight _build() {
    final _$result = _$v ??
        _$Flight._(
          id: id,
          origin: origin,
          destination: destination,
          departureTime: departureTime,
          arrivalTime: arrivalTime,
          seatsAvailable: seatsAvailable,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
