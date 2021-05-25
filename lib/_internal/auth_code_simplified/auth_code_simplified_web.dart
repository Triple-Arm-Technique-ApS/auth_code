import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ExternalBrowserWindow {
  final bool hasScrollbars;
  final bool isResizable;
  final bool hasStatusBar;
  final bool hasLocationbar;
  final bool hasToolbar;
  final bool hasMenubar;
  final int left;
  final int top;
  final int width;
  final int height;
  final void Function() onClosed;
  final Uri url;
  final String title;
  final bool center;
  final void Function(
    html.MessageEvent event,
    void Function() close,
  )? onMessage;
  ExternalBrowserWindow({
    this.hasScrollbars = false,
    this.isResizable = false,
    this.hasStatusBar = false,
    this.hasLocationbar = false,
    this.hasToolbar = false,
    this.hasMenubar = false,
    this.left = 300,
    this.top = 300,
    this.width = 420,
    this.height = 700,
    this.onMessage,
    this.center = true,
    required this.onClosed,
    required this.url,
    required this.title,
  });

  Future<void> open() async {
    String opt = options;
    if (center) {
      int? screenWidth = html.window.screen?.width;
      int? screenHeight = html.window.screen?.height;
      if (screenWidth != null && screenHeight != null) {
        double newLeft = (screenWidth - width) / 2;
        double newTop = (screenHeight - height) / 4;
        opt = _buildOptions(newLeft as int, newTop as int);
      }
    }
    final window = html.window.open(url.toString(), title, opt);
    StreamSubscription<html.MessageEvent>? subscription;
    bool skipEvent = false;
    if (onMessage != null) {
      subscription = html.window.onMessage.listen((event) {
        onMessage?.call(event, () {
          skipEvent = true;
          window.close();
        });
      });
    }
    await waitForClose(window);
    subscription?.cancel();
    if (!skipEvent) {
      onClosed();
    }
  }

  Future<void> waitForClose(html.WindowBase window) async {
    while (window.closed != null && !window.closed!) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  String _buildOptions(int left, int top) =>
      'scrollbars=${boolToYesOrNo(hasScrollbars)},resizable=${boolToYesOrNo(isResizable)},status=${boolToYesOrNo(hasStatusBar)},location=${boolToYesOrNo(hasLocationbar)},toolbar=${boolToYesOrNo(hasToolbar)},menubar=${boolToYesOrNo(hasMenubar)},width=$width,height=$height,left=$left,top=$top';
  String get options => _buildOptions(left, top);

  String boolToYesOrNo(bool value) => value ? 'yes' : 'no';

  factory ExternalBrowserWindow.open({
    bool hasScrollbars = false,
    bool isResizable = false,
    bool hasStatusBar = false,
    bool hasLocationbar = false,
    bool hasToolbar = false,
    bool hasMenubar = false,
    int left = 300,
    int top = 300,
    int width = 360,
    int height = 600,
    void Function(html.MessageEvent event, void Function() close)? onMessage,
    required void Function() onClosed,
    required Uri url,
    required String title,
  }) =>
      ExternalBrowserWindow(
        hasScrollbars: hasScrollbars,
        isResizable: isResizable,
        hasStatusBar: hasStatusBar,
        hasLocationbar: hasLocationbar,
        hasToolbar: hasToolbar,
        hasMenubar: hasMenubar,
        left: left,
        top: top,
        width: width,
        height: height,
        onClosed: onClosed,
        url: url,
        title: title,
        onMessage: onMessage,
      )..open();
}

class AuthCodeSimplified extends StatefulWidget {
  final Uri authorizationEndpoint;
  final bool Function(Uri uri) callbackHandler;
  final void Function() onCancelled;
  final void Function() onError;
  const AuthCodeSimplified({
    Key? key,
    required this.authorizationEndpoint,
    required this.callbackHandler,
    required this.onCancelled,
    required this.onError,
  }) : super(key: key);

  @override
  _AuthCodeSimplifiedState createState() => _AuthCodeSimplifiedState();
}

class _AuthCodeSimplifiedState extends State<AuthCodeSimplified> {
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
    return Scaffold();
  }
}
