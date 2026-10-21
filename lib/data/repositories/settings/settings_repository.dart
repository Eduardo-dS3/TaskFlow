import '../../../domain/models/app_settings.dart';
import '../../../utils/result.dart';

/// Configurações gerais compartilhadas pela equipe.
abstract class SettingsRepository {
  Future<Result<AppSettings>> getSettings();

  /// Apenas administradores podem salvar.
  Future<Result<AppSettings>> saveSettings(AppSettings settings);
}
