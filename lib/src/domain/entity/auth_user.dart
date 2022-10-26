import 'package:auth_toolkit/src/domain/entity/access_token.dart';

import '../../core/model/salutation.dart';

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
