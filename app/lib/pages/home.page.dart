import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/api_client.dart';
import '../core/models.dart';
import '../core/theme_controller.dart';
import '../widgets/anime_card.dart';
import '../widgets/pagination.dart';
import '../widgets/skeleton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  PageResp<AnimeItem>? data;
  bool loading = true;
  String? err;
  int page = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; err = null; });
    try {
      final r = await fetchAnimeList(page: page);
      setState(() => data = r);
    } catch (e) {
      setState(() => err = e.toString());
    } finally { setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AniWiki'),
        actions: [
          IconButton(
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Toggle theme',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Top Anime', style: Theme.of(context).textTheme.titleLarge)),
            TextButton(onPressed: () => context.go('/search?q=naruto'), child: const Text('Search')),
          ]),
          const SizedBox(height: 8),
          if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
          Expanded(
            child: loading
                ? GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: 8,
                    itemBuilder: (_, __) => const SkeletonBox(),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: data!.data.length,
                    itemBuilder: (_, i) {
                      final a = data!.data[i];
                      return AnimeCard(
                        id: a.id, title: a.title, imageUrl: a.image, score: a.score,
                        onTap: () => context.go('/anime/${a.id}'),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          Pager(page: data?.meta.page ?? page, hasNext: data?.meta.hasNextPage ?? true, onPage: (p) { setState(() { page = p; }); _load(); }),
        ]),
      ),
    );
  }
}