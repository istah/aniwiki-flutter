import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/api_client.dart';
import '../core/models.dart';
import '../widgets/anime_card.dart';
import '../widgets/pagination.dart';
import '../widgets/search_bar.dart';
import '../widgets/skeleton.dart';

class SearchPage extends StatefulWidget {
  final String query;
  final int page;
  const SearchPage({super.key, required this.query, this.page = 1});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  PageResp<AnimeItem>? data;
  bool loading = true;
  String? err;
  late String q = widget.query;
  int page = 1;

  @override
  void initState() {
    super.initState();
    page = widget.page;
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; err = null; });
    try {
      final r = await fetchAnimeList(page: page, q: q.isEmpty ? null : q);
      setState(() => data = r);
    } catch (e) {
      setState(() => err = e.toString());
    } finally { setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SearchBarWidget(initialQuery: q, onSearch: (v) { setState(() { q = v; page = 1; }); _load(); context.go('/search?q=${Uri.encodeQueryComponent(q)}&page=$page'); }),
          const SizedBox(height: 12),
          Text('Results for "$q"', style: Theme.of(context).textTheme.titleLarge),
          if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
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
          Pager(page: data?.meta.page ?? page, hasNext: data?.meta.hasNextPage ?? true, onPage: (p) { setState(() { page = p; }); _load(); context.go('/search?q=${Uri.encodeQueryComponent(q)}&page=$page'); }),
        ]),
      ),
    );
  }
}