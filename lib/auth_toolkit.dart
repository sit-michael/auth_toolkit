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
  final String clientId;
  final String host;
  String _bundleId;
  final void Function(Dio)? addPinnedCertificates;

  String get bundleId => _bundleId;
  String get redirectUri => '$bundleId://';

  AuthRepositoryFactory({
    required this.clientId,
    required this.host,
    String? bundleId,
    this.addPinnedCertificates,
  }) : _bundleId = bundleId ?? '';

  Future<AuthRepositoryFactory> setBundleIdFromPlatformInfo() async {
    WidgetsFlutterBinding.ensureInitialized();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _bundleId = packageInfo.packageName;
    return this;
  }

  AuthRepository build() {
    final config =
        AuthConfig(host: host, clientId: clientId, redirectUri: redirectUri);
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

  LocalDataSource _buildLocalDataSource() {
    const storage = FlutterSecureStorage();
    return LocalDataSourceImpl(storage: storage, bundleId: bundleId);
  }

  RemoteDataSource _buildRemoteDataSource(AuthConfig config) {
    final dioOptions = BaseOptions(
      baseUrl: 'https://$host',
      connectTimeout: 4000,
    );
    final dio = Dio(dioOptions);
    addPinnedCertificates?.call(dio);

    return RemoteDataSourceImpl(config: config, dio: dio);
  }
}
