import 'package:bokboolbok_roulette/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  List<String> names(PlayerProvider p) => p.players.map((e) => e.name).toList();

  group('addPlayers', () {
    test('one name works as before', () {
      final p = PlayerProvider();
      expect(p.addPlayers('  민수 '), 1);
      expect(names(p), ['민수']);
    });

    test('commas, full-width commas and line breaks split names', () {
      final p = PlayerProvider();
      expect(p.addPlayers('민수, 지영，서연、도윤\n하준\r\n Emma '), 6);
      expect(names(p), ['민수', '지영', '서연', '도윤', '하준', 'Emma']);
    });

    test('empty parts and duplicates are skipped, case-insensitive', () {
      final p = PlayerProvider();
      p.addPlayers('Emma');
      expect(p.addPlayers('emma, , Liam,,LIAM, 민수, 민수'), 2);
      expect(names(p), ['Emma', 'Liam', '민수']);
    });

    test('nothing to add returns 0', () {
      final p = PlayerProvider();
      expect(p.addPlayers(' , \n '), 0);
      expect(p.players, isEmpty);
    });
  });

  group('renamePlayer', () {
    test('renames in place and keeps the order', () {
      final p = PlayerProvider();
      p.addPlayers('A, B, C');
      expect(p.renamePlayer(1, '  지영 '), isTrue);
      expect(names(p), ['A', '지영', 'C']);
    });

    test('rejects empty names and names another participant has', () {
      final p = PlayerProvider();
      p.addPlayers('A, B');
      expect(p.renamePlayer(0, '   '), isFalse);
      expect(p.renamePlayer(0, 'b'), isFalse);
      expect(names(p), ['A', 'B']);
    });

    test('changing only the case of its own name is allowed', () {
      final p = PlayerProvider();
      p.addPlayers('emma');
      expect(p.renamePlayer(0, 'Emma'), isTrue);
      expect(names(p), ['Emma']);
    });

    test('renamed list is saved', () async {
      final p = PlayerProvider();
      p.addPlayers('A, B');
      p.renamePlayer(0, 'Z');
      await Future<void>.delayed(Duration.zero);
      final reloaded = PlayerProvider();
      await reloaded.loadFromPrefs();
      expect(names(reloaded), ['Z', 'B']);
    });
  });
}
