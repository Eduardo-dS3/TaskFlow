@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:taskflow/data/repositories/auth/auth_repository_remote.dart';
import 'package:taskflow/data/repositories/project/project_repository_remote.dart';
import 'package:taskflow/data/repositories/settings/settings_repository_remote.dart';
import 'package:taskflow/data/repositories/task/task_repository_remote.dart';
import 'package:taskflow/data/repositories/user/user_repository.dart';
import 'package:taskflow/data/repositories/user/user_repository_remote.dart';
import 'package:taskflow/data/services/api/api_client.dart';
import 'package:taskflow/domain/models/member.dart';
import 'package:taskflow/domain/models/project.dart';
import 'package:taskflow/domain/models/task.dart';
import 'package:taskflow/domain/models/team_rules.dart';
import 'package:taskflow/domain/use_cases/load_board_use_case.dart';
import 'package:taskflow/utils/result.dart';

import '../../testing/pocketbase_test_server.dart';

/// Sessão de uma pessoa: cliente da API e repositórios remotos.
class _Session {
  _Session(String url) : api = ApiClient(PocketBase(url));

  final ApiClient api;
  late final auth = AuthRepositoryRemote(apiClient: api);
  late final tasks = TaskRepositoryRemote(apiClient: api);
  late final projects = ProjectRepositoryRemote(apiClient: api);
  late final users = UserRepositoryRemote(apiClient: api);
  late final settings = SettingsRepositoryRemote(apiClient: api);
}

T _ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Error(:final error) => throw TestFailure('Falhou: $error'),
};

String _error(Result<Object?> result) => switch (result) {
  Error(:final error) => error.toString(),
  Ok() => throw TestFailure('Era esperado um erro'),
};

void main() {
  final binary = findPocketBaseBinary();
  group(
    'Repositórios remotos (PocketBase real)',
    skip: binary == null
        ? 'Defina POCKETBASE_BIN ou baixe o PocketBase em server/'
        : false,
    () {
      PocketBaseTestServer? server;
      late _Session admin;

      setUpAll(() async {
        server = await PocketBaseTestServer.start(binary!);
        admin = _Session(server!.url);
      });
      tearDownAll(() => server?.stop());

      test('entra com o usuário padrão', () async {
        expect(_ok(await admin.auth.needsSetup()), isFalse);
        final wrong = await admin.auth.login(identity: 'sa', password: 'x');
        expect(_error(wrong), 'Usuário ou senha incorretos.');

        _ok(await admin.auth.login(identity: 'sa', password: defaultPassword));
        final me = _ok(await admin.users.getCurrentUser());
        expect(me.isAdmin, isTrue);
        expect(me.username, defaultUsername);
      });

      test('fluxo de projeto, tarefa, comentário e anexo', () async {
        await _taskFlow(admin);
      });

      test('equipe: cadastro, permissões e desativação', () async {
        await _teamFlow(admin, server!.url);
      });

      test('configurações e indicadores do quadro', () async {
        final settings = _ok(await admin.settings.getSettings());
        final saved = _ok(
          await admin.settings.saveSettings(
            settings.copyWith(activeSprint: 'Sprint 7'),
          ),
        );
        expect(saved.activeSprint, 'Sprint 7');

        final board = _ok(
          await LoadBoardUseCase(
            taskRepository: admin.tasks,
            userRepository: admin.users,
            settingsRepository: admin.settings,
          ).load(),
        );
        expect(board.overview.sprintName, 'Sprint 7');
        expect(board.overview.totalTasks, board.tasks.length);
      });
    },
  );
}

Future<void> _taskFlow(_Session admin) async {
  final me = _ok(await admin.users.getCurrentUser());
  final client = _ok(
    await admin.projects.saveClient(
      const Client(id: '', name: 'Banco Alfa', tier: ClientTier.enterprise),
    ),
  );
  final project = _ok(
    await admin.projects.saveProject(
      Project(
        id: '',
        name: 'Fintech Core',
        clientId: client.id,
        clientName: client.name,
        description: '',
        status: ProjectStatus.inProgress,
        kind: ProjectKind.api,
        team: [me],
      ),
    ),
  );
  expect(project.clientName, 'Banco Alfa');

  final draft = Task.draft(now: DateTime.now(), owner: me);
  final task = _ok(
    await admin.tasks.saveTask(
      draft.copyWith(
        title: 'Webhook Stripe',
        links: draft.links.withProject(
          id: project.id,
          name: project.name,
          clientName: client.name,
        ),
      ),
    ),
  );
  expect(task.code, 'TK-1001');
  expect(task.projectName, 'Fintech Core');

  final done = _ok(
    await admin.tasks.saveTask(
      task.withStatus(TaskStatus.done, now: DateTime.now()),
    ),
  );
  expect(done.completedAt, isNotNull);

  _ok(await admin.tasks.addComment(task.id, 'Primeiro comentário'));
  final attachment = _ok(
    await admin.tasks.uploadAttachment(
      task.id,
      fileName: 'dados.json',
      bytes: '{"ok":true}'.codeUnits,
    ),
  );
  final url = _ok(await admin.tasks.attachmentUrl(attachment));
  expect((await http.get(url)).body, '{"ok":true}');

  final loaded = _ok(await admin.tasks.getTask(task.id));
  expect(loaded.commentCount, 1);
  expect(loaded.comments.single.author.id, me.id);
  expect(loaded.attachments.single.name, 'dados.json');

  _ok(await admin.tasks.deleteAttachment(attachment));
  _ok(await admin.tasks.deleteTask(task.id));
}

Future<void> _teamFlow(_Session admin, String url) async {
  final joana = _ok(
    await admin.users.createMember(
      const NewMember(
        name: 'Joana Prado',
        email: 'joana@empresa.com',
        username: 'joana',
        role: 'QA',
        password: 'SenhaForte#1',
      ),
    ),
  );

  final member = _Session(url);
  _ok(await member.auth.login(identity: 'joana', password: 'SenhaForte#1'));
  final forbidden = await member.users.createMember(
    const NewMember(
      name: 'X',
      email: 'x@empresa.com',
      role: '',
      password: 'SenhaForte#1',
    ),
  );
  expect(forbidden, isA<Error<Member>>());

  final self = _ok(await admin.users.getCurrentUser());
  final demote = await admin.users.updateMember(self.copyWith(isAdmin: false));
  expect(_error(demote), contains(lastAdminMessage));

  _ok(await admin.users.updateMember(joana.copyWith(active: false)));
  final blocked = await _Session(
    url,
  ).auth.login(identity: 'joana', password: 'SenhaForte#1');
  expect(_error(blocked), contains('desativada'));
}
