part of 'auth_code_view_bloc.dart';

@immutable
abstract class AuthCodeViewEvent {}

class AuthCodeViewLoadedRequestedEvent extends AuthCodeViewEvent {}

class UserInfoRequestedEvent extends AuthCodeViewEvent {}

class HandleCallbackEvent extends AuthCodeViewEvent {
  final Uri callbackurl;

  HandleCallbackEvent(this.callbackurl);
}
