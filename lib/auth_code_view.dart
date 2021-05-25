library auth_code_view;

export 'core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oauth2/oauth2.dart';

import '_internal/auth_code_simplified/index.dart';
import '_internal/bloc/auth_code_web_view_bloc.dart';

/// Base class for errors that can occure while logging in.
abstract class AuthCodeWebViewError {}

/// Errror thrown from the browser eg. web virew
class BrowserError extends AuthCodeWebViewError {}

/// Was unable to get the discovery document and the [AuthCodeView] should be closed.
class DiscoveryDocumentError extends AuthCodeWebViewError {}

class UserInfoError extends AuthCodeWebViewError {}

class CallbackError extends AuthCodeWebViewError {
  /// The name of the error.
  ///
  /// Possible names are enumerated in [the spec][].
  ///
  /// [the spec]: http://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-5.2
  final String error;

  /// The description of the error, provided by the server.
  ///
  /// May be `null` if the server provided no description.
  final String? description;

  /// A URL for a page that describes the error in more detail, provided by the
  /// server.
  ///
  /// May be `null` if the server provided no URL.
  final Uri? uri;

  CallbackError(this.error, this.description, this.uri);
}

class AuthCodeView extends StatelessWidget {
  final Uri authority;
  final String clientId;
  final List<String> scopes;
  final Uri redirectUri;
  final void Function() onCancelled;
  final void Function(AuthCodeWebViewError) onError;
  final void Function(Credentials credentials) onCredentials;
  final void Function(Map<String, dynamic> user)? onUserInfo;
  const AuthCodeView({
    Key? key,
    required this.authority,
    required this.clientId,
    required this.scopes,
    required this.redirectUri,
    required this.onCancelled,
    required this.onError,
    required this.onCredentials,
    this.onUserInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCodeWebViewBloc>(
      create: (_) => AuthCodeWebViewBloc(
        authority: authority,
        clientId: clientId,
        scopes: scopes,
        redirectCallbackUrl: redirectUri,
      )..add(DiscoveryDocumentRequestedEvent()),
      child: BlocConsumer<AuthCodeWebViewBloc, AuthCodeWebViewState>(
        listener: (context, state) {
          if (state is FetchingUserInfoFailed) {
            onError(UserInfoError());
          }

          if (state is FetchingDiscoveryDocumentFailed) {
            onError(DiscoveryDocumentError());
          }

          if (state is HandlingCallbackFailed) {
            onError(CallbackError(state.error, state.description, state.uri));
          }

          if (state is HandlingCallbackSucceeded) {
            onCredentials(state.credentials);
            context.read<AuthCodeWebViewBloc>().add(UserInfoRequestedEvent());
          }

          if (state is FetchingUserInfoSucceeded) {
            onUserInfo?.call(state.user);
          }
        },
        builder: (context, state) {
          if (state is FetchingDiscoveryDocumentSucceeded) {
            return AuthCodeSimplified(
              authorizationEndpoint: state.authorizationEndpoint,
              callbackHandler: (url) {
                if (matches(redirectUri, url)) {
                  context
                      .read<AuthCodeWebViewBloc>()
                      .add(HandleCallbackEvent(url));
                  return true;
                }
                return false;
              },
              onCancelled: onCancelled,
              onError: () => onError(BrowserError()),
            );
          }
          return Container();
        },
      ),
    );
  }

  bool matches(Uri uri, Uri other) {
    final one = uri.toString().split('?')[0].toLowerCase();
    final two = uri.toString().split('?')[0].toLowerCase();
    return one == two;
  }
}