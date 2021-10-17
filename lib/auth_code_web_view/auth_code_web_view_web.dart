import 'package:auth_code/web_util/external_browser_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AuthCodeWebView extends StatefulWidget {
  final Uri authorizationEndpoint;
  final bool Function(Uri uri) callbackHandler;
  final void Function() onCancelled;
  final void Function() onError;
  final Widget? child;
  const AuthCodeWebView({
    Key? key,
    required this.authorizationEndpoint,
    required this.callbackHandler,
    required this.onCancelled,
    required this.onError,
    this.child,
  }) : super(key: key);

  @override
  _AuthCodeWebViewState createState() => _AuthCodeWebViewState();
}

class _AuthCodeWebViewState extends State<AuthCodeWebView> {
  @override
  void initState() {
    super.initState();
    try {
      ExternalBrowserWindow.open(
        url: widget.authorizationEndpoint,
        title: 'Auth Code Simplified',
        onClosed: widget.onCancelled,
        onMessage: (event, close) {
          final data = event.data as Map<dynamic, dynamic>;
          if (data.containsKey('type')) {
            if (data['type'] == 'callback') {
              widget.callbackHandler(Uri.parse(data['url']));
              close();
            }
          }
        },
      );
    } catch (_) {
      widget.onError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
    );
  }
}
