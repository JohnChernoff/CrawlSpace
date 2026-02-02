import 'dart:math';

import 'package:space_fugue/coord_3d.dart';

enum ColorName {
  white,black,blue,red,green,orange,yellow,lavender,peach,vanilla,cream,
  peppermint,olive,puce,teal,taupe,vermillion,brown,silver,gold,bronze
}

enum AnimalName {
  viper, falcon, shark, raven, wolf, bear, eagle, cobra, mantis, wasp,
  lynx, pike, hornet, badger, jackal, vulture, orca, panther, reaper, basilisk,
}

class Rng {

  static String rndColorName(Random rnd) {
    return ColorName.values.elementAt(rnd.nextInt(ColorName.values.length)).name;
  }

  static String rndAnimalName(Random rnd) {
    return AnimalName.values.elementAt(rnd.nextInt(AnimalName.values.length)).name;
  }

  static int rollDice(int count, int sides, Random rnd) {
    int total = 0;
    for (int i = 0; i < count; i++) {
      total += rnd.nextInt(sides) + 1;
    }
    return total;
  }

  static Coord3D rndUnitVector(Random rnd) {
    return Coord3D(rndUnit(rnd),rndUnit(rnd),rndUnit(rnd));
  }

  static int rndUnit(Random rnd) {
    return rnd.nextBool() ? 0 : rnd.nextBool() ? 1 : -1;
  }


  static int biasedRndInt(Random rnd, {
    required int mean,
    required int min,
    required int max,
  }) {
    final weights = <int, double>{};

    // Create inverse weights based on distance from mean
    double totalWeight = 0;
    for (int i = min; i <= max; i++) {
      double weight = 1 / (1 + (i - mean).abs()); // Inverse to distance
      weights[i] = weight;
      totalWeight += weight;
    }

    // Roll based on the weights
    double roll = rnd.nextDouble() * totalWeight;
    double cumulative = 0;
    for (final entry in weights.entries) {
      cumulative += entry.value;
      if (roll <= cumulative) return entry.key;
    }

    return mean; // Fallback
  }

  static void rndTest(Random rnd) {
    Map<int,int> intMap = {};
    for (int i=0;i<100;i++) {
      int n = biasedRndInt(rnd, mean: 1, min: 0, max: 5);
      intMap.update(n, (v) => v + 1,  ifAbsent: () => 1);
      print("Rnd: $n");
    }
    print("IntMap: $intMap");
  }
}