import 'dart:convert';
import 'package:http/http.dart' as http;

// Read at build time:
// flutter run -d chrome --dart-define=API_BASE_URL=https://massalini.pythonanywhere.com
const apiBase = String.fromEnvironment('API_BASE_URL', defaultValue: '');

class ApiError implements Exception {
  final int status;
  final String message;
  ApiError(this.status, this.message);
  @override
  String toString() => 'ApiError($status): $message';
}

class AnimeSummary {
  final int id;
  final String title;
  final String? image;
  final double? score;
  final int? year;
  final String? type;
  final int? episodes;
  final List<String> genres;

  AnimeSummary({
    required this.id,
    required this.title,
    this.image,
    this.score,
    this.year,
    this.type,
    this.episodes,
    required this.genres,
  });

  factory AnimeSummary.fromJson(Map<String, dynamic> j) => AnimeSummary(
        id: j['id'] as int,
        title: (j['title'] ?? '') as String,
        image: j['image'] as String?,
        score: (j['score'] as num?)?.toDouble(),
        year: j['year'] as int?,
        type: j['type'] as String?,
        episodes: j['episodes'] as int?,
        genres: (j['genres'] as List).map((e) => e.toString()).toList(),
      );
}

class AnimeDetail {
  final int id;
  final String title;
  final String? synopsis;
  final String? image;
  final double? score;
  final int? rank;
  final int? popularity;
  final int? year;
  final String? type;
  final int? episodes;
  final String? duration;
  final List<String> genres;
  final String? trailerUrl;
  final String? youtubeId;

  AnimeDetail({
    required this.id,
    required this.title,
    this.synopsis,
    this.image,
    this.score,
    this.rank,
    this.popularity,
    this.year,
    this.type,
    this.episodes,
    this.duration,
    required this.genres,
    this.trailerUrl,
    this.youtubeId,
  });

  factory AnimeDetail.fromJson(Map<String, dynamic> j) => AnimeDetail(
        id: j['id'] as int,
        title: (j['title'] ?? '') as String,
        synopsis: j['synopsis'] as String?,
        image: j['image'] as String?,
        score: (j['score'] as num?)?.toDouble(),
        rank: j['rank'] as int?,
        popularity: j['popularity'] as int?,
        year: j['year'] as int?,
        type: j['type'] as String?,
        episodes: j['episodes'] as int?,
        duration: j['duration'] as String?,
        genres: (j['genres'] as List).map((e) => e.toString()).toList(),
        trailerUrl: (j['trailer']?['url']) as String?,
        youtubeId: (j['trailer']?['youtube_id']) as String?,
      );
}

class MangaSummary {
  final int id;
  final String title;
  final String? image;
  final double? score;
  final int? year;
  final String? type;
  final int? chapters;
  final int? volumes;
  final List<String> genres;

  MangaSummary({
    required this.id,
    required this.title,
    this.image,
    this.score,
    this.year,
    this.type,
    this.chapters,
    this.volumes,
    required this.genres,
  });

  factory MangaSummary.fromJson(Map<String, dynamic> j) => MangaSummary(
        id: j['id'] as int, // <-- cast
        title: (j['title'] ?? '') as String,
        image: j['image'] as String?,
        score: (j['score'] as num?)?.toDouble(),
        year: j['year'] as int?,
        type: j['type'] as String?,
        chapters: j['chapters'] as int?,
        volumes: j['volumes'] as int?,
        genres: (j['genres'] as List).map((e) => e.toString()).toList(),
      );
}

class CharacterSummary {
  final int id;
  final String name;
  final String? image;
  final int? favorites;
  final List<String> nicknames;

  CharacterSummary({
    required this.id,
    required this.name,
    this.image,
    this.favorites,
    required this.nicknames,
  });

  factory CharacterSummary.fromJson(Map<String, dynamic> j) => CharacterSummary(
        id: j['id'] as int, // <-- cast
        name: (j['name'] ?? '') as String,
        image: j['image'] as String?,
        favorites: j['favorites'] as int?,
        nicknames:
            (j['nicknames'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );
}

class AniWikiApi {
  final http.Client _client;
  AniWikiApi(this._client);

  static Uri _u(String path, [Map<String, dynamic>? q]) =>
      Uri.parse('$apiBase$path')
          .replace(queryParameters: q?.map((k, v) => MapEntry(k, '$v')));
          
  Future<({List<AnimeSummary> items, int page, bool hasNext})> search({
    required String q,
    required int page,
    required int limit,
  }) async {
    final r = await _client.get(_u('/api/anime/search', {
      'q': q,
      'page': page,
      'limit': limit,
    }));
    if (r.statusCode >= 400) {
      try {
        final err = jsonDecode(r.body);
        throw ApiError(r.statusCode, err['error']?['message']?.toString() ?? 'Error');
      } catch (_) {
        throw ApiError(r.statusCode, 'HTTP ${r.statusCode}');
      }
    }
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    final items = (j['items'] as List).map((e) => AnimeSummary.fromJson(e as Map<String, dynamic>)).toList();
    final int currentPage = (j['page'] as num?)?.toInt() ?? page;
    final bool hasNext = (j['hasNext'] as bool?) ?? false;
    return (items: items, page: currentPage, hasNext: hasNext);
  }

  Future<AnimeDetail> detail(int id) async {
    final r = await _client.get(_u('/api/anime/$id'));
    if (r.statusCode >= 400) {
      try {
        final err = jsonDecode(r.body);
        throw ApiError(r.statusCode, err['error']?['message']?.toString() ?? 'Error');
      } catch (_) {
        throw ApiError(r.statusCode, 'HTTP ${r.statusCode}');
      }
    }
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    return AnimeDetail.fromJson(j);
  }

  Future<({List<MangaSummary> items, int page, bool hasNext})> searchManga({
    required String q,
    required int page,
    required int limit,
  }) async {
    final r = await _client.get(_u('/api/manga/search', {
      'q': q,
      'page': page,
      'limit': limit,
    }));
    if (r.statusCode >= 400) {
      try {
        final err = jsonDecode(r.body);
        throw ApiError(
            r.statusCode, err['error']?['message']?.toString() ?? 'Error');
      } catch (_) {
        throw ApiError(r.statusCode, 'HTTP ${r.statusCode}');
      }
    }
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    final items = (j['items'] as List)
        .map((e) => MangaSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    final int currentPage = (j['page'] as num?)?.toInt() ?? page;
    final bool hasNext = (j['hasNext'] as bool?) ?? false;
    return (items: items, page: currentPage, hasNext: hasNext);
  }

  Future<({List<CharacterSummary> items, int page, bool hasNext})>
      searchCharacters({
    required String q,
    required int page,
    required int limit,
  }) async {
    final r = await _client.get(_u('/api/characters/search', {
      'q': q,
      'page': page,
      'limit': limit,
    }));
    if (r.statusCode >= 400) {
      try {
        final err = jsonDecode(r.body);
        throw ApiError(
            r.statusCode, err['error']?['message']?.toString() ?? 'Error');
      } catch (_) {
        throw ApiError(r.statusCode, 'HTTP ${r.statusCode}');
      }
    }
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    final items = (j['items'] as List)
        .map((e) => CharacterSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    final int currentPage = (j['page'] as num?)?.toInt() ?? page;
    final bool hasNext = (j['hasNext'] as bool?) ?? false;
    return (items: items, page: currentPage, hasNext: hasNext);
  }
}