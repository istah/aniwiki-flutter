import 'dart:io';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_logging/shelf_logging.dart';
import 'package:shelf_router/shelf_router.dart';
import '../lib/routes/anime.dart' as anime_routes;
import '../lib/routes/manga.dart' as manga_routes;
import '../lib/routes/characters.dart' as character_routes;
import '../lib/routes/ai.dart' as ai_routes;

Future<void> main(List<String> args) async {
  dotenv.load();
  final port = int.tryParse(Platform.environment['PORT'] ?? dotenv.env['PORT'] ?? '8787') ?? 8787;

  final router = Router()
    ..get('/health', (Request _) => Response.ok('{"ok":true}', headers: {'content-type': 'application/json'}))
    ..mount('/api/anime', anime_routes.router)
    ..mount('/api/manga', manga_routes.router)
    ..mount('/api/characters', character_routes.router)
    ..mount('/api/ai', ai_routes.router);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(loggingMiddleware(logRequests: true))
      .addMiddleware(corsHeaders())
      .addHandler(router);

  final server = await serve(handler, InternetAddress.anyIPv4, port);
  // ignore: avoid_print
  print('API listening on http://localhost:${server.port}');
}