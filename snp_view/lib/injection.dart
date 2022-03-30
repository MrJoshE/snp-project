import 'package:get_it/get_it.dart';

import 'state/home_page_cubit.dart';

GetIt locator = GetIt.instance;

Future setupInjection() async {
  locator.registerFactory<HomePageCubit>(() => HomePageCubit());
  // locator.registerLazySingleton(instance)
}
