// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_register_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthRegisterPostRequest extends AuthRegisterPostRequest {
  @override
  final String email;
  @override
  final String password;

  factory _$AuthRegisterPostRequest(
          [void Function(AuthRegisterPostRequestBuilder)? updates]) =>
      (AuthRegisterPostRequestBuilder()..update(updates))._build();

  _$AuthRegisterPostRequest._({required this.email, required this.password})
      : super._();
  @override
  AuthRegisterPostRequest rebuild(
          void Function(AuthRegisterPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthRegisterPostRequestBuilder toBuilder() =>
      AuthRegisterPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthRegisterPostRequest &&
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
    return (newBuiltValueToStringHelper(r'AuthRegisterPostRequest')
          ..add('email', email)
          ..add('password', password))
        .toString();
  }
}

class AuthRegisterPostRequestBuilder
    implements
        Builder<AuthRegisterPostRequest, AuthRegisterPostRequestBuilder> {
  _$AuthRegisterPostRequest? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  AuthRegisterPostRequestBuilder() {
    AuthRegisterPostRequest._defaults(this);
  }

  AuthRegisterPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthRegisterPostRequest other) {
    _$v = other as _$AuthRegisterPostRequest;
  }

  @override
  void update(void Function(AuthRegisterPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthRegisterPostRequest build() => _build();

  _$AuthRegisterPostRequest _build() {
    final _$result = _$v ??
        _$AuthRegisterPostRequest._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'AuthRegisterPostRequest', 'email'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'AuthRegisterPostRequest', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
