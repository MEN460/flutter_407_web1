// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_login_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthLoginPostRequest extends AuthLoginPostRequest {
  @override
  final String email;
  @override
  final String password;

  factory _$AuthLoginPostRequest(
          [void Function(AuthLoginPostRequestBuilder)? updates]) =>
      (AuthLoginPostRequestBuilder()..update(updates))._build();

  _$AuthLoginPostRequest._({required this.email, required this.password})
      : super._();
  @override
  AuthLoginPostRequest rebuild(
          void Function(AuthLoginPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthLoginPostRequestBuilder toBuilder() =>
      AuthLoginPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthLoginPostRequest &&
        email == other.email &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthLoginPostRequest')
          ..add('email', email)
          ..add('password', password))
        .toString();
  }
}

class AuthLoginPostRequestBuilder
    implements Builder<AuthLoginPostRequest, AuthLoginPostRequestBuilder> {
  _$AuthLoginPostRequest? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  AuthLoginPostRequestBuilder() {
    AuthLoginPostRequest._defaults(this);
  }

  AuthLoginPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthLoginPostRequest other) {
    _$v = other as _$AuthLoginPostRequest;
  }

  @override
  void update(void Function(AuthLoginPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthLoginPostRequest build() => _build();

  _$AuthLoginPostRequest _build() {
    final _$result = _$v ??
        _$AuthLoginPostRequest._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'AuthLoginPostRequest', 'email'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'AuthLoginPostRequest', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
