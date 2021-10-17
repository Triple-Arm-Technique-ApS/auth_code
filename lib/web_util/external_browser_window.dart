import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

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
    final window = html.window.open(url.toString(), title, options);
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

  math.Point<int> getPoint() {
    if (center) {
      int? screenLeft = html.window.screenLeft ?? html.window.screenX;
      int? screenTop = html.window.screenTop ?? html.window.screenY;
      int? screenWidth = html.window.innerWidth ??
          html.document.documentElement?.clientWidth ??
          html.window.screen?.width;
      int? screenHeight = html.window.innerHeight ??
          html.document.documentElement?.clientHeight ??
          html.window.screen?.height;

      if (screenLeft != null &&
          screenTop != null &&
          screenWidth != null &&
          screenHeight != null) {
        final left = (screenWidth - width) / 2;
        final top = (screenHeight - height) / 2;
        return math.Point<int>(left.toInt(), top.toInt());
      }
    }
    return math.Point(left, top);
  }

  String _buildOptions(int left, int top) =>
      'scrollbars=${boolToYesOrNo(hasScrollbars)},resizable=${boolToYesOrNo(isResizable)},status=${boolToYesOrNo(hasStatusBar)},location=${boolToYesOrNo(hasLocationbar)},toolbar=${boolToYesOrNo(hasToolbar)},menubar=${boolToYesOrNo(hasMenubar)},width=$width,height=$height,left=$left,top=$top';

  String get options {
    final point = getPoint();
    return _buildOptions(point.x, point.y);
  }

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
