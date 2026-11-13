import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kbtu_flutter/week13/core/api/api_client.dart';
import 'package:kbtu_flutter/week13/core/api/api_exception.dart';
import 'package:kbtu_flutter/week13/core/storage/secure_store.dart';
import 'package:kbtu_flutter/week13/features/users/http_user_repository.dart';
import 'package:kbtu_flutter/week13/features/users/users_cache.dart';

import '../../fixtures/user1.dart';

HttpUserRepository repoWith(MockClientHandler handler) => HttpUserRepository(
  ApiClient(const SecureStore(), client: MockClient(handler)),
  UsersCache(),
);

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('HttpUserRepository.getById', () {
    test('404 throws NotFoundException', () {
      final repo = repoWith(
        (_) async => http.Response('{"error":"gone"}', 404),
      );

      expect(repo.getById(99), throwsA(isA<NotFoundException>()));
    });

    test('500 throws ServerException', () {
      final repo = repoWith((_) async => http.Response('oops', 500));

      expect(
        repo.getById(1),
        throwsA(isA<ServerException>().having((e) => e.status, 'status', 500)),
      );
    });

    test('SocketException throws NoConnectionException', () {
      final repo = repoWith((_) async => throw const SocketException('down'));

      expect(repo.getById(1), throwsA(isA<NoConnectionException>()));
    });
  });

  test('a number in lat becomes BadResponseException', () {
    final user = jsonDecode(user1) as Map<String, dynamic>;
    final geo = (user['address'] as Map<String, dynamic>)['geo'] as Map;
    geo['lat'] = -37.3159;
    final repo = repoWith((_) async => http.Response(jsonEncode([user]), 200));

    expect(
      repo.getAll(),
      throwsA(
        isA<BadResponseException>().having(
          (e) => e.detail,
          'detail',
          startsWith('users: '),
        ),
      ),
    );
  });
}
