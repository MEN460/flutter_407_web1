// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TicketRequest extends TicketRequest {
  @override
  final String type;
  @override
  final String details;

  factory _$TicketRequest([void Function(TicketRequestBuilder)? updates]) =>
      (TicketRequestBuilder()..update(updates))._build();

  _$TicketRequest._({required this.type, required this.details}) : super._();
  @override
  TicketRequest rebuild(void Function(TicketRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TicketRequestBuilder toBuilder() => TicketRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TicketRequest &&
        type == other.type &&
        details == other.details;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TicketRequest')
          ..add('type', type)
          ..add('details', details))
        .toString();
  }
}

class TicketRequestBuilder
    implements Builder<TicketRequest, TicketRequestBuilder> {
  _$TicketRequest? _$v;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  String? _details;
  String? get details => _$this._details;
  set details(String? details) => _$this._details = details;

  TicketRequestBuilder() {
    TicketRequest._defaults(this);
  }

  TicketRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _details = $v.details;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TicketRequest other) {
    _$v = other as _$TicketRequest;
  }

  @override
  void update(void Function(TicketRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TicketRequest build() => _build();

  _$TicketRequest _build() {
    final _$result = _$v ??
        _$TicketRequest._(
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'TicketRequest', 'type'),
          details: BuiltValueNullFieldError.checkNotNull(
              details, r'TicketRequest', 'details'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
