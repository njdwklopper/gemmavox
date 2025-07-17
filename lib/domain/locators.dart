import 'package:gemma_vox/domain/services/gemma_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

 void setupGetItLocators() {
  //Gemma
  getIt.registerLazySingleton<GemmaService>(() => GemmaService());
}