

import '../../core/export.dart';
import '../export.dart';

abstract class AuthRepository {
  AuthConfig get config;
  Future<Uri> generateAuthRequestUrl(ViewType viewType);
  Future<void> finishLogin(String code, String state);
  Future<AuthUser?> getUserInfo();
  Future<String?> getAccessToken();
  Future<void> logout();
}
