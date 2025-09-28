import 'package:get_it/get_it.dart';
import 'package:kanban_flow/src/common/services/storage_service.dart';
import 'package:kanban_flow/src/features/kanban/repositories/kanban_repository.dart';
import 'package:kanban_flow/src/features/kanban/view_models/kanban_view_model.dart';
import 'package:kanban_flow/src/features/settings/repositories/setting_repository.dart';
import 'package:kanban_flow/src/features/settings/view_models/setting_view_model.dart';

final locator = GetIt.instance;

void dependencyInjector() {
  _startStorageService();
  _startFeatureKanban();
  _startFeatureSetting();
}

void _startStorageService() {
  locator.registerLazySingleton<StorageService>(() => StorageServiceImpl());
}

void _startFeatureKanban() {
  locator.registerCachedFactory<KanbanRepository>(() => KanbanRepositoryImpl());
  locator.registerLazySingleton<KanbanViewModel>(
    () => KanbanViewModelImpl(kanbanRepository: locator<KanbanRepository>()),
  );
}

void _startFeatureSetting() {
  locator.registerCachedFactory<SettingRepository>(
    () => SettingRepositoryImpl(storageService: locator<StorageService>()),
  );
  locator.registerLazySingleton<SettingViewModel>(
    () => SettingViewModelImpl(settingRepository: locator<SettingRepository>()),
  );
}

Future<void> initDependencies() async {
  await locator<StorageService>().initStorage();
  await Future.wait([locator<SettingViewModel>().getTheme()]);
}

void resetDependencies() {
  locator.reset();
}

void resetFeatureSetting() {
  locator.unregister<SettingRepository>();
  locator.unregister<SettingViewModel>();
  _startFeatureSetting();
}
