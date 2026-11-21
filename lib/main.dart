import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bokboolbok_roulette/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app_analytics.dart';
import 'design_tokens.dart';
import 'firebase_options.dart';
import 'iap_service.dart';
import 'modes/ladder.dart';
import 'modes/team_split.dart';
import 'result_share.dart';
import 'review_prompter.dart';

// ─── Design tokens (values live in design_tokens.dart) ───────────────────────
const Color _kBg = kBg;
const Color _kSurface = kSurface;
const Color _kCard = kCard;
const Color _kBorder = kBorder;
const Color _kText = kText;
const Color _kTextSub = kTextSub;
const Color _kDisabled = kDisabled;
const Color _kAction = kAction;
const Color _kSuccess = kSuccess;

const SystemUiOverlayStyle _kLightSystemUiStyle = SystemUiOverlayStyle(
  statusBarColor: _kBg,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: _kBg,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarDividerColor: _kBg,
  systemNavigationBarContrastEnforced: false,
);

const List<Color> _kWheelColors = kWheelColors;
const List<Color> _kWheelTextColors = kWheelTextColors;
// ─────────────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(_kLightSystemUiStyle);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppAnalytics.enabled = true;
  } catch (error) {
    // The app works without analytics; never block startup on it.
    debugPrint('Firebase init failed: $error');
  }
  MobileAds.instance.initialize();
  RequestConfiguration configuration = RequestConfiguration(
    testDeviceIds: ['D86D9B1F092E7C8CC61591C0B2B19CFE'],
  );
  MobileAds.instance.updateRequestConfiguration(configuration);
  AdHelper.loadInterstitialAd();
  final playerProvider = PlayerProvider();
  try {
    await playerProvider.loadFromPrefs();
  } catch (error) {
    debugPrint('Failed to load saved roulette data: $error');
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => playerProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: _kBg,
          colorScheme: const ColorScheme.light(
            primary: _kAction,
            secondary: _kSuccess,
            surface: _kSurface,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: _kText,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: _kCard,
            foregroundColor: _kText,
            elevation: 0,
            // Keep the bar white when content scrolls under it (no M3 tint).
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: _kText,
            ),
          ),
          cardTheme: CardThemeData(
            color: _kCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            margin: EdgeInsets.zero,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAction,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: _kAction.withValues(alpha: 0.35),
              disabledForegroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: _kCard,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: _kBorder),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: _kBorder),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: _kAction, width: 2),
            ),
            labelStyle: const TextStyle(color: _kTextSub),
            hintStyle: const TextStyle(color: _kTextSub),
            prefixIconColor: _kTextSub,
            suffixIconColor: _kTextSub,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: _kCard,
            selectedItemColor: _kAction,
            unselectedItemColor: _kTextSub,
            elevation: 0,
          ),
          dividerColor: _kBorder,
          iconTheme: const IconThemeData(color: _kTextSub),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _kAction),
          ),
        ),
        home: const HomeScreen(),
      ),
    ),
  );
}

// ─── AdHelper ─────────────────────────────────────────────────────────────────
class AdHelper {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;

  static bool isAdReady() => _isAdLoaded;

  static void loadInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3960681231120180/2725744412',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  static void showInterstitialAd(
    VoidCallback onAdClosedAfterDelay, {
    bool isAdFree = false,
  }) {
    if (isAdFree) {
      onAdClosedAfterDelay();
      return;
    }
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          loadInterstitialAd();
          onAdClosedAfterDelay();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          loadInterstitialAd();
          onAdClosedAfterDelay();
        },
      );
      _interstitialAd!.show();
      _isAdLoaded = false;
    } else {
      onAdClosedAfterDelay();
    }
  }
}

// ─── MyBannerAd ───────────────────────────────────────────────────────────────
class MyBannerAd extends StatefulWidget {
  const MyBannerAd({super.key});

  @override
  State<MyBannerAd> createState() => _MyBannerAdState();
}

