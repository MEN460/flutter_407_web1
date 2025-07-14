// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BookingRequest extends BookingRequest {
  @override
  final int flightId;
  @override
  final String seatNumber;

  factory _$BookingRequest([void Function(BookingRequestBuilder)? updates]) =>
      (BookingRequestBuilder()..update(updates))._build();

  _$BookingRequest._({required this.flightId, required this.seatNumber})
      : super._();
  @override
  BookingRequest rebuild(void Function(BookingRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BookingRequestBuilder toBuilder() => BookingRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookingRequest &&
        flightId == other.flightId &&
        seatNumber == other.seatNumber;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, flightId.hashCode);
    _$hash = $jc(_$hash, seatNumber.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BookingRequest')
          ..add('flightId', flightId)
          ..add('seatNumber', seatNumber))
        .toString();
  }
}

class BookingRequestBuilder
    implements Builder<BookingRequest, BookingRequestBuilder> {
  _$BookingRequest? _$v;

  int? _flightId;
  int? get flightId => _$this._flightId;
  set flightId(int? flightId) => _$this._flightId = flightId;

  String? _seatNumber;
  String? get seatNumber => _$this._seatNumber;
  set seatNumber(String? seatNumber) => _$this._seatNumber = seatNumber;

  BookingRequestBuilder() {
    BookingRequest._defaults(this);
  }

  BookingRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _flightId = $v.flightId;
      _seatNumber = $v.seatNumber;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BookingRequest other) {
    _$v = other as _$BookingRequest;
  }

  @override
  void update(void Function(BookingRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookingRequest build() => _build();

  _$BookingRequest _build() {
    final _$result = _$v ??
        _$BookingRequest._(
          flightId: BuiltValueNullFieldError.checkNotNull(
              flightId, r'BookingRequest', 'flightId'),
          seatNumber: BuiltValueNullFieldError.checkNotNull(
              seatNumber, r'BookingRequest', 'seatNumber'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
