import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/models.dart';

class CharacterDetailsPage extends StatefulWidget {
  final int id;
  const CharacterDetailsPage({super.key, required this.id});
  @override
  State<CharacterDetailsPage> createState() => _CharacterDetailsPageState();
}

class _CharacterDetailsPageState extends State<CharacterDetailsPage> {
  CharacterFull? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final r = await fetchCharacterFull(widget.id);
    setState(() { data = r; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (loading || data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final c = data!;
    return Scaffold(
      appBar: AppBar(title: Text(c.name)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 200, height: 280, child: c.image != null ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(c.image!, fit: BoxFit.cover)) : const ColoredBox(color: Colors.black12)),
          const SizedBox(width: 16),
          Expanded(child: Text(c.about ?? 'No bio.'))
        ]),
      ),
    );
  }
}