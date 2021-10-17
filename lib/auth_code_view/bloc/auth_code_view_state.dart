part of 'auth_code_view_bloc.dart';

@immutable
abstract class AuthCodeViewState {}

class AuthCodeViewInitial extends AuthCodeViewState {}

class AuthCodeViewLoaded extends AuthCodeViewState {
  final Uri authorizationEndpoint;
  AuthCodeViewLoaded(this.authorizationEndpoint);
}

class FetchingUserInfo extends AuthCodeViewState {}

class FetchingUserInfoSucceeded extends AuthCodeViewState {
  final Map<String, dynamic> user;

  FetchingUserInfoSucceeded(this.user);
}

class FetchingUserInfoFailed extends AuthCodeViewState {}

class HandlingCallback extends AuthCodeViewState {}

class HandlingCallbackFailed extends AuthCodeViewState {
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

class HandlingCallbackSucceeded extends AuthCodeViewState {
  final Credentials credentials;

  HandlingCallbackSucceeded(this.credentials);
}
