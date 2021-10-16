import 'dart:async';

import 'package:auth_code/auth_code_options.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:oauth2/oauth2.dart';

import '../../auth_code_view.dart';

part 'auth_code_web_view_event.dart';
part 'auth_code_web_view_state.dart';

class AuthCodeWebViewBloc
    extends Bloc<AuthCodeWebViewEvent, AuthCodeWebViewState> {
  final AuthCodeOptions options;
  final String clientId;
  final List<String> scopes;
  final Uri redirectCallbackUrl;
  final Uri Function(Uri)? authorizeEndpointTransformer;
  late final AuthCodeManager authCodeManager = AuthCodeManager(options);
  AuthCodeWebViewBloc({
    required this.options,
    required this.clientId,
    required this.scopes,
    required this.redirectCallbackUrl,
    this.authorizeEndpointTransformer,
  }) : super(AuthCodeWebViewInitial());

  @override
  Stream<AuthCodeWebViewState> mapEventToState(
    AuthCodeWebViewEvent event,
  ) async* {
    if (event is DiscoveryDocumentRequestedEvent) {
      yield FetchingDiscoveryDocument();
      try {
        await authCodeManager.init(clientId);
        final authorizationEndpoint = authCodeManager.createAuthorizeEndpoint(
          scopes: scopes,
          redirectCallbackUrl: redirectCallbackUrl,
        );
        if (authorizeEndpointTransformer != null) {
          yield FetchingDiscoveryDocumentSucceeded(
            authorizeEndpointTransformer!(authorizationEndpoint),
          );
        } else {
          yield FetchingDiscoveryDocumentSucceeded(authorizationEndpoint);
        }
      } catch (_) {
        yield FetchingDiscoveryDocumentFailed();
      }
    }
    if (event is HandleCallbackEvent) {
      try {
        yield HandlingCallback();
        final credentials = await authCodeManager
            .createCredentialsFromCallback(event.callbackurl);
        yield HandlingCallbackSucceeded(credentials);
      } on AuthorizationException catch (authException) {
        yield HandlingCallbackFailed(
          error: authException.error,
          description: authException.description,
          uri: authException.uri,
        );
      } on FormatException catch (formatException) {
        yield HandlingCallbackFailed(error: formatException.message);
      } catch (_) {
        yield HandlingCallbackFailed(error: 'Unexpected');
      }
    }
    if (event is UserInfoRequestedEvent) {
      if (authCodeManager.hasUserInfoEndpoint) {
        yield FetchingUserInfo();
        try {
          final user = await authCodeManager.getUserInfo();
          yield FetchingUserInfoSucceeded(user);
        } catch (_) {
          yield FetchingDiscoveryDocumentFailed();
        }
      }
    }
  }
}
