import 'package:flutter/foundation.dart';

import '../../../data/repositories/settings/settings_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/app_settings.dart';
import '../../../domain/models/member.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// Nome e cargo do próprio usuário.
typedef ProfileData = ({String name, String role});

/// Troca de senha do próprio usuário.
typedef PasswordChange = ({String current, String next});

/// Dados da organização (somente administradores).
typedef OrganizationData = ({String organization, String activeSprint});

/// Perfil, senha e configurações gerais.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required this._userRepository,
    required this._settingsRepository,
  }) {
    load = Command0(_load)..execute();
    saveProfile = Command1(_saveProfile);
    changePassword = Command1(_changePassword);
    saveOrganization = Command1(_saveOrganization);
  }

  final UserRepository _userRepository;
  final SettingsRepository _settingsRepository;

  late final Command0<void> load;
  late final Command1<void, ProfileData> saveProfile;
  late final Command1<void, PasswordChange> changePassword;
  late final Command1<void, OrganizationData> saveOrganization;

  Member? _user;
  Member? get user => _user;

  AppSettings _settings = const AppSettings();
  AppSettings get settings => _settings;

  bool get isAdmin => _user?.isAdmin ?? false;

  Future<Result<void>> _load() async {
    final results = await (
      _userRepository.getCurrentUser(),
      _settingsRepository.getSettings(),
    ).wait;
    switch (results) {
      case (Ok(value: final user), Ok(value: final settings)):
        _user = user;
        _settings = settings;
        notifyListeners();
        return const Result.ok(null);
      case (Error(:final error), _) || (_, Error(:final error)):
        notifyListeners();
        return Result.error(error);
    }
  }

  Future<Result<void>> _saveProfile(ProfileData data) async {
    final result = await _userRepository.updateProfile(
      name: data.name,
      role: data.role,
    );
    switch (result) {
      case Ok(:final value):
        _user = value;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _changePassword(PasswordChange data) => _userRepository
      .changePassword(currentPassword: data.current, newPassword: data.next);

  Future<Result<void>> _saveOrganization(OrganizationData data) async {
    final result = await _settingsRepository.saveSettings(
      _settings.copyWith(
        organization: data.organization.trim(),
        activeSprint: data.activeSprint.trim(),
      ),
    );
    switch (result) {
      case Ok(:final value):
        _settings = value;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }
}
