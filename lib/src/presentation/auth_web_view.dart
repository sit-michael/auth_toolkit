
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';

import '../domain/export.dart';


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
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return InAppWebView(
          initialUrlRequest: URLRequest(url: snapshot.data),
          onLoadError: _loadError,
          onReceivedServerTrustAuthRequest: _onReceivedServerTrustAuthRequest,
        );
      },
    );
  }

  Future<ServerTrustAuthResponse?> _onReceivedServerTrustAuthRequest(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge) async {
    final trusted = challenge.protectionSpace.host.endsWith('kaufland.com');
    final action = trusted
        ? ServerTrustAuthResponseAction.PROCEED
        : ServerTrustAuthResponseAction.CANCEL;
    return ServerTrustAuthResponse(action: action);
  }

  Future<void> _loadError(InAppWebViewController controller, Uri? url, int code,
      String message) async {
    if (url == null) return;
    if (_isRedirectUrl(url)) {
      _log.info('✅ Recognized redirect after login success');
      final code = url.queryParameters['code'];
      final state = url.queryParameters['state'];
      await repository.finishLogin(code ?? '', state ?? '');
      onSuccess();
      return;
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
