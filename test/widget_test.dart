import 'package:flutter_test/flutter_test.dart';
import 'package:ps_deskom/main.dart';

void main() {
  testWidgets('PS DesKom App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PSDesKomApp());
    expect(find.text('PS DesKom - Desenvolvido por Gradle Studio'), findsOneWidget);
  });
}
