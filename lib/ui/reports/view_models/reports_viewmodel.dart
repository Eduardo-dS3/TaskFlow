import 'package:flutter/foundation.dart';

import '../../../data/repositories/project/project_repository.dart';
import '../../../data/repositories/settings/settings_repository.dart';
import '../../../domain/models/productivity_report.dart';
import '../../../domain/models/project.dart';
import '../../../domain/use_cases/build_report_use_case.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import '../export/pdf_theme.dart';
import '../export/report_csv.dart';
import '../export/report_pdf.dart';

/// Filtros do relatório: período e, opcionalmente, um projeto.
typedef ReportFilter = ({ReportPeriod period, String? projectId});

class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel({
    required this._buildReport,
    required this._projectRepository,
    required this._settingsRepository,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    load = Command1(_load)..execute(_filter);
    exportCsv = Command0(_exportCsv);
    exportPdf = Command0(_exportPdf);
  }

  final BuildReportUseCase _buildReport;
  final ProjectRepository _projectRepository;
  final SettingsRepository _settingsRepository;
  final DateTime Function() _clock;

  late final Command1<void, ReportFilter> load;

  /// Conteúdo do CSV, pronto para baixar.
  late final Command0<List<int>> exportCsv;

  /// Conteúdo do PDF executivo, pronto para baixar ou abrir.
  late final Command0<List<int>> exportPdf;

  static const pageSize = 5;

  ProductivityReport? _report;
  ProductivityReport? get report => _report;

  ReportFilter _filter = (period: ReportPeriod.last30Days, projectId: null);

  ReportPeriod get period => _filter.period;

  String? get projectId => _filter.projectId;

  List<Project> _projects = [];
  List<Project> get projects => _projects;

  /// Descrição do recorte atual (todos os projetos ou um específico).
  String get scope {
    final id = _filter.projectId;
    final project = _projects.where((p) => p.id == id).firstOrNull;
    return project == null ? 'Todos os projetos' : 'Projeto: ${project.name}';
  }

  int _page = 0;
  int get page => _page;

  int get pageCount {
    final total = _report?.members.length ?? 0;
    return (total / pageSize).ceil().clamp(1, 999);
  }

  List<MemberPerformance> get visibleMembers =>
      _report?.members.skip(_page * pageSize).take(pageSize).toList() ?? [];

  void selectPeriod(ReportPeriod period) {
    if (period == _filter.period) return;
    load.execute((period: period, projectId: _filter.projectId));
  }

  void selectProject(String? projectId) {
    if (projectId == _filter.projectId) return;
    load.execute((period: _filter.period, projectId: projectId));
  }

  void setPage(int page) {
    _page = page.clamp(0, pageCount - 1);
    notifyListeners();
  }

  void retry() => load.execute(_filter);

  Future<Result<void>> _load(ReportFilter filter) async {
    _filter = filter;
    notifyListeners();

    if (_projects.isEmpty) {
      if (await _projectRepository.getProjects() case Ok(:final value)) {
        _projects = value;
      }
    }
    final result = await _buildReport.build(
      filter.period,
      projectId: filter.projectId,
    );
    if (result case Ok(:final value)) {
      _report = value;
      _page = 0;
    }
    notifyListeners();
    return result;
  }

  Future<Result<List<int>>> _exportCsv() async {
    final report = _report;
    if (report == null) {
      return Result.error(Exception('Relatório não carregado'));
    }
    return Result.ok(reportCsv(report, scope: scope));
  }

  Future<Result<List<int>>> _exportPdf() async {
    final report = _report;
    if (report == null) {
      return Result.error(Exception('Relatório não carregado'));
    }
    final settings = await _settingsRepository.getSettings();
    final organization = switch (settings) {
      Ok(:final value) => value.organization,
      Error() => '',
    };
    final bytes = await reportPdf(
      report,
      scope: scope,
      organization: organization,
      generatedAt: _clock(),
      theme: await loadPdfTheme(),
    );
    return Result.ok(bytes);
  }
}
