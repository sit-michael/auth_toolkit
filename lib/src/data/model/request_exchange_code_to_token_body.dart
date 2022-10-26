class RequestExchangeCodeToTokenBody {
  final String code;
  final String codeVerifier;
  final String clientId;
  final String redirectUri;

  RequestExchangeCodeToTokenBody({
    required this.code,
    required this.codeVerifier,
    required this.clientId,
    required this.redirectUri,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'code_verifier': codeVerifier,
        'client_id': clientId,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
      };
}
