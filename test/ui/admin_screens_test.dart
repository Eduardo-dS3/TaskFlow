import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:taskflow/ui/settings/view_models/settings_viewmodel.dart';
import 'package:taskflow/ui/settings/widgets/settings_screen.dart';
import 'package:taskflow/ui/team/view_models/team_viewmodel.dart';
import 'package:taskflow/ui/team/widgets/team_screen.dart';

import '../../testing/fakes/fake_repositories.dart';
import 'screens_test.dart' show pump;

/// Telas de Configurações e Equipe em desktop e celular, sem overflow.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  for (final size in const [Size(1440, 1000), Size(390, 844)]) {
    group('${size.width.toInt()}px', () {
      late FakeDependencies deps;

      setUp(() => deps = FakeDependencies());

      testWidgets('Configurações', (tester) async {
        await pump(
          tester,
          SettingsScreen(
            viewModel: SettingsViewModel(
              userRepository: deps.users,
              settingsRepository: deps.settings,
            ),
          ),
          size,
        );
        expect(find.text('Meu perfil'), findsOneWidget);
        expect(find.text('Organização'), findsOneWidget);
      });

      testWidgets('Equipe', (tester) async {
        await pump(
          tester,
          TeamScreen(
            viewModel: TeamViewModel(
              userRepository: deps.users,
              clock: testClock,
            ),
          ),
          size,
        );
        expect(find.text('Equipe'), findsOneWidget);
        expect(find.text('Mariana Souza (você)'), findsOneWidget);
      });
    });
  }
}
