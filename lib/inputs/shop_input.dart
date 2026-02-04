import 'package:space_fugue/inputs/letter_menu_input.dart';

class ShopInput extends LetterMenuInput {
  const ShopInput(super.child, super.fm, {super.key});

  @override
  void handleLetter(String letter) {
    print("Handling letter: $letter");
    if (letter.startsWith("s")) {
      fm.planetsideController.sellItem();
    } else {
      fm.planetsideController.purchaseItem(letter);
    }
  }

}