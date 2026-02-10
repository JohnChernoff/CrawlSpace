import '../ship.dart';
import '../systems/ship_system.dart';
import '../systems/weapons.dart';

enum HullType {
  basic([],1),
  ablative([HullResistance(DamageType.kinetic,.5)],2),
  refractive([HullResistance(DamageType.light,.33)],2.5),
  crystalline([
    HullResistance(DamageType.kinetic,.66),
    HullResistance(DamageType.plasma,.25),
  ],5),
  hypercarbon([
    HullResistance(DamageType.fire,.66),
    HullResistance(DamageType.plasma,.5),
    HullResistance(DamageType.sonic,.5),
  ],6.6);
  final List<HullResistance> resistances;
  final double baseRepairCost; //in kilos
  const HullType(this.resistances,this.baseRepairCost);
}

enum ShipClass {
  mentok("Mentok",ShipType.scout,
      [ShipClassSlot(SystemSlot(SystemSlotType.generic,1),8)],
      500
  ),
  hermes("Hermes",ShipType.skiff,
      [
        ShipClassSlot(SystemSlot(SystemSlotType.generic,1),6),
        ShipClassSlot(SystemSlot(SystemSlotType.tanaka,1),1),
        ShipClassSlot(SystemSlot(SystemSlotType.sinclair,1),1),
      ],
      750),
  orion("Orion",ShipType.cruiser,
      [
        ShipClassSlot(SystemSlot(SystemSlotType.generic,1),4),
        ShipClassSlot(SystemSlot(SystemSlotType.nimrod,1),3),
        ShipClassSlot(SystemSlot(SystemSlotType.tanaka,1),1),
      ],
      5000),
  balrog("Balrog",ShipType.battleship,
      [
        ShipClassSlot(SystemSlot(SystemSlotType.generic,1),4),
        ShipClassSlot(SystemSlot(SystemSlotType.nimrod,1),3),
        ShipClassSlot(SystemSlot(SystemSlotType.tanaka,2),1),
        ShipClassSlot(SystemSlot(SystemSlotType.gregoriev,1),1),
      ],
      7500),
  galaxy("Galaxy",ShipType.flagship,
      [
        ShipClassSlot(SystemSlot(SystemSlotType.generic,1),4),
        ShipClassSlot(SystemSlot(SystemSlotType.bauchmann,4),4),
        ShipClassSlot(SystemSlot(SystemSlotType.sinclair,2),4),
      ],
      10000
  );
  final String name;
  final ShipType type;
  final List<ShipClassSlot> slots;
  final double maxMass;
  const ShipClass(this.name,this.type,this.slots,this.maxMass);
}

enum ShipType { //TODO: ascii/color codes
  scout,skiff,cruiser,destroyer,interceptor,battleship,flagship,unknown
}
