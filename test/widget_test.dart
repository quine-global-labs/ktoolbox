import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ktoolbox/models/toolbox_container.dart';
import 'package:ktoolbox/screens/home_screen.dart';
import 'package:ktoolbox/services/toolbox_service.dart';

class _FakeToolboxService extends ToolboxService {
  const _FakeToolboxService();

  @override
  Future<List<ToolboxContainer>> listContainers() async => const [];
}

void main() {
  testWidgets('App shows the Ktoolbox title bar and empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(service: const _FakeToolboxService())),
    );
    await tester.pump();

    expect(find.text('Ktoolbox'), findsOneWidget);
    expect(find.text('No Toolbox containers yet. Tap + to create one.'), findsOneWidget);
  });
}
