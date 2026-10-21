import 'package:pocketbase/pocketbase.dart';

/// Conversões comuns entre os registros do PocketBase e o domínio.

/// Datas chegam em UTC ("2026-10-21 02:11:21.931Z"); vazias viram `null`.
DateTime? parseDate(String value) =>
    value.isEmpty ? null : DateTime.tryParse(value)?.toLocal();

/// Datas são enviadas em UTC; `null` limpa o campo no servidor.
String formatDate(DateTime? date) =>
    date == null ? '' : date.toUtc().toIso8601String();

String? nonEmpty(String value) => value.isEmpty ? null : value;

T enumByName<T extends Enum>(List<T> values, String name, T fallback) =>
    values.asNameMap()[name] ?? fallback;

T? enumOrNull<T extends Enum>(List<T> values, String name) =>
    values.asNameMap()[name];

/// Registros expandidos de uma relação (`expand=campo`). Relações simples
/// vêm como uma lista de um item.
List<RecordModel> expanded(RecordModel record, String field) =>
    record.get<List<RecordModel>>('expand.$field', const <RecordModel>[]);

RecordModel? expandedOne(RecordModel record, String field) {
  final items = expanded(record, field);
  return items.isEmpty ? null : items.first;
}

/// Lista de textos de um campo JSON.
List<String> stringList(Object? value) =>
    value is List ? [for (final item in value) item.toString()] : const [];
