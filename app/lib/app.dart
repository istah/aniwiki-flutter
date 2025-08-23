import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme_controller.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/anime_details_page.dart';
import 'pages/character_details_page.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const HomePage()),
    GoRoute(path: '/search', builder: (ctx, st) => SearchPage(
      query: st.uri.queryParameters['q'] ?? '',
      page: int.tryParse(st.uri.queryParameters['page'] ?? '1') ?? 1)),
    GoRoute(path: '/anime/:id', builder: (ctx, st) => AnimeDetailsPage(id: int.parse(st.pathParameters['id']!))),
    GoRoute(path: '/characters/:id', builder: (ctx, st) => CharacterDetailsPage(id: int.parse(st.pathParameters['id']!))),
  ],
);

class AniWikiApp extends ConsumerWidget {
  const AniWikiApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'AniWiki',
      themeMode: themeMode,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1))),
      darkTheme: ThemeData.dark(useMaterial3: true),
      routerConfig: _router,
    );
  }
}