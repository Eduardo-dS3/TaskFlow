import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/task/task_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/metrics/task_metrics.dart';
import '../../../domain/models/member.dart';
import '../../../domain/models/task.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// Estado da moldura do app: usuário logado, pendências e presença online.
class ShellViewModel extends ChangeNotifier {
  ShellViewModel({
    required this._authRepository,
    required this._userRepository,
    required this._taskRepository,
    DateTime Function()? clock,
    this._heartbeat = const Duration(minutes: 2),
  }) : _clock = clock ?? DateTime.now {
    load = Command0(_load);
    logout = Command0(_authRepository.logout);
    _authRepository.addListener(_onAuthChanged);
    _profileSubscription = _userRepository.currentUserChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
    _onAuthChanged();
  }

  /// Prazo (em dias) a partir do qual uma tarefa aparece nas pendências.
  static const alertWindowDays = 2;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final TaskRepository _taskRepository;
  final DateTime Function() _clock;
  final Duration _heartbeat;
  Timer? _timer;
  late final StreamSubscription<Member> _profileSubscription;

  late final Command0<void> load;
  late final Command0<void> logout;

  Member? _user;
  Member? get user => _user;

  bool get isAdmin => _user?.isAdmin ?? false;

  List<Task> _alerts = [];

  /// Tarefas abertas do usuário atrasadas ou com prazo nos próximos dias.
  List<Task> get alerts => _alerts;

  void _onAuthChanged() {
    _timer?.cancel();
    if (!_authRepository.isAuthenticated) {
      _user = null;
      _alerts = [];
      notifyListeners();
      return;
    }
    load.execute();
    _timer = Timer.periodic(_heartbeat, (_) => load.execute());
  }

  Future<Result<void>> _load() async {
    final userResult = await _userRepository.getCurrentUser();
    if (userResult case Error(:final error)) return Result.error(error);
    final user = (userResult as Ok<Member>).value;
    _user = user;

    final tasks = await _taskRepository.getTasks();
    if (tasks case Ok(:final value)) _alerts = _alertsFor(user, value);
    notifyListeners();

    await _userRepository.markPresence();
    return const Result.ok(null);
  }

  List<Task> _alertsFor(Member user, List<Task> tasks) {
    final limit = startOfDay(
      _clock(),
    ).add(const Duration(days: alertWindowDays + 1));
    final alerts = tasks.where((t) {
      final due = t.dueDate;
      return t.status != TaskStatus.done &&
          due != null &&
          due.isBefore(limit) &&
          involves(t, user);
    }).toList();
    return alerts..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_profileSubscription.cancel());
    _authRepository.removeListener(_onAuthChanged);
    super.dispose();
  }
}
