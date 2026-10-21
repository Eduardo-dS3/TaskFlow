import '../../data/repositories/settings/settings_repository.dart';
import '../../data/repositories/task/task_repository.dart';
import '../../data/repositories/user/user_repository.dart';
import '../../utils/result.dart';
import '../metrics/report_metrics.dart';
import '../models/productivity_report.dart';

/// Monta o relatório de produtividade a partir das tarefas e da equipe.
class BuildReportUseCase {
  BuildReportUseCase({
    required this._taskRepository,
    required this._userRepository,
    required this._settingsRepository,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final TaskRepository _taskRepository;
  final UserRepository _userRepository;
  final SettingsRepository _settingsRepository;
  final DateTime Function() _clock;

  /// Relatório do [period]; com [projectId], considera só aquele projeto.
  Future<Result<ProductivityReport>> build(
    ReportPeriod period, {
    String? projectId,
  }) async {
    final results = await (
      _taskRepository.getTasks(),
      _userRepository.getMembers(),
      _settingsRepository.getSettings(),
    ).wait;

    switch (results) {
      case (Ok(value: final tasks), Ok(value: final members), Ok(:final value)):
        return Result.ok(
          computeReport(
            tasks: tasks,
            members: members,
            period: period,
            activeSprint: value.activeSprint,
            now: _clock(),
            projectId: projectId,
          ),
        );
      case (Error(:final error), _, _) ||
          (_, Error(:final error), _) ||
          (_, _, Error(:final error)):
        return Result.error(error);
    }
  }
}
