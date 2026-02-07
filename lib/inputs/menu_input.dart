import 'package:collection/collection.dart';

import 'letter_input.dart';

class MenuInput extends LetterInput {

  const MenuInput(super.child, super.fm, {super.key});

  @override
  void handleLetter(String letter) {
    fm.menuController.selectionList
        .firstWhereOrNull((s) => s.letter == letter)?.activate(fm.menuController);
  }

}