import 'package:snp_client/abstract/snp_client.dart';
import 'package:snp_client/abstract/snp_client_options.dart';
import 'package:snp_client/snp_client_impl.dart';
import 'package:test/test.dart';

void main() {
  late SnpClient _client;
  late SnpClientOptions _options;

  setUp(() {
    _options = SnpClientOptions();
    _client = SnpClientImpl(_options);
  });

  group('[SnpClient]', () {
    test('can be created', () async {
      expect(_client, isNotNull);
    });
  });

  tearDown(() {});
}
