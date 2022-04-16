import 'package:logging/logging.dart';
import 'package:snp_server/snp_server_config_impl.dart';
import 'package:snp_server/snp_server_impl.dart';

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

  final config = SnpServerConfigImpl();

  final server = SnpServerImpl(config);

  await server.initialize();
}
