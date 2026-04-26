import 'package:flutter_test/flutter_test.dart';

import 'package:kyte/app/bootstrap.dart';
import 'package:kyte/app/kyte_app.dart';

void main() {
  testWidgets('Kyte app boots in demo mode', (WidgetTester tester) async {
    await tester.pumpWidget(KyteApp(bootstrap: const AppBootstrap.demo()));
    await tester.pumpAndSettle();

    expect(find.text('Kyte'), findsOneWidget);
    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.text('Phase 7 resilience hardening'), findsOneWidget);
    expect(find.text('Org chart'), findsOneWidget);
    expect(find.text('Aarav Sharma'), findsWidgets);
  });
}
