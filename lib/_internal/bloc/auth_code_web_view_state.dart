part of 'auth_code_web_view_bloc.dart';

@immutable
abstract class AuthCodeWebViewState {}

class AuthCodeWebViewInitial extends AuthCodeWebViewState {}

class FetchingDiscoveryDocument extends AuthCodeWebViewState {}

class FetchingDiscoveryDocumentSucceeded extends AuthCodeWebViewState {
  final Uri authorizationEndpoint;

  FetchingDiscoveryDocumentSucceeded(this.authorizationEndpoint);
}

class FetchingDiscoveryDocumentFailed extends AuthCodeWebViewState {}

class FetchingUserInfo extends AuthCodeWebViewState {}

class FetchingUserInfoSucceeded extends AuthCodeWebViewState {
  final Map<String, dynamic> user;

  FetchingUserInfoSucceeded(this.user);
}

class FetchingUserInfoFailed extends AuthCodeWebViewState {}

class HandlingCallback extends AuthCodeWebViewState {}

class HandlingCallbackFailed extends AuthCodeWebViewState {
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

  HandlingCallbackFailed({
    required this.error,
    this.description,
    this.uri,
  });
}

class HandlingCallbackSucceeded extends AuthCodeWebViewState {
  final Credentials credentials;

  HandlingCallbackSucceeded(this.credentials);
}
