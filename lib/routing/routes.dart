/// Caminhos de navegação do app.
abstract final class Routes {
  static const board = '/board';
  static const tasks = '/tasks';
  static const newTask = '/tasks/new';
  static const projects = '/projects';
  static const reports = '/reports';

  static String taskWithId(String id) => '$tasks/$id';
}
