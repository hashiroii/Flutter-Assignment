import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kbtu_flutter/week13/features/users/geo.dart';
import 'package:kbtu_flutter/week13/features/users/user.dart';

import '../../fixtures/user1.dart';

void main() {
  group('User.fromJson', () {
    test('parses the real user 1', () {
      final json = jsonDecode(user1) as Map<String, dynamic>;

      final user = User.fromJson(json);

      expect(user.name, 'Leanne Graham');
      expect(user.address.city, 'Gwenborough');
      expect(user.address.geo.lat, -37.3159);
    });

    test('throws a TypeError when id is a string', () {
      final json = jsonDecode(user1) as Map<String, dynamic>;
      json['id'] = '1';

      expect(() => User.fromJson(json), throwsA(isA<TypeError>()));
    });
  });

  test('Geo.fromJson throws a TypeError when lat is a number', () {
    final json = <String, dynamic>{'lat': -68.6102, 'lng': '-47.0653'};

    expect(() => Geo.fromJson(json), throwsA(isA<TypeError>()));
  });
}
