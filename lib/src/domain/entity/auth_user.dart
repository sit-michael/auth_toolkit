
import '../../core/export.dart';
import '../export.dart';

class AuthUser {
  final String authId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final Salutation salutation;

  AuthUser.fromToken(AccessToken tokenInfo)
      : authId = tokenInfo.authId,
        email = tokenInfo.email,
        firstName = tokenInfo.firstName,
        lastName = tokenInfo.lastName,
        salutation = tokenInfo.salutation;
}
