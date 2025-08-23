import 'dart:convert';
import 'package:http/http.dart' as http;

class JikanClient {
  static const _base = 'https://api.jikan.moe/v4';

  Future<Map<String, Object?>> _get(String path) async {
    final uri = Uri.parse('$_base$path');
    final res = await http.get(uri, headers: {'User-Agent': 'aniwiki-backend'});
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return json.decode(res.body) as Map<String, Object?>;
  }

  Future<Map<String, Object?>> listAnime(int page) => _get('/anime?page=$page&order_by=score&sort=desc');
  Future<Map<String, Object?>> searchAnime(String q, int page) => _get('/anime?q=${Uri.encodeQueryComponent(q)}&page=$page');
  Future<Map<String, Object?>> getAnime(String id) => _get('/anime/$id/full');

  Future<Map<String, Object?>> searchCharacters(String q, int page) => _get('/characters?q=${Uri.encodeQueryComponent(q)}&page=$page');
  Future<Map<String, Object?>> getCharacter(String id) => _get('/characters/$id/full');

  Future<Map<String, Object?>> searchManga(String q, int page) => _get('/manga?q=${Uri.encodeQueryComponent(q)}&page=$page');
  Future<Map<String, Object?>> getManga(String id) => _get('/manga/$id/full');
}