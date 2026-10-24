/// Validações dos campos de formulário.
abstract final class Validators {
  static const minPasswordLength = 8;

  static String? required(String? value, String label) =>
      value == null || value.trim().isEmpty ? 'Informe $label.' : null;

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Informe o e-mail.';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    return valid ? null : 'E-mail inválido.';
  }

  /// Nome de usuário opcional: letras, números, ponto, hífen e sublinhado.
  static String? username(String? value) {
    final text = value?.trim() ?? '';
    final valid = RegExp(r'^[a-zA-Z0-9._-]*$').hasMatch(text);
    return valid ? null : 'Use só letras, números, ponto, hífen ou sublinhado.';
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Informe a senha.';
    return value.length < minPasswordLength
        ? 'A senha precisa ter pelo menos $minPasswordLength caracteres.'
        : null;
  }

  /// Confere se a confirmação é igual à senha informada.
  static String? confirmation(String? value, String password) =>
      value == password ? null : 'As senhas não conferem.';

  /// Número decimal maior ou igual a zero (aceita vírgula).
  static String? hours(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final number = parseNumber(text);
    return number == null || number < 0 ? 'Valor inválido.' : null;
  }

  static double? parseNumber(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));
}
