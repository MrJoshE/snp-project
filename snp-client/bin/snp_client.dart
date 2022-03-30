import 'package:logging/logging.dart';
import 'package:snp_client/abstract/snp_client_options.dart';
import 'package:snp_client/snp_client_impl.dart';
import 'package:snp_shared/requests/requests.dart';
import 'package:snp_shared/responses/responses.dart';

Future main(List<String> arguments) async {
  print('\n');
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}:\t\t\t ${record.loggerName} ${record.message}');
  });

  SnpResponseHandler.isLogging = false;

  final options = SnpClientOptions(
    proxyServerAddress: 'localhost',
    token: 'josh',
  );

  final client = SnpClientImpl(options);

  final request = SnpHttpRequest(method: 'GET', path: 'www.google.com');

  await client.initialize();

  final authResponse = await client.authenticate();
  print('Auth response: ${authResponse.status}');

  final response = await client.send(request: request);
  print('Response: ${response.status}');
}
