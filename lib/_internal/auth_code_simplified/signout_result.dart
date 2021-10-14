class SignOutResult {
  final bool cancelled;
  final bool successful;
  final bool failed;

  SignOutResult._(this.cancelled, this.successful, this.failed);

  factory SignOutResult.cancelled() => SignOutResult._(true, false, false);

  factory SignOutResult.successful() => SignOutResult._(false, true, false);

  factory SignOutResult.failed() => SignOutResult._(false, false, true);
}
