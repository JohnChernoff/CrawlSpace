import 'package:crawlspace_engine/fugue_engine.dart';
import 'package:crawlspace_engine/galaxy.dart';
import 'package:crawlspace_engine/shop.dart';

void main() {
  final engine = FugueEngine(Galaxy("Testlandia"), "Zug");
  Shop shop = Shop(ShopType.misc,1,engine.rnd);
  for (final slot in shop.itemSlots) {
    print("${slot.items.first}: ${slot.items.length}");
  }
}