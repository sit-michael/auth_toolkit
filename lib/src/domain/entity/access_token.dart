import '../../core/model/salutation.dart';

class AccessToken {
  final DateTime expirationTime;
  final String authId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final Salutation salutation;

  AccessToken({
    required this.authId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.salutation,
    required this.expirationTime,
  });
}
