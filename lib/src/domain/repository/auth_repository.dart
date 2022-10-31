import 'package:auth_toolkit/src/core/auth_config.dart';

import '../entity/auth_user.dart';
import '../entity/view_type.dart';

abstract class AuthRepository {
  AuthConfig get config;
  Future<Uri> generateAuthRequestUrl(ViewType viewType);
  Future<void> finishLogin(String code, String state);
  Future<AuthUser?> getUserInfo();
  Future<String?> getAccessToken();
  Future<void> logout();
}
