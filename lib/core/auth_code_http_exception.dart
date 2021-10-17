import 'auth_code_exception.dart';

class AuthCodeHttpException extends AuthCodeException {
  final int statusCode;
  final String? reasonPhrase;
  final String body;
  AuthCodeHttpException({
    required this.statusCode,
    required this.reasonPhrase,
    required this.body,
  }) : super(
          message:
              'HTTP request failed with status : $statusCode $reasonPhrase.',
        );
}
