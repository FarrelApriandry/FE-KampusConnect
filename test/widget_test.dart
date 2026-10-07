import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fe/shared/widgets/kc_logo.dart';

void main() {
  testWidgets('KCLogo renders wordmark', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: KCLogo())),
    );

    expect(find.text('Kampus'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
  });
}
