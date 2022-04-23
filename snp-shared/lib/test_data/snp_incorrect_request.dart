import '../snp_shared.dart';

class SnpIncorrectRequestTest {
  static SnpRequest send() {
    return SnpRequest(
      id: 'test_send',
      type: 'SEND',
      body: {"method": "GET", "url": "https://www.google.com", "headers": {}, "body": {}},
    );
  }

  static SnpRequest auth() {
    return SnpRequest(
      id: 'test_auth',
      type: 'AUTH',
      body: {
        'authToken': 'admin',
      },
    );
  }
}
