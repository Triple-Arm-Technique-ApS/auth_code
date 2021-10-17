import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'core/discovery_document.dart';

class AuthCodeOptions {
  /// [clientId] is the OAuth 2.0 Client Identifier valid at the Authorization Server.
  final String clientId;

  /// [redirectUri] is the redirection URI to which the response will be sent.
  final Uri redirectUri;

  /// The [scope] requested by the client.
  final List<String> scope;

  /// The OAuth 2.0 authorisation endpoint URL.
  final Uri authorizationEndpoint;

  /// REQUIRED IF OpenID Connect Provider supports OpenID Connect Session Management and
  /// is a URL at the OP to which an RP can perform a redirect to request that the End-User be logged out at the OP.
  final Uri? endSessionEndpoint;

  /// The OpenID Connect UserInfo endpoint URL.
  final Uri? userInfoEndpoint;

  /// The OAuth 2.0 Token_endpoint URL.
  /// This is REQUIRED unless only the Implicit Flow is used.
  final Uri tokenEndpoint;

  AuthCodeOptions(
    this.clientId,
    this.redirectUri,
    this.scope,
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

  factory AuthCodeOptionsNotifier.fromWellKnownConfiguration({
    required String clientId,
    required Uri redirectUri,
    required List<String> scope,
    required Uri wellKnownConfigurationEndpoint,
  }) {
    return AuthCodeOptionsNotifier._()
      .._fetch(
        clientId: clientId,
        redirectUri: redirectUri,
        scope: scope,
        wellKnownConfigurationEndpoint: wellKnownConfigurationEndpoint,
      );
  }

  factory AuthCodeOptionsNotifier.fromValues({
    required String clientId,
    required Uri redirectUri,
    required List<String> scope,
    required Uri authorizationEndpoint,
    required Uri tokenEndpoint,
    Uri? endSessionEndpoint,
    Uri? userInfoEndpoint,
  }) =>
      AuthCodeOptionsNotifier._()
        .._load(
          clientId: clientId,
          redirectUri: redirectUri,
          scope: scope,
          authorizationEndpoint: authorizationEndpoint,
          tokenEndpoint: tokenEndpoint,
          endSessionEndpoint: endSessionEndpoint,
          userInfoEndpoint: userInfoEndpoint,
        );

  Future _fetch({
    required String clientId,
    required Uri redirectUri,
    required List<String> scope,
    required Uri wellKnownConfigurationEndpoint,
  }) async {
    final document =
        await DiscoveryDocument.fromAuthority(wellKnownConfigurationEndpoint);
    _options = AuthCodeOptions(
      clientId,
      redirectUri,
      scope,
      document.authorizationEndpoint,
      document.endSessionEndpoint,
      document.userinfoEndpoint,
      document.tokenEndpoint,
    );
    notifyListeners();
  }

  void _load({
    required String clientId,
    required Uri redirectUri,
    required List<String> scope,
    required Uri authorizationEndpoint,
    Uri? endSessionEndpoint,
    Uri? userInfoEndpoint,
    required Uri tokenEndpoint,
  }) {
    _options = AuthCodeOptions(
      clientId,
      redirectUri,
      scope,
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
    required String clientId,
    required Uri redirectUri,
    required List<String> scope,
    required Uri wellKnownConfigurationEndpoint,
    required Widget child,
    Key? key,
  }) {
    return AuthCodeOptionsProvider._(
      notifier: AuthCodeOptionsNotifier.fromWellKnownConfiguration(
        clientId: clientId,
        redirectUri: redirectUri,
        scope: scope,
        wellKnownConfigurationEndpoint: wellKnownConfigurationEndpoint,
      ),
      child: child,
      key: key,
    );
  }
  factory AuthCodeOptionsProvider.fromValues({
    required String clientId,
    required Uri redirectUri,
    required List<String> scope,
    required Uri authorizationEndpoint,
    required Uri tokenEndpoint,
    required Widget child,
    Uri? endSessionEndpoint,
    Uri? userInfoEndpoint,
    Key? key,
  }) {
    return AuthCodeOptionsProvider._(
      notifier: AuthCodeOptionsNotifier.fromValues(
        clientId: clientId,
        redirectUri: redirectUri,
        scope: scope,
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
