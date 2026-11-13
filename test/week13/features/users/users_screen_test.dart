import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kbtu_flutter/week13/features/users/users_model.dart';
import 'package:kbtu_flutter/week13/features/users/users_screen.dart';
import 'package:provider/provider.dart';

import '../../fakes/fake_user_repository.dart';

void main() {
  testWidgets('shows the offline view and Retry', (tester) async {
    final model = UsersModel(FakeUserRepository(fail: true));
    await tester.runAsync(model.load);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: model,
          child: const UsersScreen(),
        ),
      ),
    );

    expect(find.text('No connection'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
