import 'package:bokboolbok_roulette/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reads the legacy name:count|name:count format', () async {
    SharedPreferences.setMockInitialValues({
      'history': '민수:3|10:30 회의:2|broken|:5|지영:x',
    });
    final p = PlayerProvider();
    await p.loadHistory();
    expect(p.history, {'민수': 3, '10:30 회의': 2});
  });

  test('names with : and | survive a save and reload', () async {
    SharedPreferences.setMockInitialValues({});
    final p = PlayerProvider();
    await p.addHistory('A|B');
    await p.addHistory('팀:1');
    await p.addHistory('팀:1');

    final reloaded = PlayerProvider();
    await reloaded.loadHistory();
    expect(reloaded.history, {'A|B': 1, '팀:1': 2});
  });
}
