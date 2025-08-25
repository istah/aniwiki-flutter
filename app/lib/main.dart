import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/anime_list_page.dart';
import 'pages/anime_detail_page.dart';

/// Set at build time with:
/// flutter run -d chrome --dart-define=API_BASE_URL=https://massalini.pythonanywhere.com
/// flutter build web --release --dart-define=API_BASE_URL=https://massalini.pythonanywhere.com
const apiBase = String.fromEnvironment('API_BASE_URL', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('theme_mode');
  final initialMode = _decodeTheme(saved);
  runApp(AniWikiApp(prefs: prefs, initialMode: initialMode));
}

class AniWikiApp extends StatefulWidget {
  final SharedPreferences prefs;
  final ThemeMode initialMode;
  const AniWikiApp({super.key, required this.prefs, required this.initialMode});

  @override
  State<AniWikiApp> createState() => _AniWikiAppState();
}

class _AniWikiAppState extends State<AniWikiApp> {
  late final ThemeController _controller;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _controller = ThemeController(mode: widget.initialMode, prefs: widget.prefs);
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: SafeArea(child: AnimeListPage()),
          ),
          routes: [
            GoRoute(
              path: 'anime/:id',
              builder: (context, state) {
                final idStr = state.pathParameters['id'];
                final id = int.tryParse(idStr ?? '');
                return Scaffold(
                  body: SafeArea(
                    child: id == null
                        ? const Center(child: Text('Invalid anime id'))
                        : AnimeDetailPage(id: id),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeControllerProvider(
      controller: _controller,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => MaterialApp.router(
          title: 'AniWiki',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: _controller.mode,
          routerConfig: _router,
        ),
      ),
    );
  }
}

/// Simple ChangeNotifier-based theme controller with persistence.
class ThemeController extends ChangeNotifier {
  ThemeMode mode;
  final SharedPreferences prefs;
  ThemeController({required this.mode, required this.prefs});

  void setMode(ThemeMode m) {
    if (mode == m) return;
    mode = m;
    prefs.setString('theme_mode', _encodeTheme(m));
    notifyListeners();
  }

  /// Cycles System → Light → Dark → System
  void cycle() {
    switch (mode) {
      case ThemeMode.system:
        setMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        setMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setMode(ThemeMode.system);
        break;
    }
  }
}

class ThemeControllerProvider extends InheritedNotifier<ThemeController> {
  const ThemeControllerProvider({super.key, required ThemeController controller, required Widget child})
      : super(notifier: controller, child: child);

  static ThemeController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ThemeControllerProvider>();
    assert(provider != null, 'ThemeControllerProvider not found in context');
    return provider!.notifier!;
    }
}

String _encodeTheme(ThemeMode m) => switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };

ThemeMode _decodeTheme(String? s) {
  return switch (s) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
