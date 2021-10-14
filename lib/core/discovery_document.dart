class DiscoveryDocument {
  final Uri issuer;
  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final Uri? userinfoEndpoint;
  final Uri? endSessionEndpoint;
  DiscoveryDocument({
    required this.issuer,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    this.userinfoEndpoint,
    this.endSessionEndpoint,
  });

  factory DiscoveryDocument.fromJson(Map<String, dynamic> json) {
    return DiscoveryDocument(
      issuer: Uri.parse(json['issuer'] as String),
      authorizationEndpoint:
          Uri.parse(json['authorization_endpoint'] as String),
      tokenEndpoint: Uri.parse(json['token_endpoint'] as String),
      userinfoEndpoint: json.containsKey('userinfo_endpoint')
          ? Uri.parse(json['userinfo_endpoint'] as String)
          : null,
      endSessionEndpoint: json.containsKey('end_session_endpoint')
          ? Uri.parse(json['end_session_endpoint'] as String)
          : null,
    );
  }
}
