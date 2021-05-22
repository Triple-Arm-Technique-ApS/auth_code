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

class HandlingCallbackFailed extends AuthCodeWebViewState {}

class HandlingCallbackSucceeded extends AuthCodeWebViewState {
  final Credentials credentials;

  HandlingCallbackSucceeded(this.credentials);
}
