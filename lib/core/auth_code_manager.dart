import 'package:oauth2/oauth2.dart';

import 'identity_server.dart';

class AuthCodeManager {
  final Uri _authority;

  Client? _client;

  bool get _isInitialized => _grant != null;

  bool get hasCredentials => _client?.credentials != null;

  AuthorizationCodeGrant? _grant;

  late IdentityServer _identityServer = IdentityServer(_authority);

  AuthCodeManager(this._authority);

  Future<void> init(String clientId) async {
    if (!_identityServer.isInitialized) {
      await _identityServer.init();
    }
    final authorizationEndpoint =
        _identityServer.discoveryDocument!.authorizationEndpoint;
    final tokenEndpoint = _identityServer.discoveryDocument!.tokenEndpoint;
    _grant =
        AuthorizationCodeGrant(clientId, authorizationEndpoint, tokenEndpoint);
  }

  Uri createAuthorizeEndpoint({
    required List<String> scopes,
    required Uri redirectCallbackUrl,
  }) {
    if (!_identityServer.isInitialized) {
      throw Exception('init must be called prior to createAuthorizeEndpoint.');
    }
    return _grant!.getAuthorizationUrl(redirectCallbackUrl, scopes: scopes);
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

  bool get hasUserInfoEndpoint =>
      _identityServer.discoveryDocument?.userinfoEndpoint != null;
}
