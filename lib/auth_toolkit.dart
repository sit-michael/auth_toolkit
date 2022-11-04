library auth_toolkit;

import 'package:auth_toolkit/src/core/auth_config.dart';
import 'package:auth_toolkit/src/core/pkce/pkce_generator.dart';
import 'package:auth_toolkit/src/data/data_source/local_data_source.dart';
import 'package:auth_toolkit/src/data/data_source/remote_data_source.dart';
import 'package:auth_toolkit/src/data/repository/auth_repository_impl.dart';
import 'package:auth_toolkit/src/domain/repository/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

export './src/core/model/salutation.dart';
export './src/domain/repository/auth_repository.dart';
export './src/domain/entity/auth_user.dart';
export './src/domain/entity/view_type.dart';
export './src/presentation/auth_web_view.dart';

class AuthRepositoryFactory {
  final String _clientId;
  final String _host;
  String _bundleId;
  final void Function(Dio)? _addPinnedCertificates;

  AuthRepositoryFactory({
    required String clientId,
    required String host,
    String? bundleId,
    void Function(Dio)? addPinnedCertificates,
  })  : _bundleId = bundleId ?? '',
        _clientId = clientId,
        _host = host,
        _addPinnedCertificates = addPinnedCertificates;

  Future<AuthRepositoryFactory> setBundleIdFromPlatformInfo() async {
    WidgetsFlutterBinding.ensureInitialized();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _bundleId = packageInfo.packageName;
    return this;
  }

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
