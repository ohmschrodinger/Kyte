import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyte/app/bootstrap.dart';
import 'package:kyte/app/kyte_app.dart';
import 'package:kyte/widgets/org_tree_view.dart';

void main() {
  testWidgets('search is case-insensitive and shows name matches', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(KyteApp(bootstrap: const AppBootstrap.demo()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'AVA');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, 'Aarav Sharma'), findsOneWidget);
    expect(find.textContaining('Name match'), findsOneWidget);
  });

  testWidgets('search supports department matches', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(KyteApp(bootstrap: const AppBootstrap.demo()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hr');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, 'Naina Desai'), findsOneWidget);
    expect(find.textContaining('Dept match'), findsOneWidget);
  });

  testWidgets('clear button removes search results and highlight', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(KyteApp(bootstrap: const AppBootstrap.demo()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ava');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Aarav Sharma'));
    await tester.pumpAndSettle();

    var tree = tester.widget<OrgTreeView>(find.byType(OrgTreeView));
    expect(tree.highlightedMemberId, 'ceo-001');

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    tree = tester.widget<OrgTreeView>(find.byType(OrgTreeView));
    expect(tree.highlightedMemberId, isNull);
    expect(find.widgetWithText(ListTile, 'Aarav Sharma'), findsNothing);
  });
}
