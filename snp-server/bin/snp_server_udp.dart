import 'package:logging/logging.dart';
import 'package:snp_server/snp_server_config_impl.dart';
import 'package:snp_server/snp_server_udp_impl.dart';
import 'package:snp_shared/snp_shared.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  String lastLoggerName = '';

  Logger.root.onRecord.listen((record) {
    if (record.loggerName != lastLoggerName) {
      print('\n');
    }
    print('\t[${record.loggerName}]\t\t ${record.message}');
    lastLoggerName = record.loggerName;
  });

  SnpRequestHandler.isLogging = true;

  final config = SnpServerConfigImpl();

  final server = SnpServerUdpImpl(config);

  await server.initialize();
}
