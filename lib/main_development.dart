import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'main.dart';

/// Modo de demonstração: dados de exemplo em memória, sem servidor.
///
/// `flutter run -d chrome -t lib/main_development.dart`
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');

  runApp(
    MultiProvider(providers: providersLocal(), child: const TaskFlowApp()),
  );
}
