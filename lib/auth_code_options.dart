import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'core/discovery_document.dart';

class AuthCodeOptions {
  final Uri authorizationEndpoint;
  final Uri? endSessionEndpoint;
  final Uri? userInfoEndpoint;
  final Uri tokenEndpoint;

  AuthCodeOptions(
    this.authorizationEndpoint,
    this.endSessionEndpoint,
    this.userInfoEndpoint,
    this.tokenEndpoint,
  );
}

class AuthCodeOptionsNotifier extends ChangeNotifier {
  AuthCodeOptions? _options;

  get options => _options;

  get initializing => _options == null;

  AuthCodeOptionsNotifier._();

  factory AuthCodeOptionsNotifier.fromWellKnownConfiguration(
      Uri wellKnownConfigurationEndpoint) {
    return AuthCodeOptionsNotifier._().._fetch(wellKnownConfigurationEndpoint);
  }

  factory AuthCodeOptionsNotifier.fromValues({
    required Uri authorizationEndpoint,
    required Uri tokenEndpoint,
    Uri? endSessionEndpoint,
    Uri? userInfoEndpoint,
  }) =>
      AuthCodeOptionsNotifier._()
        .._load(
          authorizationEndpoint: authorizationEndpoint,
          tokenEndpoint: tokenEndpoint,
          endSessionEndpoint: endSessionEndpoint,
          userInfoEndpoint: userInfoEndpoint,
        );

  Future _fetch(Uri wellKnownConfigurationEndpoint) async {
    final document =
        await DiscoveryDocument.fromAuthority(wellKnownConfigurationEndpoint);
    _options = AuthCodeOptions(
      document.authorizationEndpoint,
      document.endSessionEndpoint,
      document.endSessionEndpoint,
      document.tokenEndpoint,
    );
    notifyListeners();
  }

  void _load({
    required Uri authorizationEndpoint,
    Uri? endSessionEndpoint,
    Uri? userInfoEndpoint,
    required Uri tokenEndpoint,
  }) {
    _options = AuthCodeOptions(
      authorizationEndpoint,
      endSessionEndpoint,
      userInfoEndpoint,
      tokenEndpoint,
    );
    notifyListeners();
  }
}

class AuthCodeOptionsProvider
    extends InheritedNotifier<AuthCodeOptionsNotifier> {
  AuthCodeOptionsProvider._({
    required AuthCodeOptionsNotifier notifier,
    required Widget child,
    Key? key,
  }) : super(
          key: key,
          notifier: notifier,
          child: child,
        );

  factory AuthCodeOptionsProvider.fromWellKnownConfiguration({
    required Uri wellKnownConfigurationEndpoint,
    required Widget child,
    Key? key,
  }) {
    return AuthCodeOptionsProvider._(
      notifier: AuthCodeOptionsNotifier.fromWellKnownConfiguration(
          wellKnownConfigurationEndpoint),
      child: child,
      key: key,
    );
  }
  factory AuthCodeOptionsProvider.fromValues({
    required Uri authorizationEndpoint,
    required Uri tokenEndpoint,
    required Widget child,
    Uri? endSessionEndpoint,
    Uri? userInfoEndpoint,
    Key? key,
  }) {
    return AuthCodeOptionsProvider._(
      notifier: AuthCodeOptionsNotifier.fromValues(
        authorizationEndpoint: authorizationEndpoint,
        tokenEndpoint: tokenEndpoint,
        endSessionEndpoint: endSessionEndpoint,
        userInfoEndpoint: userInfoEndpoint,
      ),
      child: child,
      key: key,
    );
  }
  static AuthCodeOptionsNotifier of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AuthCodeOptionsProvider>()!
      .notifier!;
}
