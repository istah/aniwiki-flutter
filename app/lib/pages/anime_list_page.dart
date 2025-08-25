import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import '../main.dart' show ThemeControllerProvider;

import '../api/aniwiki_api.dart';

enum MediaTab { anime, manga, characters }

class AnimeListPage extends StatefulWidget {
  const AnimeListPage({super.key});

  @override
  State<AnimeListPage> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  final _api = AniWikiApi(http.Client());

  // Per-tab query controllers
  final _qAnime = TextEditingController(text: '');
  final _qManga = TextEditingController(text: '');
  final _qChars = TextEditingController(text: '');

  // Per-tab pagination
  int _pageAnime = 1;
  int _pageManga = 1;
  int _pageChars = 1;
  final int _limit = 24;

  // Per-tab data
  List<AnimeSummary> _anime = [];
  List<MangaSummary> _manga = [];
  List<CharacterSummary> _chars = [];

  bool _hasNextAnime = false;
  bool _hasNextManga = false;
  bool _hasNextChars = false;

  // Shared flags
  bool _loading = true;
  String? _error;
  MediaTab _tab = MediaTab.anime;

  @override
  void initState() {
    super.initState();
    _fetch(); // initial anime fetch
  }

  @override
  void dispose() {
    _qAnime.dispose();
    _qManga.dispose();
    _qChars.dispose();
    super.dispose();
  }

  TextEditingController get _activeController => switch (_tab) {
        MediaTab.anime => _qAnime,
        MediaTab.manga => _qManga,
        MediaTab.characters => _qChars,
      };

  int get _activePage => switch (_tab) {
        MediaTab.anime => _pageAnime,
        MediaTab.manga => _pageManga,
        MediaTab.characters => _pageChars,
      };

  bool get _activeHasNext => switch (_tab) {
        MediaTab.anime => _hasNextAnime,
        MediaTab.manga => _hasNextManga,
        MediaTab.characters => _hasNextChars,
      };

  set _activePage(int value) {
    setState(() {
      switch (_tab) {
        case MediaTab.anime:
          _pageAnime = value;
          break;
        case MediaTab.manga:
          _pageManga = value;
          break;
        case MediaTab.characters:
          _pageChars = value;
          break;
      }
    });
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      switch (_tab) {
        case MediaTab.anime:
          final res = await _api.search(q: _qAnime.text.trim(), page: _pageAnime, limit: _limit);
          setState(() {
            _anime = res.items;
            _hasNextAnime = res.hasNext;
          });
          break;
        case MediaTab.manga:
          final res = await _api.searchManga(q: _qManga.text.trim(), page: _pageManga, limit: _limit);
          setState(() {
            _manga = res.items;
            _hasNextManga = res.hasNext;
          });
          break;
        case MediaTab.characters:
          final res = await _api.searchCharacters(q: _qChars.text.trim(), page: _pageChars, limit: _limit);
          setState(() {
            _chars = res.items;
            _hasNextChars = res.hasNext;
          });
          break;
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TabBar(
              onTap: (i) {
                setState(() => _tab = MediaTab.values[i]);
                // Lazy load when switching to an empty tab
                if ((_tab == MediaTab.manga && _manga.isEmpty) ||
                    (_tab == MediaTab.characters && _chars.isEmpty)) {
                  _fetch();
                }
              },
              tabs: const [
                Tab(text: 'Anime'),
                Tab(text: 'Manga'),
                Tab(text: 'Characters'),
              ],
            ),
          ),

          // Search row + actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _activeController,
                    decoration: InputDecoration(
                      hintText: switch (_tab) {
                        MediaTab.anime => 'Search anime…',
                        MediaTab.manga => 'Search manga…',
                        MediaTab.characters => 'Search characters…',
                      },
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) {
                      _activePage = 1;
                      _fetch();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Theme toggle
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
                  onPressed: () {
                    _activePage = 1;
                    _fetch();
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),
          ),

          // Loading skeleton
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
                itemBuilder: (_, __) => const _CardSkeleton(),
              ),
            ),

          // Error card
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

          // Content grid
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
                itemCount: switch (_tab) {
                  MediaTab.anime => _anime.length,
                  MediaTab.manga => _manga.length,
                  MediaTab.characters => _chars.length,
                },
                itemBuilder: (_, i) {
                  switch (_tab) {
                    case MediaTab.anime:
                      final it = _anime[i];
                      return _AnimeCard(
                        title: it.title,
                        image: it.image,
                        subtitleChips: it.genres.take(3).toList(),
                        trailing: Row(
                          children: [
                            if (it.score != null) ...[
                              const Icon(Icons.star, size: 16),
                              const SizedBox(width: 4),
                              Text('${it.score}')
                            ],
                            const Spacer(),
                            Text(it.year?.toString() ?? ''),
                          ],
                        ),
                        onTap: () => context.go('/anime/${it.id}'),
                      );
                    case MediaTab.manga:
                      final it = _manga[i];
                      final stats = <Widget>[];
                      if (it.score != null) {
                        stats.addAll([const Icon(Icons.star, size: 16), const SizedBox(width: 4), Text('${it.score}')]);
                      }
                      stats.add(const Spacer());
                      if (it.chapters != null) {
                        stats.add(Text('${it.chapters} ch'));
                      } else if (it.year != null) {
                        stats.add(Text('${it.year}'));
                      }
                      return _AnimeCard(
                        title: it.title,
                        image: it.image,
                        subtitleChips: it.genres.take(3).toList(),
                        trailing: Row(children: stats),
                        onTap: null, // TODO: add manga detail route later
                      );
                    case MediaTab.characters:
                      final it = _chars[i];
                      return _AnimeCard(
                        title: it.name,
                        image: it.image,
                        subtitleChips: it.nicknames.take(2).toList(),
                        trailing: Row(
                          children: [
                            const Icon(Icons.favorite, size: 16),
                            const SizedBox(width: 4),
                            Text('${it.favorites ?? 0}'),
                          ],
                        ),
                        onTap: null, // TODO: add character detail route later
                      );
                  }
                },
              ),
            ),

          // Pagination
          if (!_loading && _error == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: _activePage > 1
                        ? () {
                            _activePage = _activePage - 1;
                            _fetch();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Prev'),
                  ),
                  const SizedBox(width: 8),
                  Text('Page ${_activePage}'),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _activeHasNext
                        ? () {
                            _activePage = _activePage + 1;
                            _fetch();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Reusable card for all three tabs
class _AnimeCard extends StatelessWidget {
  final String title;
  final String? image;
  final List<String> subtitleChips;
  final Widget trailing;
  final VoidCallback? onTap;
  const _AnimeCard({
    required this.title,
    required this.image,
    required this.subtitleChips,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: image != null
                  ? CachedNetworkImage(imageUrl: image!, fit: BoxFit.cover)
                  : const ColoredBox(color: Colors.black12),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: subtitleChips
                        .map((g) => Chip(
                              label: Text(g),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 6),
                  trailing,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();
  @override
  Widget build(BuildContext context) {
    return const Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(child: _SkeletonBox(borderRadius: BorderRadius.zero)),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  const _SkeletonBox({
    this.height = 12,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    super.key,
  });
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