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
      1000
  ),
  galaxy("Galaxy",ShipType.flagship,
      [
        ShipClassSlot(SystemSlot(SystemSlotType.bauchmann,4),4),
        ShipClassSlot(SystemSlot(SystemSlotType.sinclair,2),1),
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
  scout,skiff,cruiser,destroyer,interceptor,flagship,unknown
}