class _MyBannerAdState extends State<MyBannerAd> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3960681231120180/2821709658',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdFree = context.watch<PlayerProvider>().isAdFree;
    if (isAdFree || _bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────
class Player {
  final String name;
  Player(this.name);
}

class Preset {
  final String name;
  final List<String> players;
  Preset({required this.name, required this.players});
}

class PlayerProvider with ChangeNotifier {
  final List<Player> _players = [];
  Map<String, int> _history = {};
  List<Preset> _presets = [];
  bool _isAdFree = false;

  List<Player> get players => _players;
  Map<String, int> get history => _history;
  List<Preset> get presets => _presets;
  bool get isAdFree => _isAdFree;

  void setAdFree(bool value) async {
    _isAdFree = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAdFree', value);
    notifyListeners();
  }

  bool _nameTaken(String name, {int? except}) {
    final lower = name.toLowerCase();
    for (var i = 0; i < _players.length; i++) {
      if (i != except && _players[i].name.toLowerCase() == lower) return true;
    }
    return false;
  }

  /// Adds every name in [input]. Names may be separated by commas
  /// (`,` `，` `、`) or line breaks, so a pasted list adds everyone at once.
  /// Empty and duplicate names (case-insensitive) are skipped.
  /// Returns how many were added.
  int addPlayers(String input) {
    var added = 0;
    for (final part in input.split(RegExp(r'[,，、\r\n]+'))) {
      final name = part.trim();
      if (name.isEmpty || _nameTaken(name)) continue;
      _players.add(Player(name));
      added++;
    }
    if (added > 0) {
      _saveToPrefs();
      notifyListeners();
    }
    return added;
  }

  /// Renames the participant at [index]. Returns false (and changes
  /// nothing) when the new name is empty or another participant has it.
  bool renamePlayer(int index, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _nameTaken(trimmed, except: index)) return false;
    _players[index] = Player(trimmed);
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  void removePlayer(int index) {
    _players.removeAt(index);
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList('players') ?? [];
    _isAdFree = prefs.getBool('isAdFree') ?? false;
    _players.clear();
    _players.addAll(names.map((e) => Player(e)));
    await loadHistory();
    await _loadPresets();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('players', _players.map((e) => e.name).toList());
  }

  Future<void> addHistory(String name) async {
    _history[name] = (_history[name] ?? 0) + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('history', _encodeHistory());
    notifyListeners();
  }

  // Stored as a JSON object so names may contain any character.
  String _encodeHistory() => jsonEncode(_history);

  Map<String, int> _decodeHistory(String encoded) {
    if (encoded.startsWith('{')) {
      try {
        final decoded = jsonDecode(encoded) as Map<String, dynamic>;
        return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {
        // Fall through to the legacy format.
      }
    }
    // Legacy format (<= 1.0.8): "name:count|name:count". The count is after
    // the last ':', so names that contain ':' are still recovered.
    final Map<String, int> map = {};
    for (final pair in encoded.split('|')) {
      final sep = pair.lastIndexOf(':');
      if (sep <= 0) continue;
      final count = int.tryParse(pair.substring(sep + 1));
      if (count != null) map[pair.substring(0, sep)] = count;
    }
    return map;
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString('history');
    _history = encoded != null ? _decodeHistory(encoded) : {};
  }

  Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    notifyListeners();
    AppAnalytics.historyCleared();
  }

  // ── Presets ──────────────────────────────────────────────────────────────────
  Future<void> _loadPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList('presets') ?? [];
    _presets =
        encoded
            .map((e) {
              final parts = e.split('\x00');
              if (parts.length < 2) return null;
              return Preset(name: parts[0], players: parts.sublist(1));
            })
            .whereType<Preset>()
            .toList();
  }

  Future<void> _savePresets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'presets',
      _presets.map((p) => '${p.name}\x00${p.players.join('\x00')}').toList(),
    );
  }

  Future<void> savePreset(String presetName) async {
    final names = _players.map((p) => p.name).toList();
    _presets.add(Preset(name: presetName, players: names));
    await _savePresets();
    notifyListeners();
    AppAnalytics.presetSaved(participants: names.length);
  }

  Future<void> deletePreset(int index) async {
    _presets.removeAt(index);
    await _savePresets();
    notifyListeners();
  }

  void loadPreset(int index) {
    final preset = _presets[index];
    _players.clear();
    _players.addAll(preset.players.map((e) => Player(e)));
    _saveToPrefs();
    notifyListeners();
    AppAnalytics.presetLoaded(participants: preset.players.length);
  }
}

