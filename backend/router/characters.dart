import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../jikan_client.dart';
import '../pagination.dart';

final _client = JikanClient();

Router get router {
  final r = Router();

  r.get('/', (Request req) async {
    final page = int.tryParse(req.requestedUri.queryParameters['page'] ?? '1') ?? 1;
    final q = (req.requestedUri.queryParameters['q'] ?? 'a').trim();
    final raw = await _client.searchCharacters(q.isEmpty ? 'a' : q, page);
    final normalized = normalizePage(raw.cast<String, Object?>());
    return Response.ok(json.encode(normalized), headers: {'content-type': 'application/json'});
  });

  r.get('/<id|[0-9]+>', (Request req, String id) async {
    final raw = await _client.getCharacter(id);
    return Response.ok(json.encode(raw), headers: {'content-type': 'application/json'});
  });

  return r;
}