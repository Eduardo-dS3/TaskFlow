import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Endereço do servidor, definido no build com
/// `--dart-define=API_URL=http://servidor:8090`.
///
/// Sem ele, o app usa o próprio endereço de onde foi aberto, que é o caso da
/// instalação padrão (o servidor entrega o app e a API na mesma porta).
const _apiUrlOverride = String.fromEnvironment('API_URL');

/// Versão exibida em "Ajuda", definida no build com `--dart-define`.
const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: 'dev');

const _authStorageKey = 'taskflow_auth';

String get apiBaseUrl =>
    _apiUrlOverride.isNotEmpty ? _apiUrlOverride : Uri.base.origin;

/// Cliente do PocketBase com a sessão persistida no navegador.
Future<PocketBase> createPocketBase() async {
  final prefs = await SharedPreferences.getInstance();
  final store = AsyncAuthStore(
    save: (data) => prefs.setString(_authStorageKey, data),
    initial: prefs.getString(_authStorageKey),
    clear: () => prefs.remove(_authStorageKey),
  );
  return PocketBase(apiBaseUrl, authStore: store, lang: 'pt-BR');
}
