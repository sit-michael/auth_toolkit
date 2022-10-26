class ResponseTokenBody {
  final String? tokenType;
  final String sub;
  final int expiresIn;
  final int? idTokenExpiresIn;
  final String? sid;
  final String accessToken;
  final String? idToken;
  final String? refreshToken;
  final String? state;
  final String? identityId;

  ResponseTokenBody.fromJson(Map<String, dynamic> json)
      : tokenType = json['token_type'],
        sub = json['sub'],
        expiresIn = json['expires_in'],
        idTokenExpiresIn = json['id_token_expires_in'],
        sid = json['sid'],
        accessToken = json['access_token'],
        idToken = json['id_token'],
        refreshToken = json['refresh_token'],
        state = json['state'],
        identityId = json['identity_td'];

  Map<String, dynamic> toJson() => {
        'token_type': tokenType,
        'sub': sub,
        'expires_in': expiresIn,
        'id_token_expires_in': idTokenExpiresIn,
        'sid': sid,
        'access_token': accessToken,
        'id_token': idToken,
        'refresh_token': refreshToken,
        'state': state,
        'identity_td': identityId,
      };
}
