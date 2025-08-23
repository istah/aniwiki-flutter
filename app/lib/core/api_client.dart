import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

// Укажи прод-URL бэкенда после деплоя
const String BASE_URL = 'http://localhost:8787';

Future<PageResp<AnimeItem>> fetchAnimeList({int page = 1, String? q}) async {
  final uri = Uri.parse('$BASE_URL/api/anime').replace(queryParameters: {
    'page': '$page',
    if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
  });
  final res = await http.get(uri);
  if (res.statusCode != 200) throw Exception('API ${res.statusCode}: ${res.body}');
  final j = json.decode(res.body) as Map<String, Object?>;
  final list = (j['data'] as List<Object?>? ?? const [])
      .map((e) => AnimeItem.fromJikan((e as Map<String, Object?>?)?.cast<String, Object?>() ?? const {}))
      .toList();
  final meta = PageMeta.fromJson((j['meta'] as Map<String, Object?>?)?.cast<String, Object?>() ?? const {});
  return PageResp<AnimeItem>(data: list, meta: meta);
}

Future<AnimeFull> fetchAnimeFull(int id) async {
  final uri = Uri.parse('$BASE_URL/api/anime/$id');
  final res = await http.get(uri);
  if (res.statusCode != 200) throw Exception('API ${res.statusCode}: ${res.body}');
  final j = json.decode(res.body) as Map<String, Object?>;
  return AnimeFull.fromJikan(j);
}

Future<CharacterFull> fetchCharacterFull(int id) async {
  final uri = Uri.parse('$BASE_URL/api/characters/$id');
  final res = await http.get(uri);
  if (res.statusCode != 200) throw Exception('API ${res.statusCode}: ${res.body}');
  final j = json.decode(res.body) as Map<String, Object?>;
  return CharacterFull.fromJikan(j);
}

Future<String> aiEnrich({required String title, String? synopsis}) async {
  final uri = Uri.parse('$BASE_URL/api/ai/describe');
  final res = await http.post(uri, headers: {'content-type': 'application/json'}, body: json.encode({'title': title, 'synopsis': synopsis}));
  if (res.statusCode == 501) return 'AI not configured';
  if (res.statusCode != 200) throw Exception('API ${res.statusCode}: ${res.body}');
  final j = json.decode(res.body) as Map<String, Object?>;
  return (j['text'] as String?) ?? '';
}