import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Tema do PDF com a Roboto embutida no app: cobre acentos e símbolos que a
/// Helvetica padrão do PDF não tem. Sem as fontes, usa o tema padrão.
Future<pw.ThemeData> loadPdfTheme({AssetBundle? bundle}) async {
  final assets = bundle ?? rootBundle;
  Future<pw.Font> font(String name) async =>
      pw.Font.ttf(await assets.load('assets/fonts/Roboto-$name.ttf'));
  try {
    return pw.ThemeData.withFont(
      base: await font('Regular'),
      bold: await font('Bold'),
      italic: await font('Italic'),
    );
  } on FlutterError {
    return pw.ThemeData.base();
  }
}
