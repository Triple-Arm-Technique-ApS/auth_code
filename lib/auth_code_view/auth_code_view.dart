import 'package:auth_code/auth_code.dart';
import 'package:auth_code/auth_code_options.dart';
import 'package:auth_code/auth_code_web_view/index.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oauth2/oauth2.dart';

import 'bloc/auth_code_view_bloc.dart';

typedef AuthorizationEndpointTransformer = Uri Function(Uri);

/// Base class for errors that can occure while logging in.
abstract class AuthCodeViewError {}

/// Errror thrown from the browser eg. web virew
class BrowserError extends AuthCodeViewError {}

class UserInfoError extends AuthCodeViewError {}

class CallbackError extends AuthCodeViewError {
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

typedef OnCancelledCallback = void Function();

typedef OnCredentialsCallback = void Function(Credentials);

typedef OnAuthCodeErrorCallback = void Function(AuthCodeViewError);

typedef OnUserInfoCallback = void Function(Map<String, dynamic> user);

class AuthCodeView extends StatelessWidget {
  final OnCancelledCallback onCancelled;
  final OnAuthCodeErrorCallback onError;
  final OnCredentialsCallback onCredentials;
  final OnUserInfoCallback? onUserInfo;
  final Widget? child;
  final AuthorizationEndpointTransformer? authorizationEndpointTransformer;
  const AuthCodeView(
      {Key? key,
      required this.onCancelled,
      required this.onError,
      required this.onCredentials,
      this.child,
      this.onUserInfo,
      this.authorizationEndpointTransformer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthCodeOptions options =
        AuthCodeOptionsProvider.of(context).options!;
    return BlocProvider<AuthCodeViewBloc>(
      create: (_) =>
          AuthCodeViewBloc(options)..add(AuthCodeViewLoadedRequestedEvent()),
      child: BlocConsumer<AuthCodeViewBloc, AuthCodeViewState>(
        listener: (context, state) {
          if (state is FetchingUserInfoFailed) {
            onError(UserInfoError());
          }
          if (state is HandlingCallbackFailed) {
            // Check for Azure AD status code.
            if (state.description != null &&
                state.description!.contains('AADB2C90091')) {
              onCancelled();
            } else {
              onError(CallbackError(state.error, state.description, state.uri));
            }
          }

          if (state is HandlingCallbackSucceeded) {
            onCredentials(state.credentials);
            AuthCode.of(context).signIn(state.credentials);
            context.read<AuthCodeViewBloc>().add(UserInfoRequestedEvent());
          }

          if (state is FetchingUserInfoSucceeded) {
            onUserInfo?.call(state.user);
          }
        },
        builder: (context, state) {
          if (state is AuthCodeViewLoaded) {
            return AuthCodeWebView(
              authorizationEndpoint: authorizationEndpointTransformer == null
                  ? state.authorizationEndpoint
                  : authorizationEndpointTransformer!(
                      state.authorizationEndpoint),
              callbackHandler: (url) {
                if (matches(options.redirectUri, url)) {
                  context
                      .read<AuthCodeViewBloc>()
                      .add(HandleCallbackEvent(url));
                  return true;
                }
                return false;
              },
              onCancelled: onCancelled,
              onError: () => onError(BrowserError()),
              child: child,
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  bool matches(Uri uri, Uri other) {
    final one = uri.toString().split('?')[0].toLowerCase();
    final two = other.toString().split('?')[0].toLowerCase();
    return one == two;
  }
}
