class AuthConfig {
  final String authPath = '/authz-srv/authz';
  final String tokenPath = '/token-srv/token';
  final String redirectUri;
  final String host;
  final String clientId;

  const AuthConfig({
    required this.host,
    required this.clientId,
    required this.redirectUri,
  });
}
