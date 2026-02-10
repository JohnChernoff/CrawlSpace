import 'package:crawlspace_engine/fugue_engine.dart';
import 'package:flutter/material.dart';

abstract class LetterInput extends StatelessWidget {
  final Widget child;
  final FugueEngine fm;

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