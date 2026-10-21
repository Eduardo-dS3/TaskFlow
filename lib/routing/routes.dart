import '../domain/models/task.dart';

/// Caminhos de navegação do app.
abstract final class Routes {
  static const login = '/login';
  static const board = '/board';
  static const tasks = '/tasks';
  static const newTask = '/tasks/new';
  static const projects = '/projects';
  static const reports = '/reports';
  static const settings = '/settings';
  static const team = '/team';

  static String taskWithId(String id) => '$tasks/$id';

  /// Nova tarefa já posicionada em uma coluna do quadro.
  static String newTaskWithStatus(TaskStatus status) =>
      '$newTask?status=${status.name}';

  /// Quadro filtrado pelo texto da busca.
  static String boardSearch(String query) =>
      Uri(path: board, queryParameters: {'q': query}).toString();
}
