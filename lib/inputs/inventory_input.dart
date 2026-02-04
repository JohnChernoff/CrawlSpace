import 'package:space_fugue/inputs/letter_menu_input.dart';

class InventoryInput extends LetterMenuInput {

  const InventoryInput(super.child, super.fm, {super.key});

  @override
  void handleLetter(String letter) {
    fm.menuController.inventoryCompleter?.complete(letter);
  }

}