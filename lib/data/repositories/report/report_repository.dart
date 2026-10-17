import '../../../domain/models/productivity_report.dart';
import '../../../utils/result.dart';

/// Fonte da verdade para os indicadores de produtividade.
abstract class ReportRepository {
  Future<Result<ProductivityReport>> getReport(ReportPeriod period);
}
