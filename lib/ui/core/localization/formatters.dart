import 'package:intl/intl.dart';

import '../../../domain/models/productivity_report.dart';
import '../../../domain/models/project.dart';
import '../../../domain/models/task.dart';

/// Textos e formatações de exibição (camada de UI).
abstract final class Formatters {
  static final _shortDate = DateFormat('dd MMM', 'pt_BR');
  static final _fullDate = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _time = DateFormat('HH:mm', 'pt_BR');

  /// "25 Out"
  static String shortDate(DateTime date) {
    final text = _shortDate.format(date).replaceAll('.', '');
    final parts = text.split(' ');
    final month = parts.last;
    return '${parts.first} ${month[0].toUpperCase()}${month.substring(1)}';
  }

  /// "18/10/2024"
  static String fullDate(DateTime date) => _fullDate.format(date);

  static String percent(double value, {int decimals = 0}) =>
      '${(value * 100).toStringAsFixed(decimals)}%';

  static String signedPercent(double value, {int decimals = 1}) =>
      '${value >= 0 ? '+' : ''}${(value * 100).toStringAsFixed(decimals)}%';

  static String fileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).round()} KB';
  }

  static String hours(double value) =>
      value == value.roundToDouble() ? '${value.toInt()}h' : '${value}h';

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Prazo relativo exibido nos cards: "Hoje", "Amanhã", "3 dias" ou "25 Out".
  static String dueLabel(DateTime due, DateTime now) {
    final diff = _day(due).difference(_day(now)).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    if (diff > 1 && diff <= 5) return '$diff dias';
    return shortDate(due);
  }

  /// "Concluído hoje", "Concluído ontem", "Concluído em 12 Out".
  static String completedLabel(DateTime date, DateTime now) {
    final diff = _day(now).difference(_day(date)).inDays;
    if (diff == 0) return 'Concluído hoje';
    if (diff == 1) return 'Concluído ontem';
    return 'Concluído em ${shortDate(date)}';
  }

  /// "há 3 horas", "ontem às 16:45".
  static String relativeTime(DateTime date, DateTime now) {
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (_day(date) == _day(now)) {
      return 'há ${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'}';
    }
    if (_day(now).difference(_day(date)).inDays == 1) {
      return 'ontem às ${_time.format(date)}';
    }
    return '${shortDate(date)} às ${_time.format(date)}';
  }

  static String taskStatus(TaskStatus status) => switch (status) {
    TaskStatus.pending => 'Pendentes',
    TaskStatus.inProgress => 'Em Andamento',
    TaskStatus.done => 'Concluídas',
  };

  static String taskStatusSingular(TaskStatus status) => switch (status) {
    TaskStatus.pending => 'Pendente',
    TaskStatus.inProgress => 'Em Andamento',
    TaskStatus.done => 'Concluída',
  };

  static String priority(TaskPriority priority) => switch (priority) {
    TaskPriority.urgent => 'Urgente',
    TaskPriority.high => 'Alta',
    TaskPriority.medium => 'Média',
    TaskPriority.low => 'Baixa',
  };

  static String subtaskStage(SubtaskStage stage) => switch (stage) {
    SubtaskStage.queued => 'Fila de saída',
    SubtaskStage.readyForTest => 'Pronto p/ teste',
    SubtaskStage.resolved => 'Resolvido',
  };

  static String projectStatus(ProjectStatus status) => switch (status) {
    ProjectStatus.inProgress => 'Em Andamento',
    ProjectStatus.done => 'Concluído',
    ProjectStatus.paused => 'Pausado',
  };

  static String projectKind(ProjectKind kind) => switch (kind) {
    ProjectKind.mobile => 'Aplicativo mobile',
    ProjectKind.web => 'Plataforma web',
    ProjectKind.fiscal => 'Fiscal / financeiro',
    ProjectKind.landing => 'Site / landing page',
    ProjectKind.api => 'API / backend',
    ProjectKind.report => 'Relatórios / BI',
    ProjectKind.other => 'Outro',
  };

  static String clientTier(ClientTier tier) => switch (tier) {
    ClientTier.enterprise => 'Enterprise',
    ClientTier.pro => 'Pro',
    ClientTier.custom => 'Custom',
    ClientTier.maintenance => 'Manutenção',
  };

  static String reportPeriod(ReportPeriod period) => switch (period) {
    ReportPeriod.last30Days => 'Últimos 30 dias',
    ReportPeriod.quarter => 'Este trimestre',
    ReportPeriod.year => 'Ano atual',
  };

  /// Percentual opcional: "—" quando não há dados para calcular.
  static String optionalPercent(double? value, {int decimals = 0}) =>
      value == null ? '—' : percent(value, decimals: decimals);

  static String workload(WorkloadLevel level) => switch (level) {
    WorkloadLevel.stable => 'Estável',
    WorkloadLevel.balanced => 'Equilibrada',
    WorkloadLevel.optimized => 'Otimizada',
    WorkloadLevel.overloaded => 'Sobrecarga',
    WorkloadLevel.validating => 'Em Validação',
  };
}
