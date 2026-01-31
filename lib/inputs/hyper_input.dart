import 'package:space_fugue/letter_menu_input.dart';

class HyperSpaceInput extends LetterMenuInput {
  const HyperSpaceInput(super.child, super.fm, {super.key});

  @override
  void handleLetter(String letter) {
    fm.hyperSpace(letter);
  }

}
