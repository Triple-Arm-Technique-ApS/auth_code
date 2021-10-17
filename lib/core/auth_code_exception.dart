class AuthCodeException implements Exception {
  final String message;
  AuthCodeException({
    required this.message,
  });
}
