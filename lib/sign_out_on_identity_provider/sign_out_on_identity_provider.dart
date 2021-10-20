import 'package:flutter/foundation.dart';

/// [signout] begins a sign out flow and does so diffrently on web than other platforms
/// on web a requests is made to the well known configuration endpoint of the
/// identity provider using the [authority] url,
/// then the end_session_endpoint is read and an external browser window is opened
/// directing the user to the end session page of the identity provider, the page will
/// then redirect the user back to the callback page that will be closed upon load and invoke
/// [onComplete] if the flow fails [onFailed] is called and if the user closes the external window
/// before the callback uri is called [onCancelled] is called.
/// On other platforms the [onComplete] will get invoked right away since the web view
/// does not contain any cookies
void signOutOnIdentityProvider({
  required Uri endSessionEndpoint,
  required Uri redirectCallback,
  required VoidCallback onComplete,
  required VoidCallback onCancelled,
  required VoidCallback onFailed,
  String? idToken = null,
}) {
  onComplete();
}
