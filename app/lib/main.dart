import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/anime_list_page.dart';
import 'pages/anime_detail_page.dart';

/// Set at build time with:
/// flutter run -d chrome --dart-define=API_BASE_URL=https://massalini.pythonanywhere.com
/// flutter build web --release --dart-define=API_BASE_URL=https://massalini.pythonanywhere.com
const apiBase = String.fromEnvironment('API_BASE_URL', defaultValue: '');

void main() {
  runApp(const AniWikiApp());
}

class AniWikiApp extends StatelessWidget {
  const AniWikiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
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

    return MaterialApp.router(
      title: 'AniWiki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      routerConfig: router,
    );
  }
}
