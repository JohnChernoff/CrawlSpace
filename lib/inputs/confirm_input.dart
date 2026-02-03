import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../fugue_model.dart';

enum ConfirmAction {
  yes,no,cancel
}

class ConfirmIntent extends Intent {
  final ConfirmAction action;
  const ConfirmIntent(this.action);
}

class ConfirmInput extends StatelessWidget {
  final Widget child;
  final FugueModel fm;

  const ConfirmInput(this.child, this.fm, {super.key});

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.keyY):
        const ConfirmIntent(ConfirmAction.yes),
        LogicalKeySet(LogicalKeyboardKey.keyN):
        const ConfirmIntent(ConfirmAction.no),
        LogicalKeySet(LogicalKeyboardKey.keyC):
        const ConfirmIntent(ConfirmAction.cancel),
        LogicalKeySet(LogicalKeyboardKey.keyX): //passes through somehow to letter_menu_input
        const ConfirmIntent(ConfirmAction.cancel),
      },
      actions: {
        ConfirmIntent: CallbackAction<ConfirmIntent>(
            onInvoke: (intent) {
              fm.menuController.confirmationCompleter?.complete(intent.action);
              return null;
            }),
      },
      child: child,
    );
  }
}
