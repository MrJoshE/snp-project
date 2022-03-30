import 'package:logging/logging.dart';
import 'package:snp_server/snp_server_impl.dart';

Future<void> main() async {
  print('\n');
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}:\t\t\t ${record.loggerName} ${record.message}');
  });

  final server = SnpServerImpl();

  await server.initialize();
}
