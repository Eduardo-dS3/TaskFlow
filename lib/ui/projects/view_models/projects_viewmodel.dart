import 'package:flutter/foundation.dart';

import '../../../data/repositories/project/project_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/member.dart';
import '../../../domain/models/project.dart';
import '../../../domain/use_cases/load_portfolio_use_case.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

enum ProjectsLayout { grid, list }

class ProjectsViewModel extends ChangeNotifier {
  ProjectsViewModel({
    required this._loadPortfolio,
    required this._projectRepository,
    required this._userRepository,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    load = Command0(_load)..execute();
    saveProject = Command1(_saveProject);
    deleteProject = Command1(_deleteProject);
    saveClient = Command1(_saveClient);
    deleteClient = Command1(_deleteClient);
  }

  final LoadPortfolioUseCase _loadPortfolio;
  final ProjectRepository _projectRepository;
  final UserRepository _userRepository;
  final DateTime Function() _clock;

  late final Command0<void> load;
  late final Command1<void, Project> saveProject;
  late final Command1<void, String> deleteProject;
  late final Command1<void, Client> saveClient;
  late final Command1<void, String> deleteClient;

  DateTime get now => _clock();

  PortfolioData? _data;

  PortfolioSummary? get summary => _data?.summary;

  List<Client> get clients => _data?.clients ?? const [];

  List<MemberAllocation> get allocations => _data?.allocations ?? const [];

  /// Pessoas ativas que podem compor a equipe de um projeto.
  List<Member> get members =>
      (_data?.members ?? const <Member>[]).where((m) => m.active).toList();

  Member? _currentUser;

  /// Apenas administradores excluem projetos e clientes.
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  List<Project> get _projects => _data?.projects ?? const [];

  /// Frentes de trabalho presentes na alocação (legenda do gráfico).
  List<String> get fronts =>
      {for (final a in allocations) ...a.hoursByFront.keys}.toList();

  double get totalOccupancy {
    if (allocations.isEmpty) return 0;
    final allocated = allocations.fold<double>(
      0,
      (sum, a) => sum + a.allocatedHours,
    );
    final capacity = allocations.fold<double>(
      0,
      (sum, a) => sum + a.capacityHours,
    );
    return capacity == 0 ? 0 : allocated / capacity;
  }

  /// `null` representa "Todos os Projetos".
  ProjectStatus? _statusFilter;
  ProjectStatus? get statusFilter => _statusFilter;

  String? _clientFilter;
  String? get clientFilter => _clientFilter;

  Member? _memberFilter;
  Member? get memberFilter => _memberFilter;

  String _query = '';

  ProjectsLayout _layout = ProjectsLayout.grid;
  ProjectsLayout get layout => _layout;

  int get totalCount => _projects.length;

  int countFor(ProjectStatus status) =>
      _projects.where((p) => p.status == status).length;

  List<String> get clientNames =>
      {for (final p in _projects) p.clientName}.toList()..sort();

  List<Project> get projects {
    final q = _query.trim().toLowerCase();
    return _projects.where((p) {
      final member = _memberFilter;
      return (_statusFilter == null || p.status == _statusFilter) &&
          (_clientFilter == null || p.clientName == _clientFilter) &&
          (member == null || p.team.contains(member)) &&
          (q.isEmpty || p.name.toLowerCase().contains(q));
    }).toList();
  }

  void setStatusFilter(ProjectStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setClientFilter(String? client) {
    _clientFilter = client;
    notifyListeners();
  }

  void setMemberFilter(Member? member) {
    _memberFilter = member;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setLayout(ProjectsLayout layout) {
    _layout = layout;
    notifyListeners();
  }

  Future<Result<void>> _load() async {
    if (await _userRepository.getCurrentUser() case Ok(:final value)) {
      _currentUser = value;
    }
    final result = await _loadPortfolio.load();
    if (result case Ok(:final value)) _data = value;
    notifyListeners();
    return result;
  }

  /// Executa uma alteração e, se der certo, recarrega os indicadores.
  Future<Result<void>> _mutate(Future<Result<Object?>> action) async {
    final result = await action;
    if (result case Error(:final error)) return Result.error(error);
    return _load();
  }

  Future<Result<void>> _saveProject(Project project) =>
      _mutate(_projectRepository.saveProject(project));

  Future<Result<void>> _deleteProject(String id) =>
      _mutate(_projectRepository.deleteProject(id));

  Future<Result<void>> _saveClient(Client client) =>
      _mutate(_projectRepository.saveClient(client));

  Future<Result<void>> _deleteClient(String id) =>
      _mutate(_projectRepository.deleteClient(id));
}
