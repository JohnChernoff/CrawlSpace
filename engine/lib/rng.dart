import 'dart:math';
import 'coord_3d.dart';

enum ColorName {
  white,black,blue,red,green,orange,yellow,lavender,peach,vanilla,cream,
  peppermint,olive,puce,teal,taupe,vermillion,brown,silver,gold,bronze
}

enum AnimalName {
  viper, falcon, shark, raven, wolf, bear, eagle, cobra, mantis, wasp,
  lynx, pike, hornet, badger, jackal, vulture, orca, panther, reaper, basilisk,
}

class Rng {

  static const _consonants = [
    'b','c','d','f','g','h','j','k','l','m','n','p','r','s','t','v','w','x','z',
    'ch','sh','th','kr','gr','st','tr','dr','vr','zl'
  ];

  static const _vowels = [
    'a','e','i','o','u','ae','ai','oa','ou','ei','ia'
  ];

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

  static int poissonRandom(double lambda) { // Simple Poisson approximation
    double L = exp(-lambda);
    int k = 0;
    double p = 1.0;
    final rnd = Random();

    do {
      k++;
      p *= rnd.nextDouble();
    } while (p > L);

    return k - 1;
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

  static String generateName({int minSyllables = 2, int maxSyllables = 4, required Random rnd}) {
    final syllables = minSyllables + rnd.nextInt(maxSyllables - minSyllables + 1);
    final sb = StringBuffer();

    for (int i = 0; i < syllables; i++) {
      sb.write(_pick(_consonants,rnd));
      sb.write(_pick(_vowels,rnd));
    }

    final name = sb.toString();
    return name[0].toUpperCase() + name.substring(1);
  }

  static T _pick<T>(List<T> list, Random rnd) => list[rnd.nextInt(list.length)];
}

