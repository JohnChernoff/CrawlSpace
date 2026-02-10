import 'dart:math';
import 'grid.dart';
import 'impulse.dart';
import 'ship.dart';
import 'systems/weapons.dart';

enum Hazard {
  nebula("Nebula","~",[Domain.system]),
  ion("Ion Storm","#",[Domain.system,Domain.impulse]),
  roid("Asteroids","+",[Domain.system,Domain.impulse]),
  gamma("Gamma Radiation","%",[Domain.impulse]),
  wake("Relativeistic Wake Turbulence","^",[Domain.impulse]);
  final String name;
  final String glyph;
  final List<Domain> domains;
  const Hazard(this.name,this.glyph,this.domains);

  String? effectPerTurn(Ship ship, int turns, Random rnd) {
    final cell = ship.loc.cell;
    if (rnd.nextDouble() < (cell.hazMap[this] ?? 0)) {
      if (this == Hazard.ion) {
        final system = ship.getAllInstalledSystems.elementAt(
            rnd.nextInt(ship.getAllInstalledSystems.length));
        final dmg = (rnd.nextDouble() * (cell is ImpulseCell ? .25 : .1)) * turns;
        system.takeDamage(dmg);
        return "${ship.name} takes $dmg ion damage to ${system.name}...";
      }
      if (this == Hazard.roid) {
        final dmg = rnd.nextInt(cell is ImpulseCell ? 10 : 40) * turns;
        ship.takeDamage(dmg as double, DamageType.kinetic);
        return "${ship.name} takes $dmg asteroid damage...";
      }
    }
    return null;
  }
}

