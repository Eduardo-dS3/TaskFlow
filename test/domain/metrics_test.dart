import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/domain/metrics/board_metrics.dart';
import 'package:taskflow/domain/metrics/portfolio_metrics.dart';
import 'package:taskflow/domain/metrics/report_metrics.dart';
import 'package:taskflow/domain/metrics/task_metrics.dart';
import 'package:taskflow/domain/models/member.dart';
import 'package:taskflow/domain/models/productivity_report.dart';
import 'package:taskflow/domain/models/project.dart';
import 'package:taskflow/domain/models/task.dart';
import 'package:taskflow/domain/models/team_rules.dart';

final _now = DateTime(2024, 10, 18, 10);
const _ana = Member(id: 'a', name: 'Ana Lima', role: 'Dev', isAdmin: true);
const _beto = Member(id: 'b', name: 'Beto Reis', role: 'Dev');

Task _task(
  String id, {
  TaskStatus status = TaskStatus.pending,
  DateTime? created,
  DateTime? due,
  DateTime? completed,
  double estimated = 0,
  List<Member> people = const [],
  String? projectId,
}) => Task(
  id: id,
  code: id,
  title: id,
  summary: '',
  status: status,
  priority: TaskPriority.medium,
  category: 'Geral',
  createdAt: created,
  dueDate: due,
  completedAt: completed,
  estimatedHours: estimated,
  assignees: people,
  projectId: projectId,
  projectName: projectId == null ? null : 'Projeto $projectId',
);

void main() {
  group('prazos', _deadlineTests);
  group('quadro e portfólio', _boardAndPortfolioTests);
  group('relatório e equipe', _reportAndTeamTests);
}

void _deadlineTests() {
  test('conclusão no próprio dia do prazo conta como no prazo', () {
    final onTime = _task(
      '1',
      status: TaskStatus.done,
      due: DateTime(2024, 10, 10),
      completed: DateTime(2024, 10, 10, 23, 59),
    );
    final late = _task(
      '2',
      status: TaskStatus.done,
      due: DateTime(2024, 10, 10),
      completed: DateTime(2024, 10, 11, 0, 1),
    );
    expect(completedOnTime(onTime), isTrue);
    expect(completedOnTime(late), isFalse);
    expect(onTimeRate([onTime, late]), 0.5);
    expect(onTimeRate([_task('3')]), isNull);
  });

  test('tarefa atrasada é a aberta com prazo antes de hoje', () {
    expect(_task('1', due: DateTime(2024, 10, 17)).isOverdue(_now), isTrue);
    expect(_task('2', due: DateTime(2024, 10, 18)).isOverdue(_now), isFalse);
  });
}

void _boardAndPortfolioTests() {
  test('indicadores do quadro', () {
    final overview = computeSprintOverview(
      tasks: [
        _task('1', due: DateTime(2024, 10, 1), created: DateTime(2024, 10, 2)),
        _task(
          '2',
          status: TaskStatus.inProgress,
          estimated: 20,
          people: [_ana],
          created: DateTime(2024, 9, 5),
        ),
      ],
      members: [_ana, _beto],
      activeSprint: 'S1',
      now: _now,
    );
    expect(overview.pending, 1);
    expect(overview.inProgress, 1);
    expect(overview.overdue, 1);
    expect(overview.allocatedDevs, 1);
    expect(overview.teamCapacity, 20 / 80);
    expect(overview.monthGrowth, 0, reason: '1 em outubro e 1 em setembro');
  });

  test('totais por projeto e horas divididas por pessoa', () {
    const project = Project(
      id: 'p',
      name: 'Projeto p',
      clientName: 'Interno',
      description: '',
      status: ProjectStatus.inProgress,
      kind: ProjectKind.web,
    );
    final tasks = [
      _task('1', projectId: 'p', status: TaskStatus.done),
      _task(
        '2',
        projectId: 'p',
        status: TaskStatus.inProgress,
        estimated: 10,
        people: [_ana, _beto],
      ),
    ];
    final counted = withTaskCounts([project], tasks).single;
    expect(counted.totalTasks, 2);
    expect(counted.progress, 0.5);

    final allocations = computeAllocations(
      tasks: tasks,
      members: [_ana, _beto],
    );
    expect(allocations.map((a) => a.allocatedHours), [5, 5]);
  });
}

void _reportAndTeamTests() {
  test('períodos, concluídas e vazão líquida', () {
    expect(ReportPeriod.quarter.startFrom(_now), DateTime(2024, 10));
    expect(ReportPeriod.year.startFrom(_now), DateTime(2024));
    final report = computeReport(
      tasks: [
        _task(
          '1',
          status: TaskStatus.done,
          created: DateTime(2024, 10, 1),
          completed: DateTime(2024, 10, 3),
        ),
        _task('2', created: DateTime(2024, 10, 5)),
        _task('3', created: DateTime(2024, 10, 6)),
      ],
      members: [_ana],
      period: ReportPeriod.last30Days,
      activeSprint: '',
      now: _now,
    );
    expect(report.finishedTasks, 1);
    expect(report.activeTasks, 3);
    expect(report.averageResolutionDays, 2);
    expect(report.netThroughput, 1 - 3);
    expect(report.weeklyThroughput, hasLength(throughputWeeks));
  });

  test('regra do último administrador ativo', () {
    final team = [_ana, _beto];
    expect(keepsActiveAdmin(team, _ana.copyWith(isAdmin: false)), isFalse);
    expect(keepsActiveAdmin(team, _beto.copyWith(isAdmin: true)), isTrue);
    final twoAdmins = [_ana, _beto.copyWith(isAdmin: true)];
    expect(keepsActiveAdmin(twoAdmins, _ana.copyWith(active: false)), isTrue);
  });
}
