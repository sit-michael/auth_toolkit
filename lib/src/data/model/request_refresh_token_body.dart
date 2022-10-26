class RequestRefreshTokenBody {
  final String clientId;
  final String grantType;
  final String refreshToken;

  RequestRefreshTokenBody.fromJson(Map<String, dynamic> json)
      : clientId = json['client_id'],
        grantType = json['grant_type'],
        refreshToken = json['refresh_token'];

  Map<String, dynamic> toJson() => {
        'client_id': clientId,
        'grant_type': grantType,
        'refresh_token': refreshToken,
      };
}
