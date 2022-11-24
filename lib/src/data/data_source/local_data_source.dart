import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../export.dart';

abstract class LocalDataSource {
  Future<AccessTokenModel?> getAuthInfo();
  Future<void> putAuthInfo(AccessTokenModel info);
  Future<void> deleteAuthInfo();

  Future<String?> getAccessToken();
  Future<void> putAccessToken(String token);
  Future<void> deleteAccessToken();

  Future<String?> getRefreshToken();
  Future<void> putRefreshToken(String token);
  Future<void> deleteRefreshToken();

  Future<String?> getPkceState();
  Future<void> putPkceState(String state);
  Future<void> deletePkceState();

  Future<String?> getPkceVerifier(String state);
  Future<void> putPkceVerifier(String state, String verifier);
  Future<void> deletePkceVerifier(String state);
}

class LocalDataSourceImpl extends LocalDataSource {
  final FlutterSecureStorage _storage;
  final String _bundleId;

  LocalDataSourceImpl(
      {required String bundleId, required FlutterSecureStorage storage})
      : _storage = storage,
        _bundleId = bundleId;

  String get _accessTokenModelKey => '_accessTokenModelKey_$_bundleId';
  String get _accessTokenKey => '_accessTokenKey_$_bundleId';
  String get _refreshTokenKey => '_refreshTokenKey_$_bundleId';
  String get _pkceStateKey => '_pkceStateKey_$_bundleId';
  String get _pkceVerifierKey => '_pkceVerifierKey_$_bundleId';

  @override
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  @override
  Future<void> putAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  @override
  Future<AccessTokenModel?> getAuthInfo() async {
    final result = await _storage.read(key: _accessTokenModelKey);
    if (result == null) return null;
    final json = jsonDecode(result);
    return AccessTokenModel.fromJson(json);
  }

  @override
  Future<void> putAuthInfo(AccessTokenModel info) async {
    await _storage.write(
        key: _accessTokenModelKey, value: jsonEncode(info.toJson()));
  }

  @override
  Future<void> deleteAuthInfo() async {
    await _storage.delete(key: _accessTokenModelKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> putRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  @override
  Future<String?> getPkceVerifier(String state) async {
    final key = _buildVerifierKey(state);
    return await _storage.read(key: key);
  }

  @override
  Future<void> putPkceVerifier(String state, String verifier) async {
    final key = _buildVerifierKey(state);
    await _storage.write(key: key, value: verifier);
  }

  @override
  Future<void> deletePkceVerifier(String state) async {
    final key = _buildVerifierKey(state);
    await _storage.delete(key: key);
  }

  String _buildVerifierKey(String state) => '${_pkceVerifierKey}_$state';

  @override
  Future<String?> getPkceState() async {
    return await _storage.read(key: _pkceStateKey);
  }

  @override
  Future<void> putPkceState(String state) async {
    await _storage.write(key: _pkceStateKey, value: state);
  }

  @override
  Future<void> deletePkceState() async {
    await _storage.delete(key: _pkceStateKey);
  }
}
