import '../../../domain/models/productivity_report.dart';
import '../../../utils/result.dart';
import '../../services/local/local_data_service.dart';
import 'report_repository.dart';

class ReportRepositoryLocal implements ReportRepository {
  ReportRepositoryLocal({
    required LocalDataService localDataService,
    this._latency = const Duration(milliseconds: 400),
  }) : _service = localDataService;

  final LocalDataService _service;
  final Duration _latency;

  // Cache em memória por período: o repositório é a fonte da verdade.
  final Map<ReportPeriod, ProductivityReport> _cache = {};

  @override
  Future<Result<ProductivityReport>> getReport(ReportPeriod period) async {
    final cached = _cache[period];
    if (cached != null) return Result.ok(cached);

    await Future.delayed(_latency);
    final report = _service.report(period);
    _cache[period] = report;
    return Result.ok(report);
  }
}
