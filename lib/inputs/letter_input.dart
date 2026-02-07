import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../fugue_model.dart';

abstract class LetterInput extends StatelessWidget {
  final Widget child;
  final FugueModel fm;

  const LetterInput(this.child, this.fm, {super.key});

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    final char = event.character; //?.toLowerCase();
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