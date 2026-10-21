import 'package:flutter/material.dart';

import '../../core/localization/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/validators.dart';

/// Horas estimadas e registradas de uma tarefa.
typedef TaskHours = ({double estimated, double logged});

/// Edita a estimativa e registra horas trabalhadas. `null` se cancelado.
Future<TaskHours?> showHoursDialog(
  BuildContext context, {
  required double estimated,
  required double logged,
}) => showDialog<TaskHours>(
  context: context,
  builder: (context) => _HoursDialog(estimated: estimated, logged: logged),
);

class _HoursDialog extends StatefulWidget {
  const _HoursDialog({required this.estimated, required this.logged});

  final double estimated;
  final double logged;

  @override
  State<_HoursDialog> createState() => _HoursDialogState();
}

class _HoursDialogState extends State<_HoursDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _estimated = TextEditingController(
    text: _format(widget.estimated),
  );
  final _worked = TextEditingController();

  static String _format(double value) =>
      value == value.roundToDouble() ? '${value.toInt()}' : '$value';

  @override
  void dispose() {
    _estimated.dispose();
    _worked.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final estimated = Validators.parseNumber(_estimated.text) ?? 0;
    final worked = Validators.parseNumber(_worked.text) ?? 0;
    Navigator.pop(context, (
      estimated: estimated,
      logged: widget.logged + worked,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Horas da tarefa'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _estimated,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Estimativa total (horas)',
                ),
                validator: Validators.hours,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _worked,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Registrar horas trabalhadas agora',
                  hintText: 'Ex.: 1,5',
                ),
                validator: Validators.hours,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              Text(
                'Já registradas: ${Formatters.hours(widget.logged)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Aplicar')),
      ],
    );
  }
}
