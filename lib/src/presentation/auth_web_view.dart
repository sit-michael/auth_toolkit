import 'package:auth_toolkit/auth_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';

class AuthWebView extends StatelessWidget {
  static final _log = Logger('$AuthWebView');

  final ViewType type;
  final AuthRepository repository;

  final VoidCallback onSuccess;

  const AuthWebView({
    required this.type,
    required this.repository,
    required this.onSuccess,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uri>(
      future: repository.generateAuthRequestUrl(type),
      builder: (context, snapshot) => InAppWebView(
        initialUrlRequest: URLRequest(url: snapshot.data),
        onLoadError: _loadError,
        onReceivedServerTrustAuthRequest: _onReceivedServerTrustAuthRequest,
      ),
    );
  }

  Future<ServerTrustAuthResponse?> _onReceivedServerTrustAuthRequest(
      InAppWebViewController controller, URLAuthenticationChallenge challenge) async {
    final trusted = challenge.protectionSpace.host.endsWith('kaufland.com');
    final action = trusted ? ServerTrustAuthResponseAction.PROCEED : ServerTrustAuthResponseAction.CANCEL;
    return ServerTrustAuthResponse(action: action);
  }

  Future<void> _loadError(InAppWebViewController controller, Uri? url, int code, String message) async {
    if (url == null) return;
    if (_isRedirectUrl(url)) {
      onSuccess();
    }
    _log.info('💥 Load error: $code, $url, $message');
  }

  bool _isRedirectUrl(Uri url) {
    if (url.scheme != repository.config.redirectUri.split(':')[0]) return false;
    if (url.host != repository.config.redirectUri.split('/').last) return false;
    if (url.queryParameters['code'] == null) return false;
    if (url.queryParameters['state'] == null) return false;

    return true;
  }
}
