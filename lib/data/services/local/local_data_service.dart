import '../../../domain/models/app_settings.dart';
import '../../../domain/models/member.dart';
import '../../../domain/models/project.dart';
import '../../../domain/models/task.dart';
import 'seed/seed_calendar.dart';
import 'seed/seed_members.dart';
import 'seed/seed_projects.dart';
import 'seed/seed_tasks.dart';

/// Fonte de dados em memória usada no modo de demonstração e nos testes.
///
/// Simula o servidor: guarda tarefas, projetos, clientes, equipe e
/// configurações enquanto o app está aberto. Os dados iniciais ficam em
/// `seed/`.
class LocalDataService {
  LocalDataService({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    final calendar = SeedCalendar(_clock());
    _tasks = seedTasks(calendar);
    _projects = seedProjects(calendar);
  }

  final DateTime Function() _clock;
  int _sequence = 1100;

  DateTime get now => _clock();

  /// Identificador novo para registros criados localmente.
  String newId(String prefix) => '$prefix-${++_sequence}';

  /// Próximo código legível de tarefa (TK-1101, TK-1102, ...).
  String nextTaskCode() => 'TK-${++_sequence}';

  // ---------------------------------------------------------------------------
  // Equipe
  // ---------------------------------------------------------------------------

  List<Member> _members = [...SeedMembers.all];
  String _currentUserId = SeedMembers.mariana.id;

  Member get currentUser => _members.firstWhere((m) => m.id == _currentUserId);

  set currentUserId(String id) => _currentUserId = id;

  List<Member> get members => List.unmodifiable(_members);

  Member? findMember(String id) => _find(_members, id, (m) => m.id);

  Member upsertMember(Member member) {
    _members = _upsert(_members, member, (m) => m.id);
    return member;
  }

  // ---------------------------------------------------------------------------
  // Configurações
  // ---------------------------------------------------------------------------

  AppSettings settings = const AppSettings(
    id: 'settings',
    activeSprint: seedActiveSprint,
  );

  // ---------------------------------------------------------------------------
  // Tarefas
  // ---------------------------------------------------------------------------

  late List<Task> _tasks;

  /// Conteúdo dos anexos enviados nesta sessão, por id do anexo.
  final Map<String, List<int>> attachmentBytes = {};

  List<Task> get tasks => List.unmodifiable(_tasks);

  Task? findTask(String id) => _find(_tasks, id, (t) => t.id);

  Task upsertTask(Task task) {
    _tasks = _upsert(_tasks, task, (t) => t.id);
    return task;
  }

  bool deleteTask(String id) => _remove(id, (t) => t.id, _tasks, (list) {
    _tasks = list;
  });

  // ---------------------------------------------------------------------------
  // Projetos & Clientes
  // ---------------------------------------------------------------------------

  late List<Project> _projects;
  List<Client> _clients = [...seedClients];

  List<Project> get projects => List.unmodifiable(_projects);

  List<Client> get clients => List.unmodifiable(_clients);

  Client? findClient(String id) => _find(_clients, id, (c) => c.id);

  Project upsertProject(Project project) {
    _projects = _upsert(_projects, project, (p) => p.id);
    return project;
  }

  bool deleteProject(String id) => _remove(id, (p) => p.id, _projects, (list) {
    _projects = list;
  });

  Client upsertClient(Client client) {
    _clients = _upsert(_clients, client, (c) => c.id);
    return client;
  }

  bool deleteClient(String id) => _remove(id, (c) => c.id, _clients, (list) {
    _clients = list;
  });

  // ---------------------------------------------------------------------------
  // Utilitários
  // ---------------------------------------------------------------------------

  static T? _find<T>(List<T> items, String id, String Function(T) idOf) {
    for (final item in items) {
      if (idOf(item) == id) return item;
    }
    return null;
  }

  /// Substitui o item de mesmo id ou o adiciona ao final.
  static List<T> _upsert<T>(List<T> items, T item, String Function(T) idOf) {
    final index = items.indexWhere((i) => idOf(i) == idOf(item));
    if (index == -1) return [...items, item];
    return [...items]..[index] = item;
  }

  static bool _remove<T>(
    String id,
    String Function(T) idOf,
    List<T> items,
    void Function(List<T>) assign,
  ) {
    final remaining = items.where((i) => idOf(i) != id).toList();
    assign(remaining);
    return remaining.length != items.length;
  }
}
