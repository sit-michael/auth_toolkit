library auth_toolkit;

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'src/core/export.dart';
import 'src/data/export.dart';
import 'src/domain/export.dart';

export 'src/domain/repository/auth_repository.dart';

class AuthRepositoryFactory {
  final String _clientId;
  final String _host;
  final String _bundleId;
  final void Function(Dio)? _addPinnedCertificates;

  AuthRepositoryFactory({
    required String clientId,
    required String host,
    required String bundleId,
    void Function(Dio)? addPinnedCertificates,
  })  : _bundleId = bundleId,
        _clientId = clientId,
        _host = host,
        _addPinnedCertificates = addPinnedCertificates;

  AuthRepository build() {
    final config = AuthConfig(
        host: _host, clientId: _clientId, redirectUri: _generateRedirectUri());
    final LocalDataSource local = _buildLocalDataSource();
    final RemoteDataSource remote = _buildRemoteDataSource(config);
    final PkceGenerator pkceGenerator = PkceGenerator();

    return AuthRepositoryImpl(
      config: config,
      local: local,
      remote: remote,
      pkceGenerator: pkceGenerator,
    );
  }

  String _generateRedirectUri() {
    String uri = '$_bundleId://';
    uri = uri.replaceAll('_', '-');
    return uri;
  }

  LocalDataSource _buildLocalDataSource() {
    const storage = FlutterSecureStorage();
    return LocalDataSourceImpl(storage: storage, bundleId: _bundleId);
  }

  RemoteDataSource _buildRemoteDataSource(AuthConfig config) {
    final dioOptions = BaseOptions(
      baseUrl: 'https://$_host',
      connectTimeout: 4000,
    );
    final dio = Dio(dioOptions);
    _addPinnedCertificates?.call(dio);

    return RemoteDataSourceImpl(config: config, dio: dio);
  }
}
