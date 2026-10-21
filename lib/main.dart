import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'config/server_config.dart';
import 'data/repositories/auth/auth_repository.dart';
import 'data/repositories/auth/auth_repository_remote.dart';
import 'data/services/api/api_client.dart';
import 'routing/router.dart';
import 'ui/core/themes/theme.dart';

/// Ponto de entrada de produção: dados no servidor do TaskFlow.
///
/// Para o modo de demonstração (dados de exemplo, sem servidor), use
/// `flutter run -t lib/main_development.dart`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');

  final apiClient = ApiClient(await createPocketBase());
  final authRepository = AuthRepositoryRemote(apiClient: apiClient);
  await authRepository.restoreSession();

  runApp(
    MultiProvider(
      providers: providersRemote(
        apiClient: apiClient,
        authRepository: authRepository,
      ),
      child: const TaskFlowApp(),
    ),
  );
}

class TaskFlowApp extends StatefulWidget {
  const TaskFlowApp({super.key});

  @override
  State<TaskFlowApp> createState() => _TaskFlowAppState();
}

class _TaskFlowAppState extends State<TaskFlowApp> {
  late final GoRouter _router = router(context.read<AuthRepository>());

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: _router,
    );
  }
}
