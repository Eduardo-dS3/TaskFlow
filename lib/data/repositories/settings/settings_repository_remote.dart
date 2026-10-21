import '../../../domain/models/app_settings.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/api/mappers/member_mappers.dart';
import 'settings_repository.dart';

/// Implementação de [SettingsRepository] no servidor (registro único).
class SettingsRepositoryRemote implements SettingsRepository {
  SettingsRepositoryRemote({required ApiClient apiClient}) : _api = apiClient;

  static const _collection = 'app_settings';

  final ApiClient _api;

  @override
  Future<Result<AppSettings>> getSettings() async {
    final result = await _api.list(_collection, sort: 'created');
    return switch (result) {
      Ok(:final value) when value.isNotEmpty => Result.ok(
        settingsFromRecord(value.first),
      ),
      Ok() => const Result.ok(AppSettings()),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<AppSettings>> saveSettings(AppSettings settings) async {
    if (settings.id.isEmpty) {
      return Result.error(
        Exception('Configurações não encontradas no servidor'),
      );
    }
    final result = await _api.update(
      _collection,
      settings.id,
      settingsToBody(settings),
    );
    return switch (result) {
      Ok(:final value) => Result.ok(settingsFromRecord(value)),
      Error(:final error) => Result.error(error),
    };
  }
}
