import 'package:logging/logging.dart';
import 'package:snp_client/snp_client.dart';

void main(List<String> arguments) {
  print(    '\n\n'  );
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}:\t\t\t ${record.message}');
  });


  final client = SnpClient();


  
  
}
