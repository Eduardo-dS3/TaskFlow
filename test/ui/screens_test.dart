import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:taskflow/ui/board/view_models/board_viewmodel.dart';
import 'package:taskflow/ui/board/widgets/board_screen.dart';
import 'package:taskflow/ui/core/themes/theme.dart';
import 'package:taskflow/ui/projects/view_models/projects_viewmodel.dart';
import 'package:taskflow/ui/projects/widgets/projects_screen.dart';
import 'package:taskflow/ui/reports/view_models/reports_viewmodel.dart';
import 'package:taskflow/ui/reports/widgets/reports_screen.dart';
import 'package:taskflow/ui/task_details/view_models/task_details_viewmodel.dart';
import 'package:taskflow/ui/task_details/widgets/task_details_screen.dart';

import '../../testing/fakes/fake_repositories.dart';

/// Testes de widget: cada tela é renderizada com repositórios falsos em
/// larguras de desktop e celular, garantindo que não há overflow.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<void> pump(WidgetTester tester, Widget screen, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final size in const [Size(1440, 1000), Size(390, 844)]) {
    group('${size.width.toInt()}px', () {
      testWidgets('Quadro de tarefas', (tester) async {
        await pump(
          tester,
          BoardScreen(
            viewModel: BoardViewModel(
              taskRepository: FakeTaskRepository(),
              clock: testClock,
            ),
          ),
          size,
        );
        expect(find.text('Refatoração da autenticação JWT'), findsOneWidget);
        expect(find.text('Amanhã'), findsOneWidget);
      });

      testWidgets('Detalhes da tarefa', (tester) async {
        final service = fakeDataService();
        await pump(
          tester,
          TaskDetailsScreen(
            viewModel: TaskDetailsViewModel(
              taskRepository: FakeTaskRepository(service),
              userRepository: fakeUserRepository(service),
              projectRepository: fakeProjectRepository(service),
              taskId: 't-1048',
              clock: testClock,
            ),
          ),
          size,
        );
        expect(find.text('Checklist & Subtarefas'), findsOneWidget);
        expect(find.text('Salvar Alterações'), findsOneWidget);
      });

      testWidgets('Projetos & Clientes', (tester) async {
        await pump(
          tester,
          ProjectsScreen(
            viewModel: ProjectsViewModel(
              projectRepository: fakeProjectRepository(),
              clock: testClock,
            ),
          ),
          size,
        );
        expect(find.text('Projetos & Clientes'), findsOneWidget);
        expect(find.text('Clientes Ativos'), findsOneWidget);
      });

      testWidgets('Relatórios', (tester) async {
        await pump(
          tester,
          ReportsScreen(
            viewModel: ReportsViewModel(
              reportRepository: fakeReportRepository(),
            ),
          ),
          size,
        );
        expect(find.text('Relatórios de Produtividade'), findsOneWidget);
      });
    });
  }
}
