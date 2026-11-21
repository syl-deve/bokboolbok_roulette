import 'dart:math';

import 'package:bokboolbok_roulette/modes/ladder.dart';
import 'package:bokboolbok_roulette/modes/team_split.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ladder', () {
    test('every participant lands on a different slot', () {
      for (var seed = 0; seed < 300; seed++) {
        final columns = 2 + seed % 19; // 2..20
        final rungs = generateRungs(columns, Random(seed));
        final mapping = ladderMapping(rungs, columns);
        expect(mapping.toSet().length, columns, reason: 'seed $seed');
        expect(mapping.every((m) => m >= 0 && m < columns), isTrue);
      }
    });

    test('rungs never touch on the same row and every gap has one', () {
      for (var seed = 0; seed < 300; seed++) {
        final columns = 2 + seed % 19;
        final rungs = generateRungs(columns, Random(seed));
        for (final row in rungs) {
          for (var g = 1; g < row.length; g++) {
            expect(row[g] && row[g - 1], isFalse, reason: 'seed $seed');
          }
        }
        for (var g = 0; g < columns - 1; g++) {
          expect(rungs.any((row) => row[g]), isTrue, reason: 'seed $seed gap $g');
        }
      }
    });

    test('the path follows rungs left and right', () {
      // One rung on row 0 between columns 0 and 1.
      final rungs = [
        [true, false],
        [false, false],
      ];
      expect(ladderMapping(rungs, 3), [1, 0, 2]);
      expect(ladderPath(rungs, 0).map((p) => [p.x, p.y]).toList(), [
        [0, 0],
        [0, 1],
        [1, 1],
        [1, 2],
        [1, 3],
      ]);
    });

    test('every participant is equally likely to reach every slot', () {
      // 5 participants, 20000 ladders: each (participant, slot) pair should
      // come up about 1/5 of the time.
      const columns = 5;
      const runs = 20000;
      final counts = List.generate(columns, (_) => List.filled(columns, 0));
      final random = Random(11);
      for (var i = 0; i < runs; i++) {
        final m = ladderMapping(generateRungs(columns, random), columns);
        for (var p = 0; p < columns; p++) {
          counts[p][m[p]]++;
        }
      }
      for (var p = 0; p < columns; p++) {
        for (var s = 0; s < columns; s++) {
          expect(counts[p][s] / runs, closeTo(0.2, 0.02), reason: 'p$p s$s');
        }
      }
    });

    test('with 20 participants the first one can reach the last slots', () {
      const columns = 20;
      final seen = <int>{};
      final random = Random(5);
      for (var i = 0; i < 2000; i++) {
        seen.add(ladderMapping(generateRungs(columns, random), columns)[0]);
      }
      expect(seen.length, columns);
    });
  });

  group('team split', () {
    test('everyone is placed exactly once and sizes differ by at most one', () {
      for (var n = 2; n <= 25; n++) {
        for (var teams = 2; teams <= n; teams++) {
          final result = splitIntoTeams(n, teams, Random(n * 31 + teams));
          expect(result.length, teams);
          final all = result.expand((t) => t).toList()..sort();
          expect(all, List.generate(n, (i) => i));
          final sizes = result.map((t) => t.length);
          expect(sizes.reduce(max) - sizes.reduce(min), lessThanOrEqualTo(1));
          expect(sizes.every((s) => s >= 1), isTrue);
        }
      }
    });

    test('teams change between runs', () {
      final random = Random(3);
      final first = splitIntoTeams(8, 2, random);
      var changed = false;
      for (var i = 0; i < 20 && !changed; i++) {
        changed = splitIntoTeams(8, 2, random).toString() != first.toString();
      }
      expect(changed, isTrue);
    });
  });
}
