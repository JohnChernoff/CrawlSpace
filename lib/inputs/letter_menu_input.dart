import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../fugue_model.dart';

abstract class LetterMenuInput extends StatelessWidget {
  final Widget child;
  final FugueModel fm;

  const LetterMenuInput(this.child, this.fm, {super.key});

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    final char = event.character?.toLowerCase();

    // Handle escape/cancel
    if (event.logicalKey == LogicalKeyboardKey.keyX) { print("X handled");
      fm.menuController.exitMode();
      return KeyEventResult.handled;
    }

    if (char != null && char.length == 1) {
      handleLetter(char);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void handleLetter(String letter);

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent:  _handleKey,
      child: child,
    );
  }
}