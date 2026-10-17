import 'package:flutter/foundation.dart';

import '../../../data/repositories/report/report_repository.dart';
import '../../../domain/models/productivity_report.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel({required this._reportRepository}) {
    load = Command1(_load)..execute(ReportPeriod.last30Days);
    exportPdf = Command0(_exportPdf);
  }

  final ReportRepository _reportRepository;

  /// Carrega o relatório do período informado.
  late final Command1<void, ReportPeriod> load;

  late final Command0<void> exportPdf;

  static const pageSize = 5;

  ProductivityReport? _report;
  ProductivityReport? get report => _report;

  ReportPeriod _period = ReportPeriod.last30Days;
  ReportPeriod get period => _period;

  int _page = 0;
  int get page => _page;

  int get pageCount {
    final total = _report?.members.length ?? 0;
    return (total / pageSize).ceil().clamp(1, 999);
  }

  List<MemberPerformance> get visibleMembers =>
      _report?.members.skip(_page * pageSize).take(pageSize).toList() ?? [];

  void selectPeriod(ReportPeriod period) {
    if (period == _period) return;
    load.execute(period);
  }

  void setPage(int page) {
    _page = page.clamp(0, pageCount - 1);
    notifyListeners();
  }

  void retry() => load.execute(_period);

  Future<Result<void>> _load(ReportPeriod period) async {
    _period = period;
    notifyListeners();

    final result = await _reportRepository.getReport(period);
    switch (result) {
      case Ok():
        _report = result.value;
        _page = 0;
      case Error():
        debugPrint('Falha ao carregar relatório: ${result.error}');
    }
    notifyListeners();
    return result;
  }

  Future<Result<void>> _exportPdf() async {
    // Simula a geração do documento executivo.
    await Future.delayed(const Duration(seconds: 1));
    return const Result.ok(null);
  }
}
