import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_code_http_exception.dart';

class DiscoveryDocument {
  /// URL using the https scheme with no query or fragment component that the OP asserts as its Issuer Identifier.
  /// If Issuer discovery is supported, this value MUST be identical to the issuer value returned by WebFinger.
  /// This also MUST be identical to the iss Claim value in ID Tokens issued from this Issuer.
  final Uri issuer;

  /// The OAuth 2.0 authorisation endpoint URL.
  final Uri authorizationEndpoint;

  /// The OAuth 2.0 Token_endpoint URL.
  /// This is REQUIRED unless only the Implicit Flow is used.
  final Uri tokenEndpoint;

  /// The OpenID Connect UserInfo endpoint URL.
  final Uri? userinfoEndpoint;

  /// REQUIRED IF OpenID Connect Provider supports OpenID Connect Session Management and
  /// is a URL at the OP to which an RP can perform a redirect to request that the End-User be logged out at the OP.
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

  /// Sends a http request to the well known configuration endpoint
  /// and parses the response into a [DiscoveryDocument], if a http failure
  /// occurs an [AuthCodeHttpException] is thrown.
  static Future<DiscoveryDocument> fromAuthority(
      Uri wellKnownConfigurationEndpoint) async {
    final response = await http.get(wellKnownConfigurationEndpoint);
    if (response.statusCode < 200 && response.statusCode > 299) {
      throw AuthCodeHttpException(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        body: response.body,
      );
    }

    return DiscoveryDocument.fromJson(jsonDecode(response.body));
  }
}
