import 'dart:math';
import 'package:collection/collection.dart';

import 'throws.dart';

enum FooShamPlayer {
  player("Player"),
  house("House");
  final String name;
  const FooShamPlayer(this.name);
}

class FooShamResult {
  String winThrow, loseThrow;
  FooShamGame game;
  FooShamResult(this.winThrow,this.loseThrow,this.game);

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    if (winThrow == loseThrow) {
      sb.write("$winThrow vs. $loseThrow... ");
      if (game.houseWinsOnTie) {
        sb.writeln("house wins on a tie");
      } else {
        sb.writeln("tie! No points.");
      }
    } else {
      sb.writeln("$winThrow beats $loseThrow");
    }
    if (game.winner != null) {
      sb.write("${game.winner!.name} wins!");
    } else {
      for (final ps in game.scoreMap.entries) {
        sb.writeln("${ps.key.name}: ${ps.value} points");
      }
    }
    return sb.toString();
  }
}

enum FooShamDifficulty {
  easy,
  medium,
  hard;
}

class FooShamGame {
  final ThrowList throwList;
  final FooShamDifficulty difficulty;
  int turn = 0;
  Map<String,List<String>> beatMap = {};
  Map<FooShamPlayer,int> scoreMap = {};
  Map<String, int> playerThrowFrequency = {}; // track player's throws
  int winscore = 12;
  Random rnd;
  bool houseWinsOnTie = true;
  FooShamPlayer? get winner => scoreMap.entries.firstWhereOrNull((s) => s.value >= winscore)?.key;

  FooShamGame(this.throwList, this.rnd, {this.difficulty = FooShamDifficulty.easy}) {
    for (final p in FooShamPlayer.values) {
      scoreMap[p] = 0;
    }
    for (final t in throwList.list) {
      beatMap[t] = [];
      playerThrowFrequency[t] = 0;
    }

    for (final t in throwList.list) {
      for (final t2 in throwList.list) {
        if (t != t2 && !beatMap[t2]!.contains(t) && rnd.nextBool()) {
          beatMap[t]!.add(t2);
        }
      }
    }
  }

  FooShamResult playThrow(String t) {
    turn++;
    playerThrowFrequency[t] = playerThrowFrequency[t]! + 1; // track the throw
    String houseThrow = _getHouseThrow();
    if (t == houseThrow) {
      if (houseWinsOnTie) score(FooShamPlayer.house);
      return FooShamResult(t, houseThrow,this);
    } else if (beatMap[t]!.contains(houseThrow)) {
      score(FooShamPlayer.player);
      return FooShamResult(t, houseThrow,this);
    } else {
      score(FooShamPlayer.house);
      return FooShamResult(houseThrow, t, this);
    }
  }

  String _getHouseThrow() {
    switch(difficulty) {
      case FooShamDifficulty.easy:
        return throwList.rndThrow(rnd);

      case FooShamDifficulty.medium:
      // Pick the most frequent player throw, then counter it 60% of the time
        var mostFrequent = playerThrowFrequency.entries
            .reduce((a, b) => a.value > b.value ? a : b).key;
        var counters = beatMap.entries
            .where((e) => e.value.contains(mostFrequent))
            .map((e) => e.key)
            .toList();

        return (counters.isNotEmpty && rnd.nextDouble() < 0.6)
            ? counters[rnd.nextInt(counters.length)]
            : throwList.rndThrow(rnd);

      case FooShamDifficulty.hard:
      // Same logic as medium but 90% of the time
        var mostFrequent = playerThrowFrequency.entries
            .reduce((a, b) => a.value > b.value ? a : b).key;
        var counters = beatMap.entries
            .where((e) => e.value.contains(mostFrequent))
            .map((e) => e.key)
            .toList();

        return (counters.isNotEmpty && rnd.nextDouble() < 0.9)
            ? counters[rnd.nextInt(counters.length)]
            : throwList.rndThrow(rnd);
    }
  }

  void score(FooShamPlayer p) {
    scoreMap[p] = scoreMap[p]! + 1;
  }

}