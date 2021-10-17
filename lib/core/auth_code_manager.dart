import 'package:auth_code/auth_code_options.dart';
import 'package:oauth2/oauth2.dart';

import 'identity_server.dart';

class AuthCodeManager {
  final AuthCodeOptions _options;
  Client? _client;

  bool get _isInitialized => _grant != null;

  bool get hasCredentials => _client?.credentials != null;

  AuthorizationCodeGrant? _grant;

  late IdentityServer _identityServer = IdentityServer(_options);

  AuthCodeManager(this._options);

  void init() {
    _grant = AuthorizationCodeGrant(
      _options.clientId,
      _options.authorizationEndpoint,
      _options.tokenEndpoint,
    );
  }

  Uri createAuthorizeEndpoint() {
    if (!_isInitialized) {
      init();
    }
    return _grant!.getAuthorizationUrl(
      _options.redirectUri,
      scopes: _options.scope,
    );
  }

  Future<Credentials> createCredentialsFromCallback(Uri callback) async {
    if (!_isInitialized) {
      throw Exception(
          'createAuthorizeEndpoint must be called prior to createCredentialsFromCallback.');
    }

    _client =
        await _grant!.handleAuthorizationResponse(callback.queryParameters);
    return _client!.credentials;
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    if (!hasCredentials) {
      throw Exception(
          'createCredentialsFromCallback must be called prior to getUserInfo.');
    }
    return await _identityServer.getUserInfo(_client!.credentials.accessToken);
  }

  bool get hasUserInfoEndpoint => _options.userInfoEndpoint != null;
}
