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
