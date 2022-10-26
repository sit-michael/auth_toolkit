import 'package:auth_toolkit/src/core/pkce/pkce_generator.dart';
import 'package:auth_toolkit/src/data/model/request_exchange_code_to_token_body.dart';
import 'package:dio/dio.dart';

import '../../core/auth_config.dart';
import '../model/response_token_body.dart';

abstract class RemoteDataSource {
  Uri generateAuthRequestUrl(String viewType, String state,
      PkceEncoding encoding, String codeChallenge);
  Future<ResponseTokenBody?> loginWithToken(String code, String codeVerifier);
  Future<ResponseTokenBody?> refreshToken(String token);
  Future<void> logout(String accessToken);
}

class RemoteDataSourceImpl extends RemoteDataSource {
  final Dio _dio;
  final AuthConfig _config;

  RemoteDataSourceImpl({
    required Dio dio,
    required AuthConfig config,
  })  : _config = config,
        _dio = dio;

  @override
  Future<ResponseTokenBody?> loginWithToken(
      String code, String codeVerifier) async {
    const route = '/token-srv/token';
    final body = RequestExchangeCodeToTokenBody(
      clientId: _config.clientId,
      code: code,
      codeVerifier: codeVerifier,
      redirectUri: _config.redirectUri,
    ).toJson();

    final response = await _dio.post(route, data: body);

    if (response.data == null) return null;
    return ResponseTokenBody.fromJson(response.data);
  }

  @override
  Future<void> logout(String accessToken) async {
    try {
      const route = '/session/end_session';

      final body = {
        'access_token_hint': accessToken,
        'post_logout_redirect_uri': _config.redirectUri,
      };

      await _dio.post(
        route,
        queryParameters: body,
      );
    } on DioError catch (e) {
      if (e.response?.statusCode == 302) return;
      rethrow;
    }
  }

  @override
  Future<ResponseTokenBody?> refreshToken(String token) async {
    const route = '/token-srv/token';

    final body = {
      'client_id': _config.clientId,
      'grant_type': 'refresh_token',
      'refresh_token': token,
    };

    final response = await _dio.post(
      route,
      data: body,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (response.data == null) return null;
    return ResponseTokenBody.fromJson(response.data);
  }

  @override
  Uri generateAuthRequestUrl(String viewType, String state,
      PkceEncoding encoding, String codeChallenge) {
    return Uri(
      scheme: 'https',
      host: _config.host,
      path: _config.authPath,
      queryParameters: <String, String>{
        'client_id': _config.clientId,
        'redirect_uri': _config.redirectUri,
        'view_type': viewType,
        'response_type': 'code',
        'preferredStore': 'DE0000',
        'scope': 'profile openid offline_access identities',
        'state': state,
        'code_challenge': codeChallenge,
        'code_challenge_method': encoding.name,
      },
    );
  }
}
