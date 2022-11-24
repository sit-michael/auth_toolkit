import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';

import '../domain/export.dart';

class AuthWebView extends StatefulWidget {
  static final _log = Logger('$AuthWebView');

  final ViewType type;
  final AuthRepository repository;
  final Widget? loadingScreen;

  final VoidCallback onSuccess;

  const AuthWebView({
    required this.type,
    required this.repository,
    required this.onSuccess,
    this.loadingScreen,
    Key? key,
  }) : super(key: key);

  @override
  State<AuthWebView> createState() => _AuthWebViewState();
}

class _AuthWebViewState extends State<AuthWebView> {
  bool _hideRedirect = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uri>(
      future: widget.repository.generateAuthRequestUrl(widget.type),
      builder: (context, snapshot) {
        if (!snapshot.hasData || _hideRedirect) {
          return widget.loadingScreen ??
              const Center(child: CircularProgressIndicator());
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
    try {
      if (_isRedirectUrl(url)) {
        setState(() {
          _hideRedirect = true;
        });
        AuthWebView._log.info('✅ Recognized redirect after login success');
        final code = url.queryParameters['code'];
        final state = url.queryParameters['state'];
        await widget.repository.finishLogin(code ?? '', state ?? '');
        widget.onSuccess();
        return;
      }
      AuthWebView._log.info('💥 Load error: $code, $url, $message');
    } finally {
      setState(() {
        _hideRedirect = false;
      });
    }
  }

  bool _isRedirectUrl(Uri url) {
    if (url.scheme != widget.repository.config.redirectUri.split(':')[0]) {
      return false;
    }
    if (url.host != widget.repository.config.redirectUri.split('/').last) {
      return false;
    }
    if (url.queryParameters['code'] == null) return false;
    if (url.queryParameters['state'] == null) return false;

    return true;
  }
}
