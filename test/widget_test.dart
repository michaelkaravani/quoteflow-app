import 'package:flutter_test/flutter_test.dart';

import 'package:quoteflow/services/auth_service.dart';

void main() {
  test('AuthService translates Firebase errors to Hebrew', () {
    final service = AuthService();

    expect(
      service.translateError('invalid-credential'),
      'כתובת האימייל או הסיסמה שגויים',
    );
    expect(
      service.translateError('wrong-password'),
      'כתובת האימייל או הסיסמה שגויים',
    );
    expect(
      service.translateError('user-not-found'),
      'כתובת האימייל או הסיסמה שגויים',
    );
    expect(
      service.translateError('email-already-in-use'),
      'כתובת האימייל כבר רשומה במערכת',
    );
    expect(
      service.translateError('weak-password'),
      'הסיסמה חייבת להכיל לפחות 6 תווים',
    );
    expect(
      service.translateError('invalid-email'),
      'נא להזין כתובת אימייל תקינה',
    );
    expect(
      service.translateError('network-request-failed'),
      'בעיית תקשורת. בדוק את החיבור לאינטרנט',
    );
    expect(
      service.translateError('too-many-requests'),
      'יותר מדי ניסיונות. נא לנסות שוב מאוחר יותר',
    );
    expect(
      service.translateError('unknown-error'),
      'אירעה שגיאה. נא לנסות שוב',
    );
  });
}
