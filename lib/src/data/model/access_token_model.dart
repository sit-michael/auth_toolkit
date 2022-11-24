
import '../../core/export.dart';
import '../../domain/export.dart';

class AccessTokenModel extends DataModelBuilder<AccessToken> {
  final int expirationTime;
  final String authId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? salutation;

  AccessTokenModel.fromDomain(AccessToken domain)
      : expirationTime = domain.expirationTime.millisecondsSinceEpoch,
        authId = domain.authId,
        firstName = domain.firstName,
        lastName = domain.lastName,
        salutation = domain.salutation.toString(),
        email = domain.email;

  AccessTokenModel.fromJson(json)
      : expirationTime = json['exp'],
        authId = json['sub'],
        email = json['email'],
        firstName = json['given_name'],
        lastName = json['family_name'],
        salutation = json['salutation'];

  @override
  AccessToken toDomain() => AccessToken(
        authId: authId,
        email: email,
        expirationTime: DateTime.fromMillisecondsSinceEpoch(expirationTime),
        firstName: firstName,
        lastName: lastName,
        salutation: SalutationExtension.fromString(salutation ?? ''),
      );

  @override
  Map<String, dynamic> toJson() => {
        'exp': expirationTime,
        'sub': authId,
        'email': email,
        'given_name': firstName,
        'family_name': lastName,
        'salutation': salutation,
      };
}

extension AccessTokenModelExtension on AccessTokenModel {
  bool isTokenValid() {
    final bufferTimestamp = DateTime.now().add(const Duration(minutes: 1));
    final expirationLimit = bufferTimestamp.millisecondsSinceEpoch;
    return expirationLimit > expirationTime;
  }
}
