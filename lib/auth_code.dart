library auth_code;

import 'dart:async';

import 'package:auth_code/sign_out_on_identity_provider/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:oauth2/oauth2.dart';

import 'auth_code_options.dart';

export 'auth_code_view/auth_code_view.dart';

class AuthCodeNotifier extends ChangeNotifier {
  Credentials? _credentials;
  StreamSubscription? _subscription;

  final AuthCodeOptions options;
  final VoidCallback signedOut;
  AuthCodeNotifier(
    this.options,
    this.signedOut,
  );

  bool get authenticated => _credentials != null;

  void signIn(Credentials client) {
    _credentials = client;
    notifyListeners();
    _listen();
  }

  Uri? _buildEndSessionEndpoint() {
    if (_credentials?.idToken != null) {
      return options.endSessionEndpoint?.replace(
        queryParameters: Map<String, String>.from(
            options.endSessionEndpoint!.queryParameters)
          ..addAll(
            {
              'token_hint': _credentials!.idToken!,
            },
          ),
      );
    } else {
      return options.endSessionEndpoint;
    }
  }

  void signOut() {
    final endSessionEndpoint = _buildEndSessionEndpoint();
    if (endSessionEndpoint != null) {
      signOutOnIdentityProvider(
        endSessionEndpoint: endSessionEndpoint,
        redirectCallback: options.redirectUri,
        onComplete: () {
          _subscription?.cancel();
          _credentials = null;
          notifyListeners();
        },
        onCancelled: () {},
        onFailed: () {},
      );
    } else {
      _subscription?.cancel();
      _credentials = null;
      notifyListeners();
    }
  }

  void _listen() {
    _subscription?.cancel();
    _subscription = Stream.periodic(const Duration(seconds: 5)).listen(
      (_) async {
        if (_credentials != null) {
          if (_credentials!.isExpired) {
            await _attemptToRefreshCredentials();
          }
        } else {
          await Future.delayed(
            const Duration(seconds: 10),
          );
        }
      },
    );
  }

  Future _attemptToRefreshCredentials() async {
    if (_credentials!.canRefresh) {
      try {
        _credentials = await _credentials!.refresh();
      } on FormatException catch (e) {
        /// Invalid response from the server.
        _credentials = null;
      } on AuthorizationException catch (e) {
        /// Refresing credentials failed
        _credentials = null;
      } on Exception catch (e) {
        /// Unexpected failure.
        _credentials = null;
      }
    }

    notifyListeners();
  }
}

class AuthCode extends InheritedNotifier<AuthCodeNotifier> {
  AuthCode({
    required AuthCodeOptions options,
    required Widget child,
    required VoidCallback signedOut,
    Key? key,
  }) : super(
          key: key,
          notifier: AuthCodeNotifier(
            options,
            signedOut,
          ),
          child: child,
        );

  static AuthCodeNotifier of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthCode>()!.notifier!;
}
