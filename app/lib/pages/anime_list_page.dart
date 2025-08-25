import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

import '../api/aniwiki_api.dart';
import 'anime_detail_page.dart';

class AnimeListPage extends StatefulWidget {
  const AnimeListPage({super.key});

  @override
  State<AnimeListPage> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  final _api = AniWikiApi(http.Client());
  final _qCtl = TextEditingController(text: '');
  int _page = 1;
  final int _limit = 24;
  bool _loading = true;
  bool _hasNext = false;
  List<AnimeSummary> _items = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _api.search(q: _qCtl.text.trim(), page: _page, limit: _limit);
      setState(() {
        _items = res.items;
        _hasNext = res.hasNext;
      });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  void dispose() {
    _qCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qCtl,
                  decoration: const InputDecoration(
                    hintText: 'Search anime…',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) { _page = 1; _fetch(); },
                ),
              ),
              const SizedBox(width: 8),
              // Theme toggle (placeholder wiring; functionality will be added next)
              IconButton(
  tooltip: 'Toggle theme',
  onPressed: () {
    final controller = ThemeControllerProvider.of(context);
    controller.cycle();
  },
  icon: Icon(
    Theme.of(context).brightness == Brightness.dark
        ? Icons.dark_mode
        : Icons.light_mode,
  ),
),
              const SizedBox(width: 4),
              FilledButton.icon(
                onPressed: () { _page = 1; _fetch(); },
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ],
          ),
        ),
        if (_loading)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.62,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 12,
              itemBuilder: (_, __) => Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    const Expanded(
                      child: _SkeletonBox(borderRadius: BorderRadius.zero),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _SkeletonBox(height: 14, width: 160),
                          SizedBox(height: 8),
                          _SkeletonBox(height: 12, width: 80),
                          SizedBox(height: 8),
                          _SkeletonBox(height: 12, width: 60),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _fetch,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (!_loading && _error == null)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.62,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final it = _items[i];
                return InkWell(
                  onTap: () => context.go('/anime/${it.id}'),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Expanded(
                          child: it.image != null
                              ? CachedNetworkImage(imageUrl: it.image!, fit: BoxFit.cover)
                              : const ColoredBox(color: Colors.black12),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                it.title,
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: it.genres.take(3).map((g) => Chip(
                                  label: Text(g),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                )).toList(),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (it.score != null)
                                    Flexible(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star, size: 16),
                                          const SizedBox(width: 4),
                                          Flexible(child: Text('${it.score}', overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    ),
                                  const Spacer(),
                                  Text(it.year?.toString() ?? ''),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (!_loading && _error == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _page > 1 ? () { setState(() => _page -= 1); _fetch(); } : null,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Prev'),
                ),
                Text('Page $_page'),
                OutlinedButton.icon(
                  onPressed: _hasNext ? () { setState(() => _page += 1); _fetch(); } : null,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  const _SkeletonBox({this.height = 12, this.width, this.borderRadius = const BorderRadius.all(Radius.circular(6)), super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: borderRadius,
      ),
    );
  }
}