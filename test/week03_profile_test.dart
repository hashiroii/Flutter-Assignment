import 'package:flutter_test/flutter_test.dart';

import 'package:assignment_2/week03/main.dart';
import 'package:assignment_2/week03/data.dart';

void main() {
  testWidgets('Profile screen shows name and university', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProfileApp());

    expect(find.text('My profile'), findsOneWidget);
    expect(find.text(myName), findsOneWidget);
    expect(find.text(myUniversity), findsOneWidget);
  });
}
