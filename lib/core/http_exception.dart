class HttpException implements Exception {
  final int statusCode;
  final String? reasonPhrase;
  final String body;

  HttpException(this.statusCode, this.reasonPhrase, this.body);
}
