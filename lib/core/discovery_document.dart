class DiscoveryDocument {
  final Uri issuer;
  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final Uri userinfoEndpoint;

  DiscoveryDocument({
    required this.issuer,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.userinfoEndpoint,
  });

  factory DiscoveryDocument.fromJson(Map<String, dynamic> json) {
    return DiscoveryDocument(
      issuer: Uri.parse(json['issuer'] as String),
      authorizationEndpoint:
          Uri.parse(json['authorization_endpoint'] as String),
      tokenEndpoint: Uri.parse(json['token_endpoint'] as String),
      userinfoEndpoint: Uri.parse(json['userinfo_endpoint'] as String),
    );
  }
}
