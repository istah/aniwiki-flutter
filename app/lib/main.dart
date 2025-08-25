import 'package:flutter/material.dart';

import 'pages/anime_list_page.dart';

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
    return MaterialApp(
      title: 'AniWiki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: AnimeListPage(),
        ),
      ),
    );
  }
}
