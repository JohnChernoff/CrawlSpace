class Item {
  static int _idCounter = 0;

  final String name;
  final int baseCost;
  final double rarity;
  final int id;

  Item(this.name, {required this.baseCost, required this.rarity})
      : id = _idCounter++;

  @override
  String toString() => name;
}

