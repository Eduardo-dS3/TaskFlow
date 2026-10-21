import 'dart:convert';

/// Gera um CSV no padrão do Excel em português: separador ";" e BOM UTF-8
/// (para os acentos aparecerem corretamente).
List<int> buildCsv(List<List<Object?>> rows) {
  final text = rows.map((row) => row.map(_cell).join(';')).join('\r\n');
  return [0xEF, 0xBB, 0xBF, ...utf8.encode(text)];
}

String _cell(Object? value) {
  final text = value?.toString() ?? '';
  final needsQuotes = text.contains(RegExp(r'[;"\r\n]'));
  return needsQuotes ? '"${text.replaceAll('"', '""')}"' : text;
}
