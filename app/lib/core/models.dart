class PageMeta {
  final int page;
  final bool hasNextPage;
  final int count;
  const PageMeta({required this.page, required this.hasNextPage, required this.count});
  factory PageMeta.fromJson(Map<String, Object?> j) => PageMeta(
    page: (j['page'] as int?) ?? 1,
    hasNextPage: (j['hasNextPage'] as bool?) ?? false,
    count: (j['count'] as int?) ?? 0,
  );
}

class PageResp<T> {
  final List<T> data;
  final PageMeta meta;
  const PageResp({required this.data, required this.meta});
}

class AnimeItem {
  final int id;
  final String title;
  final String? image;
  final double? score;
  const AnimeItem({required this.id, required this.title, this.image, this.score});
  factory AnimeItem.fromJikan(Map<String, Object?> j) => AnimeItem(
    id: (j['mal_id'] as int?) ?? 0,
    title: (j['title'] as String?) ?? 'Unknown',
    image: ((j['images'] as Map<String, Object?>?)?['jpg'] as Map<String, Object?>?)?['image_url'] as String?,
    score: (j['score'] as num?)?.toDouble(),
  );
}

class AnimeFull {
  final int id;
  final String title;
  final String? synopsis;
  final String? image;
  final double? score;
  final int? episodes;
  final String? duration;
  final List<String> genres;
  AnimeFull({required this.id, required this.title, this.synopsis, this.image, this.score, this.episodes, this.duration, this.genres = const []});
  factory AnimeFull.fromJikan(Map<String, Object?> j) {
    final data = (j['data'] as Map<String, Object?>?) ?? const {};
    final genres = (data['genres'] as List<Object?>? ?? const [])
        .map((e) => ((e as Map<String, Object?>?)?['name'] as String?) ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
    return AnimeFull(
      id: (data['mal_id'] as int?) ?? 0,
      title: (data['title'] as String?) ?? 'Unknown',
      synopsis: data['synopsis'] as String?,
      image: ((data['images'] as Map<String, Object?>?)?['jpg'] as Map<String, Object?>?)?['image_url'] as String?,
      score: (data['score'] as num?)?.toDouble(),
      episodes: data['episodes'] as int?,
      duration: data['duration'] as String?,
      genres: genres,
    );
  }
}

class CharacterFull {
  final String name;
  final String? about;
  final String? image;
  CharacterFull({required this.name, this.about, this.image});
  factory CharacterFull.fromJikan(Map<String, Object?> j) {
    final data = (j['data'] as Map<String, Object?>?) ?? const {};
    return CharacterFull(
      name: (data['name'] as String?) ?? 'Unknown',
      about: data['about'] as String?,
      image: ((data['images'] as Map<String, Object?>?)?['jpg'] as Map<String, Object?>?)?['image_url'] as String?,
    );
  }
}