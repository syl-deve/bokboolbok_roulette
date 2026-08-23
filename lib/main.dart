import 'dart:async';
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
import 'iap_service.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFFFFFFFF);
const Color _kSurface = Color(0xFFF8F8F8);
const Color _kCard = Color(0xFFFFFFFF);
const Color _kBorder = Color(0xFFE0E0E0);
const Color _kText = Color(0xFF484848);
const Color _kTextSub = Color(0xFF727272);
const Color _kDisabled = Color(0xFFC8C8C8);
const Color _kAction = Color(0xFFE60012);
const Color _kSuccess = Color(0xFF468254);

const SystemUiOverlayStyle _kLightSystemUiStyle = SystemUiOverlayStyle(
  statusBarColor: _kBg,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: _kBg,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarDividerColor: _kBg,
  systemNavigationBarContrastEnforced: false,
);

const List<Color> _kWheelColors = [
  Color(0xFFEF4444),
  Color(0xFFF97316),
  Color(0xFFEAB308),
  Color(0xFF22C55E),
  Color(0xFF06B6D4),
  Color(0xFF3B82F6),
  Color(0xFF8B5CF6),
  Color(0xFFD946EF),
  Color(0xFFF43F5E),
];

// 각 휠 색상 위에서 가독성이 좋은 텍스트 색 (노랑·초록·청록은 밝아서 흰 글씨 대비가 낮음)
const List<Color> _kWheelTextColors = [
  Colors.white, // red
  Colors.white, // orange
  _kText, // yellow
  _kText, // green
  _kText, // cyan
  Colors.white, // blue
  Colors.white, // violet
  Colors.white, // fuchsia
  Colors.white, // rose
];
// ─────────────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(_kLightSystemUiStyle);
  MobileAds.instance.initialize();
  RequestConfiguration configuration = RequestConfiguration(
    testDeviceIds: ['D86D9B1F092E7C8CC61591C0B2B19CFE'],
  );
  MobileAds.instance.updateRequestConfiguration(configuration);
  AdHelper.loadInterstitialAd();
  final playerProvider = PlayerProvider();
  final minimumSplashDuration = Future<void>.delayed(
    const Duration(milliseconds: 1000),
  );
  try {
    await Future.wait<void>([
      playerProvider.loadFromPrefs(),
      minimumSplashDuration,
    ]);
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
            hintStyle: const TextStyle(color: _kBorder),
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

  void addPlayer(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty &&
        !_players.any((p) => p.name.toLowerCase() == trimmed.toLowerCase())) {
      _players.add(Player(trimmed));
      _saveToPrefs();
      notifyListeners();
    }
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

  String _encodeHistory() =>
      _history.entries.map((e) => '${e.key}:${e.value}').join('|');

  Map<String, int> _decodeHistory(String encoded) {
    final Map<String, int> map = {};
    for (final pair in encoded.split('|')) {
      final parts = pair.split(':');
      if (parts.length == 2) map[parts[0]] = int.tryParse(parts[1]) ?? 0;
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
  }
}

// ─── HomeScreen ───────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _iapService = IAPService();
    _iapService.onPurchaseSuccess = (success) {
      if (success && mounted) {
        context.read<PlayerProvider>().setAdFree(true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pro 버전이 활성화되었습니다!')));
      }
    };
  }

  @override
  void dispose() {
    _iapService.dispose();
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
  void _startSpinning(List<Player> p) {
    if (_isSpinning || p.length < 2) return;
    setState(() {
      _isSpinning = true;
      players = p;
      selectedIndexes.clear();
      confirmedIndexes.clear();
    });
    final isAdFree = context.read<PlayerProvider>().isAdFree;
    AdHelper.showInterstitialAd(() {
      if (!mounted) return;
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
    }, isAdFree: isAdFree);
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
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder:
          (ctx) => _WinnerDialog(
            winners: winners,
            onClose: () {
              Navigator.pop(ctx);
              _resetGame();
              _spinButtonFocusNode.requestFocus();
              _scrollToBottom();
            },
            onSpinAgain: () {
              Navigator.pop(ctx);
              _resetGame();
              FocusScope.of(context).unfocus();
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) _startSpinning(players);
              });
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

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        final p = provider.players;
        if (p.length > 1 && spinCount >= p.length) spinCount = p.length - 1;
        final l10n = AppLocalizations.of(context)!;

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
                // 구매 복원 버튼
                IconButton(
                  icon: const Icon(Icons.restore, color: _kAction, size: 20),
                  tooltip: l10n.restorePurchase,
                  onPressed: () => _iapService.restorePurchases(),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => _iapService.buyNonConsumable(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _kAction,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.removeAds,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ] else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.verified, color: _kSuccess, size: 24),
                  ),
                ),
            ],
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
                      Padding(
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
                                      onSubmitted: (_) {
                                        provider.addPlayer(_controller.text);
                                        _controller.clear();
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
                                  GestureDetector(
                                    onTap: () {
                                      provider.addPlayer(_controller.text);
                                      _controller.clear();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(6),
                                      padding: const EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                        color: _kAction,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

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

                            // Participants header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  GestureDetector(
                                    onTap: () {
                                      for (var i = p.length - 1; i >= 0; i--) {
                                        provider.removePlayer(i);
                                      }
                                    },
                                    child: Text(
                                      l10n.clearAll,
                                      style: const TextStyle(
                                        color: _kAction,
                                        fontSize: 12,
                                      ),
                                    ),
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
                                        height: 48,
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 4,
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
                                                p[index].name.substring(0, 1),
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
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: _kText,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap:
                                                  () => provider.removePlayer(
                                                    index,
                                                  ),
                                              child: const SizedBox(
                                                width: 44,
                                                height: 44,
                                                child: Icon(
                                                  Icons.close,
                                                  color: _kTextSub,
                                                  size: 18,
                                                ),
                                              ),
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
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed:
                                      () => _showHistorySheet(context, l10n),
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
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Wheel section ───────────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Wheel (AspectRatio로 정사각형 고정)
                            Stack(
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
                                              color: Colors.black.withOpacity(
                                                0.07,
                                              ),
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
                                                    style: const TextStyle(
                                                      color: _kTextSub,
                                                    ),
                                                  ),
                                                )
                                                : FortuneWheel(
                                                  selected: _selected.stream,
                                                  animateFirst: false,
                                                  indicators: const [
                                                    FortuneIndicator(
                                                      alignment:
                                                          Alignment.topCenter,
                                                      child: TriangleIndicator(
                                                        color: Colors.white,
                                                        width: 28,
                                                        height: 28,
                                                      ),
                                                    ),
                                                  ],
                                                  physics: CircularPanPhysics(
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                    curve: Curves.easeOutCubic,
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
                                                            textColor == _kText;
                                                        // 참가자가 많을수록 조각이 좁아지므로
                                                        // 기본 글자 크기를 줄이고, 이름이 길면 추가로 축소
                                                        final baseFontSize =
                                                            p.length <= 3
                                                                ? 26.0
                                                                : p.length <= 5
                                                                ? 22.0
                                                                : p.length <= 8
                                                                ? 18.0
                                                                : 14.0;
                                                        return FortuneItem(
                                                          child: FittedBox(
                                                            fit:
                                                                BoxFit
                                                                    .scaleDown,
                                                            child: Text(
                                                              e.value.name,
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
                                                            borderWidth: 3,
                                                          ),
                                                        );
                                                      }).toList(),
                                                  onAnimationEnd: () {
                                                    _spinPlayer.stop();
                                                    if (resultIndex == null ||
                                                        resultIndex! >=
                                                            p.length)
                                                      return;
                                                    final ci = resultIndex!;
                                                    provider.addHistory(
                                                      p[ci].name,
                                                    );
                                                    setState(() {
                                                      selectedIndexes.add(ci);
                                                      confirmedIndexes.add(ci);
                                                    });
                                                    if (confirmedIndexes
                                                            .length ==
                                                        spinCount) {
                                                      HapticFeedback.heavyImpact();
                                                      Future.delayed(
                                                        const Duration(
                                                          milliseconds: 120,
                                                        ),
                                                        HapticFeedback
                                                            .heavyImpact,
                                                      );
                                                      Future.delayed(
                                                        const Duration(
                                                          milliseconds: 240,
                                                        ),
                                                        HapticFeedback
                                                            .heavyImpact,
                                                      );
                                                      _winPlayer.play(
                                                        AssetSource(
                                                          'sounds/win.wav',
                                                        ),
                                                      );
                                                      _confettiController
                                                          .play();
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
                                      confettiController: _confettiController,
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
                          ],
                        ),
                      ),

                      // ── Spin button section ──────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Column(
                          children: [
                            if (!_isSpinning && p.length >= 2)
                              _GradientSpinButton(
                                label: l10n.spinRoulette,
                                focusNode: _spinButtonFocusNode,
                                onPressed: () {
                                  _resetGame();
                                  _startSpinning(p);
                                },
                              )
                            else if (_isSpinning)
                              const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: _kSuccess,
                                ),
                              )
                            else
                              const SizedBox(height: 54),
                            const SizedBox(height: 5),
                            Text(
                              _isSpinning
                                  ? l10n.findingWinner(
                                    confirmedIndexes.length + 1,
                                    spinCount,
                                  )
                                  : l10n.selectingWinners(spinCount),
                              style: const TextStyle(
                                color: _kTextSub,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ], // SingleChildScrollView > Column children
                  ),
                ),
              ), // Expanded

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
                                border: Border(
                                  left: BorderSide(color: color, width: 4),
                                ),
                              ),
                              child: ListTile(
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
  final VoidCallback? onPressed;
  const _StepperButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? _kCard : _kDisabled,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBorder),
        ),
        child: Icon(icon, size: 16, color: enabled ? _kTextSub : _kBorder),
      ),
    );
  }
}

class _GradientSpinButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final FocusNode? focusNode;
  const _GradientSpinButton({
    required this.label,
    required this.onPressed,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _kAction,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _WinnerDialog extends StatelessWidget {
  final List<Player> winners;
  final VoidCallback onClose;
  final VoidCallback onSpinAgain;

  const _WinnerDialog({
    required this.winners,
    required this.onClose,
    required this.onSpinAgain,
  });

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
            const SizedBox(height: 20),
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
