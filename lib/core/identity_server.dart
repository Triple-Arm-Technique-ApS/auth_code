import 'dart:convert';

import 'package:auth_code/auth_code_options.dart';
import 'package:http/http.dart' as http;

import 'http_exception.dart';

class IdentityServer {
  final AuthCodeOptions _discoveryDocument;

  IdentityServer(this._discoveryDocument);

  Future<Map<String, dynamic>> getUserInfo(String accessToken) async {
    if (_discoveryDocument.userInfoEndpoint == null) {
      throw Exception('No user info endpoint found in discovery document.');
    }
    final response =
        await http.get(_discoveryDocument.userInfoEndpoint!, headers: {
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
