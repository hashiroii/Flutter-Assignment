import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kbtu_flutter/week13/features/users/user.dart';

const user1 = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {
      "lat": "-37.3159",
      "lng": "81.1496"
    }
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';

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
}
