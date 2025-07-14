// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Inquiry extends Inquiry {
  @override
  final int? id;
  @override
  final String? inquiryType;
  @override
  final String? status;
  @override
  final String? details;

  factory _$Inquiry([void Function(InquiryBuilder)? updates]) =>
      (InquiryBuilder()..update(updates))._build();

  _$Inquiry._({this.id, this.inquiryType, this.status, this.details})
      : super._();
  @override
  Inquiry rebuild(void Function(InquiryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InquiryBuilder toBuilder() => InquiryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Inquiry &&
        id == other.id &&
        inquiryType == other.inquiryType &&
        status == other.status &&
        details == other.details;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, inquiryType.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Inquiry')
          ..add('id', id)
          ..add('inquiryType', inquiryType)
          ..add('status', status)
          ..add('details', details))
        .toString();
  }
}

class InquiryBuilder implements Builder<Inquiry, InquiryBuilder> {
  _$Inquiry? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _inquiryType;
  String? get inquiryType => _$this._inquiryType;
  set inquiryType(String? inquiryType) => _$this._inquiryType = inquiryType;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _details;
  String? get details => _$this._details;
  set details(String? details) => _$this._details = details;

  InquiryBuilder() {
    Inquiry._defaults(this);
  }

  InquiryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _inquiryType = $v.inquiryType;
      _status = $v.status;
      _details = $v.details;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Inquiry other) {
    _$v = other as _$Inquiry;
  }

  @override
  void update(void Function(InquiryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Inquiry build() => _build();

  _$Inquiry _build() {
    final _$result = _$v ??
        _$Inquiry._(
          id: id,
          inquiryType: inquiryType,
          status: status,
          details: details,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
