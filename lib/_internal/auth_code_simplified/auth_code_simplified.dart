import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthCodeSimplified extends StatelessWidget {
  final Uri authorizationEndpoint;
  final bool Function(Uri uri) callbackHandler;
  final void Function() onCancelled;
  final void Function() onError;
  final Widget? child;
  const AuthCodeSimplified(
      {Key? key,
      required this.authorizationEndpoint,
      required this.callbackHandler,
      required this.onCancelled,
      required this.onError,
      this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onCancelled,
          )
        ],
      ),
      body: WebView(
        onWebViewCreated: (controller) async {
          await controller.clearCache();
          final cookieManager = CookieManager();
          await cookieManager.clearCookies();
        },
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: authorizationEndpoint.toString(),
        navigationDelegate: (NavigationRequest request) {
          if (callbackHandler(Uri.parse(request.url))) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onWebResourceError: (error) {
          if (error.errorCode != 102) {
            onError();
          }
        },
      ),
    );
  }
}
