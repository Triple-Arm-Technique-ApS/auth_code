import 'dart:convert';

import 'discovery_document.dart';
import 'package:http/http.dart' as http;

import 'http_exception.dart';

class IdentityServer {
  final Uri authority;

  DiscoveryDocument? _discoveryDocument;

  IdentityServer(this.authority);

  bool get isInitialized => _discoveryDocument != null;
  DiscoveryDocument? get discoveryDocument => _discoveryDocument;

  Future<void> init() async {
    final endpoint = authority.resolveUri(
      Uri.parse('.well-known/openid-configuration'),
    );
    final response = await http.get(endpoint);
    if (response.statusCode < 200 && response.statusCode > 299) {
      throw HttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }
    _discoveryDocument = DiscoveryDocument.fromJson(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> getUserInfo(String accessToken) async {
    if (_discoveryDocument == null) {
      await init();
    }

    if (_discoveryDocument?.userinfoEndpoint == null) {
      throw Exception('No user info endpoint found in discovery document.');
    }
    final response =
        await http.get(_discoveryDocument!.userinfoEndpoint!, headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });
    if (response.statusCode < 200 && response.statusCode > 299) {
      throw HttpException(
          response.statusCode, response.reasonPhrase, response.body);
    }

    return jsonDecode(response.body);
  }
}
