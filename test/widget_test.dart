import 'package:flutter_test/flutter_test.dart';
import 'package:azamov_second_me/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    expect(() => const AzamovAcademyApp(), isNot(throwsException));
  });
}