// ─── HomeScreen ───────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Mode tabs: 0 roulette, 1 ladder, 2 teams.
  static const _modeNames = ['roulette', 'ladder', 'teams'];
  late final TabController _tabController;
  bool _modeBusy = false;

  // Participant input
  final TextEditingController _controller = TextEditingController();

  // Scroll
  final ScrollController _scrollController = ScrollController();

  // Spin button focus (prevents keyboard from appearing after dialog close)
  final FocusNode _spinButtonFocusNode = FocusNode();

  // Roulette state
  final StreamController<int> _selected = StreamController<int>.broadcast();
  late ConfettiController _confettiController;
  final Random _random = Random();
  List<int> selectedIndexes = [];
  List<int> confirmedIndexes = [];
  int? resultIndex;
  bool _isSpinning = false;
  int spinCount = 1;
  List<Player> players = [];

  final AudioPlayer _spinPlayer = AudioPlayer();
  final AudioPlayer _winPlayer = AudioPlayer();
  late IAPService _iapService;
  final _ladderKey = GlobalKey<LadderPanelState>();
  final _teamKey = GlobalKey<TeamSplitPanelState>();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _tabController = TabController(length: 3, vsync: this)..addListener(() {
      if (_tabController.indexIsChanging) return;
      AppAnalytics.modeSelected(_modeNames[_tabController.index]);
      FocusScope.of(context).unfocus();
      setState(() {});
    });

    _iapService = IAPService();
    _iapService.onPurchaseSuccess = (success) {
      if (success && mounted) {
        context.read<PlayerProvider>().setAdFree(true);
        _showSnack(AppLocalizations.of(context)!.proActivated);
      }
    };
    _iapService.onProblem = (problem) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showSnack(switch (problem) {
        IapProblem.storeUnavailable => l10n.storeUnavailable,
        IapProblem.purchaseFailed => l10n.purchaseFailed,
      });
    };
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _iapService.dispose();
    _tabController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _selected.close();
    _confettiController.dispose();
    _spinButtonFocusNode.dispose();
    _spinPlayer.dispose();
    _winPlayer.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Roulette logic ──────────────────────────────────────────────────────────
  void _startSpinning(List<Player> p, {bool again = false}) {
    if (_isSpinning || p.length < 2) return;
    AppAnalytics.spinStart(
      participants: p.length,
      winners: spinCount,
      again: again,
    );
    setState(() {
      _isSpinning = true;
      players = p;
      selectedIndexes.clear();
      confirmedIndexes.clear();
    });
    HapticFeedback.mediumImpact();
    _spinPlayer.setReleaseMode(ReleaseMode.loop);
    _spinPlayer.play(AssetSource('sounds/spin.wav'));
    FocusScope.of(context).unfocus();
    _scrollToBottom();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (spinCount == 1) {
        resultIndex = 0;
        _selected.add(resultIndex!);
        Future.delayed(const Duration(milliseconds: 300), _spinNext);
      } else {
        _spinNext();
      }
    });
  }

  void _spinNext() {
    final available =
        List.generate(
          players.length,
          (i) => i,
        ).where((i) => !selectedIndexes.contains(i)).toList();

    if (selectedIndexes.length >= spinCount || available.isEmpty) {
      setState(() => _isSpinning = false);
      if (confirmedIndexes.isNotEmpty && mounted) {
        Future.delayed(const Duration(milliseconds: 300), _showWinnerDialog);
      }
      return;
    }
    resultIndex = available[_random.nextInt(available.length)];
    _selected.add(resultIndex!);
  }

  void _showWinnerDialog() {
    if (!mounted) return;
    final winners = confirmedIndexes.map((i) => players[i]).toList();
    AppAnalytics.resultShown(
      participants: players.length,
      winners: winners.length,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder:
          (ctx) => _WinnerDialog(
            winners: winners,
            participantCount: players.length,
            onClose: () {
              Navigator.pop(ctx);
              _resetGame();
              _afterResult(() {
                _spinButtonFocusNode.requestFocus();
                ReviewPrompter.onResult(canPrompt: true);
              });
            },
            onSpinAgain: () {
              Navigator.pop(ctx);
              _resetGame();
              ReviewPrompter.onResult(canPrompt: false);
              _afterResult(() => _startSpinning(players, again: true));
            },
          ),
    );
  }

  void _resetGame() {
    setState(() {
      resultIndex = null;
      selectedIndexes.clear();
      confirmedIndexes.clear();
      _isSpinning = false;
    });
  }

  // ── Edit a participant's name ───────────────────────────────────────────────
  Future<void> _editPlayer(
    PlayerProvider provider,
    int index,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController(
      text: provider.players[index].name,
    );
    String? error;
    await showDialog<void>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setLocal) {
              void submit() {
                final name = controller.text.trim();
                if (name.isEmpty) {
                  setLocal(() => error = l10n.presetNameEmpty);
                  return;
                }
                if (!provider.renamePlayer(index, name)) {
                  setLocal(() => error = l10n.nameTaken);
                  return;
                }
                Navigator.pop(ctx);
              }

              return AlertDialog(
                title: Text(l10n.editName),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 30,
                  decoration: InputDecoration(
                    counterText: '',
                    errorText: error,
                  ),
                  onChanged: (_) {
                    if (error != null) setLocal(() => error = null);
                  },
                  onSubmitted: (_) => submit(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(onPressed: submit, child: Text(l10n.save)),
                ],
              );
            },
          ),
    );
    controller.dispose();
    if (mounted) FocusScope.of(context).unfocus();
  }

  // ── Clear all participants (asks first) ────────────────────────────────────
  Future<void> _confirmClearAll(
    PlayerProvider provider,
    AppLocalizations l10n,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            content: Text(l10n.confirmClearAll(provider.players.length)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.clearAll),
              ),
            ],
          ),
    );
    if (ok != true || !mounted) return;
    for (var i = provider.players.length - 1; i >= 0; i--) {
      provider.removePlayer(i);
    }
  }

  // ── Preset sheet ────────────────────────────────────────────────────────────
  void _showPresetSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => _PresetSheet(l10n: l10n),
    );
  }

  // ── History sheet ───────────────────────────────────────────────────────────
  void _showHistorySheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => _HistorySheet(l10n: l10n),
    );
  }

  /// Runs after a result dialog closes, in every mode: shows the
  /// interstitial (unless ad-free), then runs [next]. The ad comes after the
  /// result so it never sits between the tap and the reveal.
  void _afterResult(VoidCallback next) {
    FocusScope.of(context).unfocus();
    AdHelper.showInterstitialAd(() {
      if (mounted) next();
    }, isAdFree: context.read<PlayerProvider>().isAdFree);
  }

  /// The one primary button for the current tab, pinned above the banner so
  /// it is on screen without scrolling.
  Widget _buildPrimaryAction(List<Player> p, AppLocalizations l10n) {
    final enough = p.length >= 2;
    switch (_tabController.index) {
      case 0:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              focusNode: _spinButtonFocusNode,
              onPressed:
                  _isSpinning || !enough
                      ? null
                      : () {
                        _resetGame();
                        _startSpinning(p);
                      },
              child: Text(l10n.spinRoulette),
            ),
            const SizedBox(height: 6),
            Text(
              _isSpinning
                  ? l10n.findingWinner(
                    // The last winner is confirmed a moment before spinning
                    // ends; don't show "winner N+1 of N".
                    min(confirmedIndexes.length + 1, spinCount),
                    spinCount,
                  )
                  : enough
                  ? l10n.selectingWinners(spinCount)
                  : l10n.noParticipants,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _kTextSub, fontSize: 12),
            ),
          ],
        );
      case 1:
        return ElevatedButton(
          onPressed:
              _modeBusy || !enough
                  ? null
                  : () => _ladderKey.currentState?.start(),
          child: Text(l10n.ladderStart),
        );
      default:
        return ElevatedButton(
          onPressed: !enough ? null : () => _teamKey.currentState?.split(),
          child: Text(l10n.teamSplitButton),
        );
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        final p = provider.players;
        if (p.length > 1 && spinCount >= p.length) spinCount = p.length - 1;
        final l10n = AppLocalizations.of(context)!;
        final reduceMotion = MediaQuery.of(context).disableAnimations;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 24,
                    height: 24,
                    cacheWidth: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                _GradientText(
                  l10n.appTitle,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              if (!provider.isAdFree) ...[
                TextButton.icon(
                  onPressed: () {
                    AppAnalytics.removeAdsTapped();
                    _iapService.buyNonConsumable();
                  },
                  icon: const Icon(Icons.star, size: 14, color: _kAction),
                  label: Text(l10n.removeAds),
                  style: TextButton.styleFrom(
                    foregroundColor: _kText,
                    backgroundColor: _kSurface,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<void>(
                  icon: const Icon(Icons.more_vert, color: _kTextSub),
                  color: _kCard,
                  itemBuilder:
                      (_) => [
                        PopupMenuItem<void>(
                          onTap: () {
                            AppAnalytics.restoreTapped();
                            _showSnack(l10n.restoreChecking);
                            _iapService.restorePurchases();
                          },
                          child: Text(l10n.restorePurchase),
                        ),
                      ],
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.verified, color: _kSuccess, size: 24),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: IgnorePointer(
                ignoring: _isSpinning || _modeBusy,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: _kBorder)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: _kAction,
                    unselectedLabelColor: _kText,
                    indicatorColor: _kAction,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      Tab(text: l10n.modeRoulette),
                      Tab(text: l10n.modeLadder),
                      Tab(text: l10n.modeTeams),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Top section ─────────────────────────────────────────────────
                      // Participants stay fixed while a mode runs.
                      IgnorePointer(
                        ignoring: _isSpinning || _modeBusy,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Input row
                              Container(
                                decoration: BoxDecoration(
                                  color: _kCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _kBorder),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _controller,
                                        // Not single-line on purpose: a
                                        // single-line field drops pasted
                                        // line breaks, which separate names.
                                        minLines: 1,
                                        maxLines: 3,
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (_) {
                                          provider.addPlayers(_controller.text);
                                          _controller.clear();
                                        },
                                        // A hardware Enter key types a line
                                        // break here; treat it as submit.
                                        onChanged: (v) {
                                          if (v.endsWith('\n')) {
                                            provider.addPlayers(v);
                                            _controller.clear();
                                          }
                                        },
                                        style: const TextStyle(color: _kText),
                                        decoration: InputDecoration(
                                          hintText: l10n.enterParticipantName,
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          filled: false,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 13,
                                              ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: IconButton.filled(
                                        tooltip: l10n.addParticipant,
                                        onPressed: () {
                                          provider.addPlayers(_controller.text);
                                          _controller.clear();
                                        },
                                        style: IconButton.styleFrom(
                                          backgroundColor: _kAction,
                                          foregroundColor: Colors.white,
                                          fixedSize: const Size(40, 40),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add, size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Participants header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${l10n.participants.toUpperCase()} (${p.length})',
                                    style: const TextStyle(
                                      color: _kTextSub,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  if (p.isNotEmpty)
                                    TextButton(
                                      onPressed:
                                          () =>
                                              _confirmClearAll(provider, l10n),
                                      style: TextButton.styleFrom(
                                        foregroundColor: _kTextSub,
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      child: Text(l10n.clearAll),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Participants list — 참가자가 많아도 목록은 고정 높이(내부 스크롤)로
                              // 접어서 룰렛·스핀 버튼이 항상 화면 안에 보이도록 함
                              if (p.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person_add_alt_outlined,
                                        color: _kTextSub,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.noParticipants,
                                        style: const TextStyle(
                                          color: _kTextSub,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                SizedBox(
                                  height: 176,
                                  child: Scrollbar(
                                    thumbVisibility: p.length > 3,
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      itemCount: p.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(height: 6),
                                      itemBuilder: (context, index) {
                                        final wheelColor =
                                            _kWheelColors[index %
                                                _kWheelColors.length];
                                        final onWheelColor =
                                            _kWheelTextColors[index %
                                                _kWheelTextColors.length];
                                        return Container(
                                          height: 52,
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _kCard,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(color: _kBorder),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundColor: wheelColor,
                                                child: Text(
                                                  p[index]
                                                      .name
                                                      .characters
                                                      .first,
                                                  style: TextStyle(
                                                    color: onWheelColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  p[index].name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: _kText,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                tooltip: l10n.editName,
                                                onPressed:
                                                    () => _editPlayer(
                                                      provider,
                                                      index,
                                                      l10n,
                                                    ),
                                                color: _kTextSub,
                                                iconSize: 18,
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                ),
                                              ),
                                              IconButton(
                                                tooltip: l10n.removeParticipant,
                                                onPressed:
                                                    () => provider.removePlayer(
                                                      index,
                                                    ),
                                                color: _kTextSub,
                                                iconSize: 18,
                                                icon: const Icon(Icons.close),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              // Buttons row — 참가자 목록 바로 아래
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed:
                                        () => _showPresetSheet(context, l10n),
                                    icon: const Icon(
                                      Icons.bookmark_outline,
                                      size: 15,
                                      color: _kTextSub,
                                    ),
                                    label: Text(
                                      l10n.presets,
                                      style: const TextStyle(
                                        color: _kTextSub,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      minimumSize: const Size(0, 44),
                                      side: const BorderSide(color: _kBorder),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  if (_tabController.index == 0) ...[
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed:
                                          () =>
                                              _showHistorySheet(context, l10n),
                                      icon: const Icon(
                                        Icons.history,
                                        size: 15,
                                        color: _kTextSub,
                                      ),
                                      label: Text(
                                        l10n.history,
                                        style: const TextStyle(
                                          color: _kTextSub,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        minimumSize: const Size(0, 44),
                                        side: const BorderSide(color: _kBorder),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_tabController.index == 0) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // No. of Winners stepper
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: _kCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _kBorder),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.winner,
                                      style: const TextStyle(
                                        color: _kText,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        _StepperButton(
                                          icon: Icons.remove,
                                          tooltip: l10n.decrease,
                                          onPressed:
                                              _isSpinning || spinCount <= 1
                                                  ? null
                                                  : () {
                                                    setState(() => spinCount--);
                                                    _resetGame();
                                                  },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Text(
                                            '$spinCount',
                                            style: const TextStyle(
                                              color: _kSuccess,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ),
                                        _StepperButton(
                                          icon: Icons.add,
                                          tooltip: l10n.increase,
                                          onPressed:
                                              _isSpinning ||
                                                      p.length <= 1 ||
                                                      spinCount >= p.length - 1
                                                  ? null
                                                  : () {
                                                    setState(() => spinCount++);
                                                    _resetGame();
                                                  },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        // ── Wheel section ───────────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Square wheel, capped so tablets and landscape
                              // phones don't get a screen-wide wheel.
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: _kWheelMaxSize,
                                  ),
                                  child: Stack(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: Stack(
                                          children: [
                                            // 외곽 림(rim) — 그라디언트 + 입체 그림자
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: const SweepGradient(
                                                  colors: [
                                                    _kCard,
                                                    _kBorder,
                                                    _kCard,
                                                    _kSurface,
                                                    _kCard,
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.07),
                                                    offset: const Offset(0, 2),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // 휠 (림 안쪽에 패딩으로 띄움)
                                            Padding(
                                              padding: const EdgeInsets.all(7),
                                              child:
                                                  p.length < 2
                                                      ? Center(
                                                        child: Text(
                                                          l10n.noParticipants,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    _kTextSub,
                                                              ),
                                                        ),
                                                      )
                                                      : FortuneWheel(
                                                        selected:
                                                            _selected.stream,
                                                        animateFirst: false,
                                                        // DESIGN.md §15: under
                                                        // reduced motion the
                                                        // result is instant.
                                                        duration:
                                                            reduceMotion
                                                                ? Duration.zero
                                                                : _kSpinDuration,
                                                        indicators: const [
                                                          FortuneIndicator(
                                                            alignment:
                                                                Alignment
                                                                    .topCenter,
                                                            child:
                                                                TriangleIndicator(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  width: 28,
                                                                  height: 28,
                                                                ),
                                                          ),
                                                        ],
                                                        physics: CircularPanPhysics(
                                                          duration:
                                                              const Duration(
                                                                seconds: 2,
                                                              ),
                                                          curve:
                                                              Curves
                                                                  .easeOutCubic,
                                                        ),
                                                        items:
                                                            p.asMap().entries.map((
                                                              e,
                                                            ) {
                                                              final color =
                                                                  _kWheelColors[e
                                                                          .key %
                                                                      _kWheelColors
                                                                          .length];
                                                              final textColor =
                                                                  _kWheelTextColors[e
                                                                          .key %
                                                                      _kWheelTextColors
                                                                          .length];
                                                              final onLightColor =
                                                                  textColor ==
                                                                  _kText;
                                                              // 참가자가 많을수록 조각이 좁아지므로
                                                              // 기본 글자 크기를 줄이고, 이름이 길면 추가로 축소
                                                              final baseFontSize =
                                                                  p.length <= 3
                                                                      ? 26.0
                                                                      : p.length <=
                                                                          5
                                                                      ? 22.0
                                                                      : p.length <=
                                                                          8
                                                                      ? 18.0
                                                                      : 14.0;
                                                              return FortuneItem(
                                                                child: FittedBox(
                                                                  fit:
                                                                      BoxFit
                                                                          .scaleDown,
                                                                  child: Text(
                                                                    e
                                                                        .value
                                                                        .name,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          baseFontSize,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                      color:
                                                                          textColor,
                                                                      shadows:
                                                                          onLightColor
                                                                              ? const []
                                                                              : const [
                                                                                Shadow(
                                                                                  color:
                                                                                      Colors.black87,
                                                                                  blurRadius:
                                                                                      6,
                                                                                  offset: Offset(
                                                                                    0,
                                                                                    2,
                                                                                  ),
                                                                                ),
                                                                                Shadow(
                                                                                  color:
                                                                                      Colors.black54,
                                                                                  blurRadius:
                                                                                      14,
                                                                                ),
                                                                              ],
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                                style: FortuneItemStyle(
                                                                  color: color,
                                                                  borderColor: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                        0.65,
                                                                      ),
                                                                  borderWidth:
                                                                      3,
                                                                ),
                                                              );
                                                            }).toList(),
                                                        onAnimationEnd: () {
                                                          _spinPlayer.stop();
                                                          if (resultIndex ==
                                                                  null ||
                                                              resultIndex! >=
                                                                  p.length)
                                                            return;
                                                          final ci =
                                                              resultIndex!;
                                                          provider.addHistory(
                                                            p[ci].name,
                                                          );
                                                          setState(() {
                                                            selectedIndexes.add(
                                                              ci,
                                                            );
                                                            confirmedIndexes
                                                                .add(ci);
                                                          });
                                                          if (confirmedIndexes
                                                                  .length ==
                                                              spinCount) {
                                                            HapticFeedback.heavyImpact();
                                                            Future.delayed(
                                                              const Duration(
                                                                milliseconds:
                                                                    120,
                                                              ),
                                                              HapticFeedback
                                                                  .heavyImpact,
                                                            );
                                                            Future.delayed(
                                                              const Duration(
                                                                milliseconds:
                                                                    240,
                                                              ),
                                                              HapticFeedback
                                                                  .heavyImpact,
                                                            );
                                                            _winPlayer.play(
                                                              AssetSource(
                                                                'sounds/win.wav',
                                                              ),
                                                            );
                                                            if (!reduceMotion) {
                                                              _confettiController
                                                                  .play();
                                                            }
                                                          }
                                                          Future.delayed(
                                                            const Duration(
                                                              milliseconds: 800,
                                                            ),
                                                            _spinNext,
                                                          );
                                                        },
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Confetti
                                      Align(
                                        alignment: Alignment.center,
                                        child: IgnorePointer(
                                          child: ConfettiWidget(
                                            confettiController:
                                                _confettiController,
                                            blastDirectionality:
                                                BlastDirectionality.explosive,
                                            shouldLoop: false,
                                            emissionFrequency: 0.05,
                                            numberOfParticles: 30,
                                            maxBlastForce: 20,
                                            minBlastForce: 5,
                                            gravity: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                      ] else if (_tabController.index == 1)
                        LadderPanel(
                          key: _ladderKey,
                          names: p.map((e) => e.name).toList(),
                          afterResult: _afterResult,
                          onBusyChanged:
                              (busy) => setState(() => _modeBusy = busy),
                        )
                      else
                        TeamSplitPanel(
                          key: _teamKey,
                          names: p.map((e) => e.name).toList(),
                          afterResult: _afterResult,
                        ),
                    ], // SingleChildScrollView > Column children
                  ),
                ),
              ), // Expanded

              _ActionBar(child: _buildPrimaryAction(p, l10n)),
              SafeArea(top: false, child: const MyBannerAd()),
            ],
          ),
        );
      },
    );
  }
}

// ─── History BottomSheet ──────────────────────────────────────────────────────
class _HistorySheet extends StatelessWidget {
  final AppLocalizations l10n;
  const _HistorySheet({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    final entries =
        provider.history.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder:
          (_, scrollController) => Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history, color: _kAction, size: 20),
                        const SizedBox(width: 8),
                        _GradientText(
                          l10n.history,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (entries.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  backgroundColor: _kCard,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: _kBorder),
                                  ),
                                  title: Text(
                                    l10n.resetHistory,
                                    style: const TextStyle(color: _kText),
                                  ),
                                  content: Text(
                                    l10n.confirmResetHistory,
                                    style: const TextStyle(color: _kTextSub),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(l10n.cancel),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: _kAction,
                                      ),
                                      child: Text(l10n.reset),
                                      onPressed: () {
                                        provider.clearHistory();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                          );
                        },
                        child: Text(
                          l10n.reset,
                          style: const TextStyle(color: _kAction, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, color: _kBorder),

              // List
              Expanded(
                child:
                    entries.isEmpty
                        ? Center(
                          child: Text(
                            l10n.noHistory,
                            style: const TextStyle(
                              color: _kTextSub,
                              fontSize: 15,
                            ),
                          ),
                        )
                        : ListView.separated(
                          controller: null,
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: entries.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final e = entries[index];
                            final color =
                                _kWheelColors[index % _kWheelColors.length];
                            return Container(
                              decoration: BoxDecoration(
                                color: _kCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _kBorder),
                              ),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 2,
                                ),
                                leading: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _kSurface,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: color, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  e.key,
                                  style: const TextStyle(
                                    color: _kText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.emoji_events,
                                      color: _kSuccess,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${e.value}${l10n.times}',
                                      style: const TextStyle(
                                        color: _kSuccess,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
    );
  }
}

// ─── Preset BottomSheet ───────────────────────────────────────────────────────
class _PresetSheet extends StatefulWidget {
  final AppLocalizations l10n;
  const _PresetSheet({required this.l10n});

  @override
  State<_PresetSheet> createState() => _PresetSheetState();
}

class _PresetSheetState extends State<_PresetSheet> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showSaveDialog(BuildContext context, PlayerProvider provider) {
    _nameController.clear();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: _kCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: _kBorder),
            ),
            title: Text(
              widget.l10n.savePreset,
              style: const TextStyle(color: _kText),
            ),
            content: TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: _kText),
              decoration: InputDecoration(hintText: widget.l10n.presetNameHint),
              onSubmitted: (_) => _doSave(ctx, provider),
            ),
            actions: [
              TextButton(
                child: Text(widget.l10n.cancel),
                onPressed: () => Navigator.pop(ctx),
              ),
              TextButton(
                child: Text(widget.l10n.save),
                onPressed: () => _doSave(ctx, provider),
              ),
            ],
          ),
    );
  }

  Future<void> _doSave(BuildContext ctx, PlayerProvider provider) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.l10n.presetNameEmpty)));
      return;
    }
    await provider.savePreset(name);
    if (!mounted || !ctx.mounted) return;
    Navigator.pop(ctx);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(widget.l10n.presetSaved)));
  }

  void _showDeleteDialog(
    BuildContext context,
    PlayerProvider provider,
    int index,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: _kCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: _kBorder),
            ),
            title: Text(
              widget.l10n.deletePreset,
              style: const TextStyle(color: _kText),
            ),
            content: Text(
              widget.l10n.confirmDeletePreset,
              style: const TextStyle(color: _kTextSub),
            ),
            actions: [
              TextButton(
                child: Text(widget.l10n.cancel),
                onPressed: () => Navigator.pop(ctx),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: _kAction),
                child: Text(widget.l10n.deletePreset),
                onPressed: () {
                  provider.deletePreset(index);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    final presets = provider.presets;
    final hasPlayers = provider.players.isNotEmpty;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder:
          (_, scrollController) => Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.bookmark_outline,
                          color: _kAction,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        _GradientText(
                          widget.l10n.presets,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (hasPlayers)
                      GestureDetector(
                        onTap: () => _showSaveDialog(context, provider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _kAction.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _kAction),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.save_outlined,
                                size: 13,
                                color: _kAction,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.l10n.savePreset,
                                style: const TextStyle(
                                  color: _kAction,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, color: _kBorder),

              // List
              Expanded(
                child:
                    presets.isEmpty
                        ? Center(
                          child: Text(
                            widget.l10n.noPresets,
                            style: const TextStyle(
                              color: _kTextSub,
                              fontSize: 15,
                            ),
                          ),
                        )
                        : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: presets.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final preset = presets[index];
                            final color =
                                _kWheelColors[index % _kWheelColors.length];
                            return Container(
                              decoration: BoxDecoration(
                                color: _kCard,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _kBorder),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                minLeadingWidth: 12,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                title: Text(
                                  preset.name,
                                  style: const TextStyle(
                                    color: _kText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  preset.players.take(3).join(', ') +
                                      (preset.players.length > 3 ? '  …' : ''),
                                  style: const TextStyle(
                                    color: _kTextSub,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.l10n.presetPersonCount(
                                        preset.players.length,
                                      ),
                                      style: const TextStyle(
                                        color: _kTextSub,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        provider.loadPreset(index);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              widget.l10n.presetLoaded,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _kSuccess.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                          border: Border.all(
                                            color: _kSuccess.withOpacity(0.4),
                                          ),
                                        ),
                                        child: Text(
                                          widget.l10n.loadPreset,
                                          style: const TextStyle(
                                            color: _kSuccess,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap:
                                          () => _showDeleteDialog(
                                            context,
                                            provider,
                                            index,
                                          ),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: _kAction,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _GradientText(this.text, {required this.style});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style.copyWith(color: style.color ?? _kText));
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  const _StepperButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Material IconButton: 48dp target, ripple, focus and a TalkBack label.
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 16),
      style: IconButton.styleFrom(
        fixedSize: const Size(48, 48),
        foregroundColor: _kTextSub,
        disabledForegroundColor: _kBorder,
        backgroundColor: _kCard,
        disabledBackgroundColor: _kDisabled,
        side: const BorderSide(color: _kBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _WinnerDialog extends StatefulWidget {
  final List<Player> winners;
  final int participantCount;
  final VoidCallback onClose;
  final VoidCallback onSpinAgain;

  const _WinnerDialog({
    required this.winners,
    required this.participantCount,
    required this.onClose,
    required this.onSpinAgain,
  });

  @override
  State<_WinnerDialog> createState() => _WinnerDialogState();
}

class _WinnerDialogState extends State<_WinnerDialog> {
  final GlobalKey _shareKey = GlobalKey();
  bool _sharing = false;

  List<Player> get winners => widget.winners;
  VoidCallback get onClose => widget.onClose;
  VoidCallback get onSpinAgain => widget.onSpinAgain;

  Future<void> _share() async {
    if (_sharing) return;
    final l10n = AppLocalizations.of(context)!;
    final names = winners.map((w) => w.name).toList();
    final message = [
      l10n.shareMessage(widget.participantCount),
      for (var i = 0; i < names.length; i++)
        names.length > 1 ? '🏆 ${i + 1}. ${names[i]}' : '🏆 ${names[i]}',
      '',
      l10n.shareInvite,
    ].join('\n');
    final box = _shareKey.currentContext?.findRenderObject() as RenderBox?;
    final origin =
        box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _sharing = true);
    final ok = await shareResultText(
      message,
      mode: 'roulette',
      participants: widget.participantCount,
      winners: names.length,
      origin: origin,
    );
    if (!mounted) return;
    setState(() => _sharing = false);
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.shareFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _kCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _kBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _kSuccess,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              winners.length > 1
                  ? AppLocalizations.of(context)!.winnersTitle
                  : AppLocalizations.of(context)!.winnerTitle,
              style: const TextStyle(
                color: _kTextSub,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: winners.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final color = _kWheelColors[i % _kWheelColors.length];
                  final onColor =
                      _kWheelTextColors[i % _kWheelTextColors.length];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: onColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            winners[i].name,
                            style: const TextStyle(
                              color: _kText,
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              key: _shareKey,
              onPressed: _sharing ? null : _share,
              // Utility pill (DESIGN.md): grey surface, ink text, 20px radius.
              style: TextButton.styleFrom(
                backgroundColor: _kSurface,
                foregroundColor: _kText,
                disabledForegroundColor: _kDisabled,
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.share, size: 16),
              label: Text(AppLocalizations.of(context)!.shareResult),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kText,
                      side: const BorderSide(color: _kBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(AppLocalizations.of(context)!.close),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSpinAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAction,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(AppLocalizations.of(context)!.spinAgain),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// White strip with a top hairline that holds the current tab's primary
/// button, between the scrolling content and the banner.
/// Largest wheel and action-bar width; keeps tablets and landscape usable.
const double _kWheelMaxSize = 440;

/// Wheel spin length (the flutter_fortune_wheel default).
const Duration _kSpinDuration = Duration(seconds: 5);

class _ActionBar extends StatelessWidget {
  final Widget child;
  const _ActionBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kCard,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kWheelMaxSize),
          // Full width in every tab, like the roulette button.
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}
