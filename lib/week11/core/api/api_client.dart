import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  Map<String, String> get headers => {'Accept': 'application/json'};

  Uri uri(String path, [Map<String, String>? query]) =>
      Uri.https(host, path, query);

  Future<dynamic> get(Uri url) async {
    final r = await _send(() => _client.get(url, headers: headers));
    _check(r);
    return _decode(r);
  }

  Future<dynamic> post(Uri url, Map<String, dynamic> body) async {
    final r = await _send(
      () => _client.post(
        url,
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    _check(r);
    if (r.statusCode != 201) {
      throw BadResponseException(
        '${url.path}: expected 201, got ${r.statusCode}',
      );
    }
    return _decode(r);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final r = await call().timeout(const Duration(seconds: 10));
      assert(() {
        log(
          '${r.request?.method} ${r.request?.url.path} → ${r.statusCode}',
          name: 'api',
        );
        return true;
      }());
      return r;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response r) {
    if (r.statusCode == 401) throw const UnauthorizedException();
    if (r.statusCode == 404) throw const NotFoundException();
    if (r.statusCode >= 500) throw ServerException(r.statusCode);
  }

  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('${r.request?.url.path}: $e');
    }
  }
}
