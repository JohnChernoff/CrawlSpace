import 'letter_input.dart';

class HyperSpaceInput extends LetterInput {
  const HyperSpaceInput(super.child, super.fm, {super.key});

  @override
  void handleLetter(String letter) {
    fm.layerTransitController.hyperSpace(letter);
  }

}
