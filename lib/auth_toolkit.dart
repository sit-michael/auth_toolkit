library auth_toolkit;

import 'package:auth_toolkit/src/core/auth_config.dart';
import 'package:auth_toolkit/src/core/pkce/pkce_generator.dart';
import 'package:auth_toolkit/src/data/data_source/local_data_source.dart';
import 'package:auth_toolkit/src/data/data_source/remote_data_source.dart';
import 'package:auth_toolkit/src/data/repository/auth_repository_impl.dart';
import 'package:auth_toolkit/src/domain/repository/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

export './src/core/model/salutation.dart';
export './src/domain/repository/auth_repository.dart';
export './src/domain/entity/auth_user.dart';
export './src/domain/entity/view_type.dart';
export './src/presentation/auth_web_view.dart';

class AuthRepositoryFactory {
  final String clientId;
  final String host;
  final String bundleId;
  final void Function(Dio)? addPinnedCertificates;

  AuthRepositoryFactory({
    required this.clientId,
    required this.host,
    required this.bundleId,
    this.addPinnedCertificates,
  });

  AuthRepository build() {
    final config =
        AuthConfig(host: host, clientId: clientId, redirectUri: '$bundleId://');
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
