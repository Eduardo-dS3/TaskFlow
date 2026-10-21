import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:taskflow/domain/models/productivity_report.dart';
import 'package:taskflow/ui/reports/view_models/reports_viewmodel.dart';
import 'package:taskflow/utils/result.dart';

import '../../../testing/fakes/fake_repositories.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  late ReportsViewModel viewModel;

  setUp(() async {
    final deps = FakeDependencies();
    viewModel = ReportsViewModel(
      buildReport: deps.buildReport,
      projectRepository: deps.projects,
      settingsRepository: deps.settings,
      clock: testClock,
    );
    await pumpEventQueue();
  });

  test('calcula o relatório a partir das tarefas', () {
    final report = viewModel.report!;
    expect(report.finishedTasks, 2);
    expect(report.totalMembers, 10);
    expect(viewModel.visibleMembers, hasLength(ReportsViewModel.pageSize));
    expect(viewModel.scope, 'Todos os projetos');
  });

  test('troca de período e filtra por projeto', () async {
    viewModel.selectPeriod(ReportPeriod.year);
    await pumpEventQueue();
    expect(viewModel.period, ReportPeriod.year);

    viewModel.selectProject('p-1');
    await pumpEventQueue();
    expect(viewModel.report!.finishedTasks, 1);
    expect(viewModel.scope, contains('App Mobile'));
  });

  test('exporta CSV e PDF', () async {
    await viewModel.exportCsv.execute();
    final csv = (viewModel.exportCsv.result as Ok<List<int>>).value;
    expect(utf8.decode(csv.skip(3).toList()), contains('Entregas no prazo'));

    await viewModel.exportPdf.execute();
    final pdf = (viewModel.exportPdf.result as Ok<List<int>>).value;
    expect(ascii.decode(pdf.take(4).toList()), '%PDF');
  });
}
