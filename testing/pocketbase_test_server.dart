import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Credenciais padrão criadas pela migration do servidor.
const defaultUsername = 'sa';
const defaultEmail = 'sa@taskflow.local';
const defaultPassword = '256318';

/// Executável do PocketBase para os testes de integração: a variável de
/// ambiente `POCKETBASE_BIN` ou o binário baixado em `server/`.
String? findPocketBaseBinary() {
  final fromEnv = Platform.environment['POCKETBASE_BIN'];
  final candidates = [
    if (fromEnv != null && fromEnv.isNotEmpty) fromEnv,
    'server/pocketbase.exe',
    'server/pocketbase',
  ];
  for (final path in candidates) {
    final file = File(path);
    if (file.existsSync()) return file.absolute.path;
  }
  return null;
}

/// Servidor PocketBase temporário com o esquema e os hooks do TaskFlow.
class PocketBaseTestServer {
  PocketBaseTestServer._(this._process, this._dataDir, this.url);

  final Process _process;
  final Directory _dataDir;
  final String url;

  static Future<PocketBaseTestServer> start(String binary) async {
    final dataDir = await Directory.systemTemp.createTemp('taskflow_it_');
    final port = await _freePort();
    final args = [
      '--dir=${dataDir.path}${Platform.pathSeparator}pb_data',
      '--migrationsDir=server${Platform.pathSeparator}pb_migrations',
      '--hooksDir=server${Platform.pathSeparator}pb_hooks',
      '--dev=false',
    ];
    final migrate = await Process.run(binary, ['migrate', 'up', ...args]);
    if (migrate.exitCode != 0) {
      throw StateError('Falha nas migrations: ${migrate.stderr}');
    }
    final process = await Process.start(binary, [
      'serve',
      '--http=127.0.0.1:$port',
      '--automigrate=false',
      ...args,
    ]);
    process.stdout.drain<void>();
    process.stderr.drain<void>();
    final server = PocketBaseTestServer._(
      process,
      dataDir,
      'http://127.0.0.1:$port',
    );
    await server._waitUntilHealthy();
    await server._disableRateLimits();
    return server;
  }

  Future<void> stop() async {
    _process.kill();
    await _process.exitCode;
    // O Windows pode manter o banco travado por alguns instantes.
    for (var attempt = 0; attempt < 10; attempt++) {
      try {
        await _dataDir.delete(recursive: true);
        return;
      } on FileSystemException {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  Future<void> _waitUntilHealthy() async {
    for (var attempt = 0; attempt < 50; attempt++) {
      try {
        final response = await http.get(Uri.parse('$url/api/health'));
        if (response.statusCode == 200) return;
      } on Exception {
        // Ainda subindo.
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    throw StateError('O PocketBase não respondeu em $url');
  }

  /// Os testes fazem vários logins seguidos; o limite de tentativas da
  /// instalação real atrapalharia aqui.
  Future<void> _disableRateLimits() async {
    final auth = await http.post(
      Uri.parse('$url/api/collections/_superusers/auth-with-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identity': defaultEmail, 'password': defaultPassword}),
    );
    final token = (jsonDecode(auth.body) as Map<String, dynamic>)['token'];
    await http.patch(
      Uri.parse('$url/api/settings'),
      headers: {'Content-Type': 'application/json', 'Authorization': '$token'},
      body: jsonEncode({
        'rateLimits': {'enabled': false},
      }),
    );
  }

  static Future<int> _freePort() async {
    final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = socket.port;
    await socket.close();
    return port;
  }
}
