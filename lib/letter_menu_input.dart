import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'fugue_model.dart';

abstract class LetterMenuInput extends StatelessWidget {
  final Widget child;
  final FugueModel fm;

  const LetterMenuInput(this.child, this.fm, {super.key});

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {

    final char = event.character?.toLowerCase();

    // Check if it's a letter a-m
    if (char != null && char.length == 1) {
      final charCode = char.codeUnitAt(0);
      if (charCode >= 97 && charCode <= 109) { // a-m
        //fm.addMsg("You selected: $char");
        handleLetter(char);
        return KeyEventResult.handled;
      }
    }

    // Handle escape/cancel
    if (event.logicalKey == LogicalKeyboardKey.keyX) {
      fm.cancelToMain();
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