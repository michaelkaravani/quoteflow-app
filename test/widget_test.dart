import 'package:flutter_test/flutter_test.dart';
import 'package:quoteflow/main.dart';
import 'package:quoteflow/services/auth_service.dart';

void main() {
  testWidgets('QuoteFlow app loads without crashing', (WidgetTester tester) async {
    final authService = AuthService(
      authStream: Stream.value(null),
    );

    await tester.pumpWidget(QuoteFlowApp(authService: authService));
    await tester.pump();

    expect(find.text('QuoteFlow'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
