import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/domain/models/member.dart';
import 'package:taskflow/ui/settings/view_models/settings_viewmodel.dart';

import '../../../testing/fakes/fake_repositories.dart';

void main() {
  late FakeDependencies deps;
  late SettingsViewModel viewModel;

  setUp(() async {
    deps = FakeDependencies();
    viewModel = SettingsViewModel(
      userRepository: deps.users,
      settingsRepository: deps.settings,
    );
    await pumpEventQueue();
  });

  test('carrega o usuário e as configurações', () {
    expect(viewModel.user?.name, 'Mariana Souza');
    expect(viewModel.isAdmin, isTrue);
    expect(viewModel.settings.activeSprint, isNotEmpty);
  });

  test(
    'salvar o perfil atualiza o usuário e avisa o restante do app',
    () async {
      final changes = <Member>[];
      final subscription = deps.users.currentUserChanges.listen(changes.add);

      await viewModel.saveProfile.execute((name: 'Mariana S.', role: 'CTO'));
      await pumpEventQueue();

      expect(viewModel.saveProfile.completed, isTrue);
      expect(viewModel.user?.role, 'CTO');
      expect(changes.single.name, 'Mariana S.');
      await subscription.cancel();
    },
  );

  test('não salva perfil sem nome', () async {
    await viewModel.saveProfile.execute((name: ' ', role: 'CTO'));
    expect(viewModel.saveProfile.error, isTrue);
  });

  test('salva organização e sprint ativa', () async {
    await viewModel.saveOrganization.execute((
      organization: 'Acme',
      activeSprint: 'Sprint 30',
    ));
    expect(viewModel.settings.organization, 'Acme');
    expect(viewModel.settings.activeSprint, 'Sprint 30');
  });

  test('troca a senha', () async {
    await viewModel.changePassword.execute((current: 'a', next: 'SenhaNova#1'));
    expect(viewModel.changePassword.completed, isTrue);
  });
}
