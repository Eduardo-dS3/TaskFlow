import 'package:pocketbase/pocketbase.dart';

/// Erro de comunicação com o servidor, com mensagem pronta para o usuário.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode = 0});

  /// Converte o erro do SDK do PocketBase em uma mensagem em português.
  factory ApiException.from(ClientException error) =>
      ApiException(_messageFor(error), statusCode: error.statusCode);

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}

const _fieldLabels = {
  'name': 'Nome',
  'email': 'E-mail',
  'password': 'Senha',
  'passwordConfirm': 'Confirmação de senha',
  'oldPassword': 'Senha atual',
  'title': 'Título',
  'file': 'Arquivo',
  'body': 'Comentário',
  'role': 'Cargo',
  'tier': 'Plano',
};

const _codeMessages = {
  'validation_not_unique': 'já está em uso',
  'validation_required': 'é obrigatório',
  'validation_invalid_email': 'não é um e-mail válido',
  'validation_invalid_old_password': 'está incorreta',
  'validation_values_mismatch': 'não confere',
  'validation_invalid_mime_type': 'tipo de arquivo não permitido',
  'validation_file_size_limit': 'excede o tamanho máximo de 25 MB',
};

String _messageFor(ClientException error) {
  if (error.statusCode == 0) {
    return 'Não foi possível conectar ao servidor. Verifique a rede.';
  }
  final serverMessage = error.response['message'];
  return switch (error.statusCode) {
        400 => _validationMessage(error.response) ?? _portuguese(serverMessage),
        401 => 'Sua sessão expirou. Entre novamente.',
        403 =>
          _portuguese(serverMessage) ??
              'Você não tem permissão para esta ação.',
        404 => 'Registro não encontrado ou sem permissão de acesso.',
        429 => 'Muitas tentativas seguidas. Aguarde alguns segundos.',
        _ =>
          'O servidor não conseguiu concluir a operação (${error.statusCode}).',
      } ??
      'Dados inválidos. Revise os campos e tente novamente.';
}

/// Mensagens dos hooks do TaskFlow já vêm em português; as do PocketBase
/// (em inglês) são substituídas por mensagens genéricas.
String? _portuguese(Object? message) {
  if (message is! String || message.isEmpty) return null;
  final isEnglish = RegExp(
    r'^(Failed|Something|The |Only|Missing|Invalid)',
  ).hasMatch(message);
  return isEnglish ? null : message;
}

/// Junta os erros de validação por campo em uma única frase.
String? _validationMessage(Map<String, dynamic> response) {
  final data = response['data'];
  if (data is! Map || data.isEmpty) return null;
  final parts = <String>[];
  data.forEach((field, detail) {
    final code = detail is Map ? detail['code'] : null;
    final label = _fieldLabels[field] ?? field.toString();
    final text = _codeMessages[code] ?? 'valor inválido';
    parts.add('$label: $text');
  });
  return parts.join('; ');
}
