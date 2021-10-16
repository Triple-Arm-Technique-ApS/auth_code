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

  Future<void> init(String clientId) async {
    _grant = AuthorizationCodeGrant(
      clientId,
      _options.authorizationEndpoint,
      _options.tokenEndpoint,
    );
  }

  Uri createAuthorizeEndpoint({
    required List<String> scopes,
    required Uri redirectCallbackUrl,
  }) {
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

  bool get hasUserInfoEndpoint => _options.userInfoEndpoint != null;
}
