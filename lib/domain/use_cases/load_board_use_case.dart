import '../../data/repositories/settings/settings_repository.dart';
import '../../data/repositories/task/task_repository.dart';
import '../../data/repositories/user/user_repository.dart';
import '../../utils/result.dart';
import '../metrics/board_metrics.dart';
import '../models/member.dart';
import '../models/task.dart';

/// Tudo o que o quadro precisa para ser exibido.
class BoardData {
  const BoardData({
    required this.tasks,
    required this.overview,
    required this.members,
  });

  final List<Task> tasks;
  final SprintOverview overview;
  final List<Member> members;
}

/// Carrega as tarefas e calcula os indicadores do quadro.
class LoadBoardUseCase {
  LoadBoardUseCase({
    required this._taskRepository,
    required this._userRepository,
    required this._settingsRepository,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final TaskRepository _taskRepository;
  final UserRepository _userRepository;
  final SettingsRepository _settingsRepository;
  final DateTime Function() _clock;

  Future<Result<BoardData>> load() async {
    final results = await (
      _taskRepository.getTasks(),
      _userRepository.getMembers(),
      _settingsRepository.getSettings(),
    ).wait;

    switch (results) {
      case (Ok(value: final tasks), Ok(value: final members), Ok(:final value)):
        return Result.ok(
          BoardData(
            tasks: tasks,
            members: members,
            overview: computeSprintOverview(
              tasks: tasks,
              members: members,
              activeSprint: value.activeSprint,
              now: _clock(),
            ),
          ),
        );
      case (Error(:final error), _, _) ||
          (_, Error(:final error), _) ||
          (_, _, Error(:final error)):
        return Result.error(error);
    }
  }
}
