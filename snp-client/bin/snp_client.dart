import 'package:logging/logging.dart';
import 'package:snp_client/snp_client.dart' as snp_client;

void main(List<String> arguments) {

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  
  
}
