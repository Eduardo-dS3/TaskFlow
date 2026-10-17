import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/domain/models/productivity_report.dart';
import 'package:taskflow/ui/reports/view_models/reports_viewmodel.dart';

import '../../../testing/fakes/fake_repositories.dart';

void main() {
  test('ReportsViewModel troca de período e recarrega', () async {
    final viewModel = ReportsViewModel(
      reportRepository: fakeReportRepository(),
    );
    await pumpEventQueue();

    expect(viewModel.report?.finishedTasks, 148);
    expect(viewModel.visibleMembers, hasLength(5));

    viewModel.selectPeriod(ReportPeriod.quarter);
    await pumpEventQueue();

    expect(viewModel.period, ReportPeriod.quarter);
    expect(viewModel.report?.finishedTasks, greaterThan(148));
  });
}
