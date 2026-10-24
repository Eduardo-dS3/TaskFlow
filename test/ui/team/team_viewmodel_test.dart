import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/data/repositories/user/user_repository.dart';
import 'package:taskflow/domain/models/team_rules.dart';
import 'package:taskflow/ui/team/view_models/team_viewmodel.dart';
import 'package:taskflow/utils/result.dart';

import '../../../testing/fakes/fake_repositories.dart';

void main() {
  late TeamViewModel viewModel;

  setUp(() async {
    final deps = FakeDependencies();
    viewModel = TeamViewModel(userRepository: deps.users, clock: testClock);
    await pumpEventQueue();
  });

  const newMember = NewMember(
    name: 'Joana Prado',
    email: 'joana@empresa.com',
    role: 'QA',
    password: 'SenhaForte#1',
  );

  test('carrega a equipe e identifica o administrador logado', () {
    expect(viewModel.members, hasLength(10));
    expect(viewModel.isAdmin, isTrue);
    expect(viewModel.isSelf(viewModel.currentUser!), isTrue);
  });

  test('cadastra pessoa e recusa e-mail repetido', () async {
    await viewModel.createMember.execute(newMember);
    expect(viewModel.members.map((m) => m.name), contains('Joana Prado'));

    await viewModel.createMember.execute(newMember);
    expect(viewModel.createMember.error, isTrue);
  });

  test('desativa e reativa uma conta', () async {
    final other = viewModel.members.firstWhere((m) => !m.isAdmin);
    await viewModel.toggleActive.execute(other);
    expect(viewModel.activeCount, 9);
    expect(viewModel.members.last.id, other.id, reason: 'inativos no fim');

    await viewModel.toggleActive.execute(viewModel.members.last);
    expect(viewModel.activeCount, 10);
  });

  test('não deixa a equipe sem administrador ativo', () async {
    final admin = viewModel.currentUser!;
    await viewModel.updateMember.execute(admin.copyWith(isAdmin: false));

    final result = viewModel.updateMember.result;
    expect(result, isA<Error<void>>());
    expect(
      (result! as Error<void>).error.toString(),
      contains(lastAdminMessage),
    );
  });

  test('redefine a senha de outra pessoa', () async {
    final other = viewModel.members.firstWhere((m) => !m.isAdmin);
    await viewModel.resetPassword.execute((
      member: other,
      password: 'SenhaNova#1',
    ));
    expect(viewModel.resetPassword.completed, isTrue);
  });
}
