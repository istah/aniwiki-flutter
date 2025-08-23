import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/models.dart';

class AnimeDetailsPage extends StatefulWidget {
  final int id;
  const AnimeDetailsPage({super.key, required this.id});
  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  AnimeFull? data;
  String? ai;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final r = await fetchAnimeFull(widget.id);
    setState(() { data = r; loading = false; });
  }

  Future<void> _enrich() async {
    final res = await aiEnrich(title: data!.title, synopsis: data!.synopsis);
    setState(() => ai = res);
  }

  @override
  Widget build(BuildContext context) {
    if (loading || data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final a = data!;
    return Scaffold(
      appBar: AppBar(title: Text(a.title)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 200, height: 280, child: a.image != null ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(a.image!, fit: BoxFit.cover)) : const ColoredBox(color: Colors.black12)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(a.genres.join(', '), style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(a.synopsis ?? 'No synopsis.'),
              const SizedBox(height: 8),
              Text('⭐ ${a.score?.toStringAsFixed(1) ?? 'n/a'} • ${a.episodes ?? '?'} eps • ${a.duration ?? '?'}', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _enrich, child: const Text('AI: Enrich Description')),
              if (ai != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(ai!)),
            ]))
          ])
        ]),
      ),
    );
  }
}