import 'package:get_it/get_it.dart';
import 'package:snp_view/app_config.dart';
import 'package:snp_view/model/api_client.dart';
import 'package:snp_view/model/snp_service.dart';

import 'state/home_page_cubit.dart';

GetIt locator = GetIt.instance;

Future setupInjection() async {
  locator.registerFactory<AppConfig>(() => AppConfig());
  locator.registerLazySingleton(() => ApiClient(locator()));
  locator.registerLazySingleton(() => SnpService(locator()));

  locator.registerFactory<HomePageCubit>(() => HomePageCubit(locator()));

  // locator.registerLazySingleton(instance)
}
