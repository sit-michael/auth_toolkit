import 'package:auth_toolkit/src/data/data_source/local_data_source.dart';
import 'package:auth_toolkit/src/data/data_source/remote_data_source.dart';
import 'package:auth_toolkit/src/data/model/access_token_model.dart';
import 'package:auth_toolkit/src/domain/entity/auth_user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logging/logging.dart';

import '../../core/pkce/pkce_generator.dart';
import '../../core/random_string_generator.dart';
import '../../domain/entity/view_type.dart';
import '../../domain/repository/auth_repository.dart';
import '../model/response_token_body.dart';

class AuthRepositoryImpl extends AuthRepository {
  final Logger _log = Logger('$AuthRepository');
  final LocalDataSource _local;
  final RemoteDataSource _remote;
  final PkceGenerator _pkceGenerator;

  AuthRepositoryImpl(
      {required LocalDataSource local,
      required RemoteDataSource remote,
      required PkceGenerator pkceGenerator})
      : _local = local,
        _remote = remote,
        _pkceGenerator = pkceGenerator;

  @override
  Future<Uri> generateAuthRequestUrl(ViewType viewType) async {
    final state = RandomStringGenerator().generateRandom(128);
    final pkcePair = _pkceGenerator.build();
    await _storeFlowVariables(state, pkcePair.codeVerifier);

    final url = _remote.generateAuthRequestUrl(
      viewType.name,
      state,
      _pkceGenerator.encoding,
      pkcePair.codeChallenge,
    );
    _log.info('✅ Generated Auth Url: $url');
    return url;
  }

  Future<void> _storeFlowVariables(String state, String verifier) async {
    await _local.putPkceState(state);
    await _local.putPkceVerifier(state, verifier);
  }

  Future<void> _cleanFlowVariables(String state) async {
    await _local.deletePkceState();
    await _local.deletePkceVerifier(state);
    _log.info('✅ Wiped Flow Variables');
  }

  @override
  Future<void> finishLogin(String code, String state) async {
    if (await _checkState(state)) {
      await _performCodeExchange(code, state);
      _log.info('✅ Finished Login Flow');
      await _cleanFlowVariables(state);
    }
    _resetState();
  }

  Future<String> _getVerifier(String state) async {
    final verifier = await _local.getPkceVerifier(state);
    if (verifier == null) return ''; //TODO: Throw Data Error instead
    return verifier;
  }

  @override
  Future<String?> getAccessToken() async {
    String? localToken = await _getValidLocalAccessToken();
    if (localToken != null) return localToken;
    return await _requestNewValidAccessToken();
  }

  @override
  Future<AuthUser?> getUserInfo() async {
    final result = await _local.getAuthInfo();
    if (result == null) {
      _log.warning('💥 Requested user info not found');
      return null;
    }
    final tokenInfo = result.toDomain();
    _log.info('✅ Returning requested user info');
    return AuthUser.fromToken(tokenInfo);
  }

  @override
  Future<void> logout() async {
    final accessToken = await getAccessToken();
    if (accessToken != null) {
      await _remote.logout(accessToken);
      _log.info('✅ Logout performed');
    }
    await _clearLocalDataSource();
    _log.info('✅ Wiped local Storage');
  }

  Future<void> _storeData(ResponseTokenBody? data) async {
    if (data == null) return; //TODO: Throw Data Error instead
    await _storeAccessToken(data.accessToken);
    await _storeRefreshToken(data.refreshToken);
    _log.info('🔑 Stored access and refresh token');
  }

  Future<void> _storeAccessToken(String accessToken) async {
    await _storeAccessTokenInfo(accessToken);
    await _local.putAccessToken(accessToken);
  }

  Future<void> _storeRefreshToken(String? refreshToken) async {
    if (refreshToken != null) {
      await _local.putRefreshToken(refreshToken);
    }
  }

  Future<String?> _getValidLocalAccessToken() async {
    if (!await _isLocalAccessTokenValid()) {
      _log.warning('🔑 Local access token is not valid anymore');
      return null;
    }
    final token = await _local.getAccessToken();
    return token;
  }

  Future<String?> _requestNewValidAccessToken() async {
    final refreshToken = await _local.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _log.warning('💥 Refresh Token not available');
      //TODO: Throw Data Error instead
      return null;
    }

    final response = await _remote.refreshToken(refreshToken);
    _log.info('✅ Refreshed access token');
    await _storeData(response);
    return response?.accessToken;
  }

  Future<bool> _isLocalAccessTokenValid() async {
    final tokenInfo = (await _local.getAuthInfo());
    if (tokenInfo == null) {
      _log.warning('💥 No validation data for access token available');
      return false;
    }
    return tokenInfo.isTokenValid();
  }

  Future<void> _storeAccessTokenInfo(String accessToken) async {
    final json = JwtDecoder.decode(accessToken);
    final tokenInfo = AccessTokenModel.fromJson(json);
    _local.putAuthInfo(tokenInfo);
  }

  Future<void> _clearLocalDataSource() async {
    await _local.deleteAccessToken();
    await _local.deleteAuthInfo();
    await _local.deleteRefreshToken();
  }

  Future<bool> _checkState(String state) async {
    final localState = await _local.getPkceState();
    return localState == state;
  }

  Future<void> _resetState() async => await _local.deletePkceState();

  Future<void> _performCodeExchange(String code, String state) async {
    final verifier = await _getVerifier(state);
    final response = await _remote.loginWithToken(code, verifier);
    await _storeData(response);
  }
}
