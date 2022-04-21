import 'package:logging/logging.dart';
import 'package:snp_client/abstract/snp_client_options.dart';
import 'package:snp_client/snp_client_udp_impl.dart';
import 'package:snp_shared/snp_shared.dart';

Future<void> main() async {
  registerLogger();

  final options = SnpClientOptions(proxyServerAddress: '127.0.0.1');
  final client = SnpClientUdpImpl(options);

  final dataResponse = await client.initialize();
  if (dataResponse.isSuccessful) {
    print('Successfully initialized');
  } else {
    print('Failed to initialize');
  }

  final request = SnpHttpRequest(method: 'GET', path: 'https://www.google.com');
  final response = await client.send(request: request);
  print(response);
}

registerLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  String lastLoggerName = '';

  Logger.root.onRecord.listen((record) {
    if (record.loggerName != lastLoggerName) {
      print('\n');
    }
    print('\t[${record.loggerName}]\t\t ${record.message}');
    lastLoggerName = record.loggerName;
  });
}