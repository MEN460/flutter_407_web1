// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Booking extends Booking {
  @override
  final int? id;
  @override
  final int? flightId;
  @override
  final int? userId;
  @override
  final String? seatNumber;
  @override
  final String? status;

  factory _$Booking([void Function(BookingBuilder)? updates]) =>
      (BookingBuilder()..update(updates))._build();

  _$Booking._(
      {this.id, this.flightId, this.userId, this.seatNumber, this.status})
      : super._();
  @override
  Booking rebuild(void Function(BookingBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BookingBuilder toBuilder() => BookingBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Booking &&
        id == other.id &&
        flightId == other.flightId &&
        userId == other.userId &&
        seatNumber == other.seatNumber &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, flightId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, seatNumber.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Booking')
          ..add('id', id)
          ..add('flightId', flightId)
          ..add('userId', userId)
          ..add('seatNumber', seatNumber)
          ..add('status', status))
        .toString();
  }
}

class BookingBuilder implements Builder<Booking, BookingBuilder> {
  _$Booking? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _flightId;
  int? get flightId => _$this._flightId;
  set flightId(int? flightId) => _$this._flightId = flightId;

  int? _userId;
  int? get userId => _$this._userId;
  set userId(int? userId) => _$this._userId = userId;

  String? _seatNumber;
  String? get seatNumber => _$this._seatNumber;
  set seatNumber(String? seatNumber) => _$this._seatNumber = seatNumber;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  BookingBuilder() {
    Booking._defaults(this);
  }

  BookingBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _flightId = $v.flightId;
      _userId = $v.userId;
      _seatNumber = $v.seatNumber;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Booking other) {
    _$v = other as _$Booking;
  }

  @override
  void update(void Function(BookingBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Booking build() => _build();

  _$Booking _build() {
    final _$result = _$v ??
        _$Booking._(
          id: id,
          flightId: flightId,
          userId: userId,
          seatNumber: seatNumber,
          status: status,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
