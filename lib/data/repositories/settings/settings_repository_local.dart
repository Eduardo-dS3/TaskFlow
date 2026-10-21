import '../../../domain/models/app_settings.dart';
import '../../../utils/result.dart';
import '../../services/local/local_data_service.dart';
import 'settings_repository.dart';

/// Implementação de [SettingsRepository] em memória.
class SettingsRepositoryLocal implements SettingsRepository {
  SettingsRepositoryLocal({required LocalDataService localDataService})
    : _service = localDataService;

  final LocalDataService _service;

  @override
  Future<Result<AppSettings>> getSettings() async =>
      Result.ok(_service.settings);

  @override
  Future<Result<AppSettings>> saveSettings(AppSettings settings) async {
    _service.settings = settings;
    return Result.ok(settings);
  }
}
