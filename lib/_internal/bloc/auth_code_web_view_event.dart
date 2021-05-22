part of 'auth_code_web_view_bloc.dart';

@immutable
abstract class AuthCodeWebViewEvent {}

class DiscoveryDocumentRequestedEvent extends AuthCodeWebViewEvent {}

class UserInfoRequestedEvent extends AuthCodeWebViewEvent {}

class HandleCallbackEvent extends AuthCodeWebViewEvent {
  final Uri callbackurl;

  HandleCallbackEvent(this.callbackurl);
}
