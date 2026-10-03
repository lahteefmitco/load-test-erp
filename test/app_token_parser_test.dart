import 'package:flutter_test/flutter_test.dart';
import 'package:load_test_erp/features/auth/data/app_token_parser.dart';

void main() {
  test('extracts JWT from app-auth token JSON string', () {
    const tokenField =
        '[{"label":"DUMMY_GULFOWN_NILAMBUR_SERVICE2526","value":"header.payload.sig","expiration":"3/4/2030 4:41:32 AM"}]';

    expect(
      extractAppJwt(tokenField, baseUrl: 'http://mictcoserver2.mictco.com:3040/'),
      'header.payload.sig',
    );
  });
}
