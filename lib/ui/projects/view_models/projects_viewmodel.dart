import 'package:flutter/foundation.dart';

import '../../../data/repositories/project/project_repository.dart';
import '../../../domain/models/project.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

enum ProjectsLayout { grid, list }

class ProjectsViewModel extends ChangeNotifier {
  ProjectsViewModel({
    required this._projectRepository,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    load = Command0(_load)..execute();
  }

  final ProjectRepository _projectRepository;
  final DateTime Function() _clock;

  late final Command0<void> load;

  DateTime get now => _clock();

  PortfolioSummary? _summary;
  PortfolioSummary? get summary => _summary;

  List<Project> _projects = [];
  List<Client> _clients = [];
  List<Client> get clients => _clients;

  List<MemberAllocation> _allocations = [];
  List<MemberAllocation> get allocations => _allocations;

  /// Frentes de trabalho presentes na alocação (legenda do gráfico).
  List<String> get fronts =>
      {for (final a in _allocations) ...a.hoursByFront.keys}.toList();

  double get totalOccupancy {
    if (_allocations.isEmpty) return 0;
    final allocated = _allocations.fold<double>(
      0,
      (sum, a) => sum + a.allocatedHours,
    );
    final capacity = _allocations.fold<double>(
      0,
      (sum, a) => sum + a.capacityHours,
    );
    return allocated / capacity;
  }

  /// `null` representa "Todos os Projetos".
  ProjectStatus? _statusFilter;
  ProjectStatus? get statusFilter => _statusFilter;

  String? _clientFilter;
  String? get clientFilter => _clientFilter;

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
      if (_statusFilter != null && p.status != _statusFilter) return false;
      if (_clientFilter != null && p.clientName != _clientFilter) return false;
      if (q.isNotEmpty && !p.name.toLowerCase().contains(q)) return false;
      return true;
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

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setLayout(ProjectsLayout layout) {
    _layout = layout;
    notifyListeners();
  }

  Future<Result<void>> _load() async {
    final results = await (
      _projectRepository.getPortfolioSummary(),
      _projectRepository.getProjects(),
      _projectRepository.getClients(),
      _projectRepository.getAllocations(),
    ).wait;

    switch (results) {
      case (
        Ok(value: final summary),
        Ok(value: final projects),
        Ok(value: final clients),
        Ok(value: final allocations),
      ):
        _summary = summary;
        _projects = projects;
        _clients = clients;
        _allocations = allocations;
        notifyListeners();
        return const Result.ok(null);
      default:
        notifyListeners();
        return Result.error(Exception('Falha ao carregar o portfólio'));
    }
  }
}
