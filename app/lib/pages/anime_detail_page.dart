import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import '../api/aniwiki_api.dart';

class AnimeDetailPage extends StatefulWidget {
  final int id;
  const AnimeDetailPage({super.key, required this.id});

  @override
  State<AnimeDetailPage> createState() => _AnimeDetailPageState();
}

class _AnimeDetailPageState extends State<AnimeDetailPage> {
  final _api = AniWikiApi(http.Client());
  bool _loading = true;
  String? _error;
  AnimeDetail? _data;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final d = await _api.detail(widget.id);
      setState(() => _data = d);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Anime #${widget.id}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _data == null
                  ? const Center(child: Text('No data'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 260,
                            height: 360,
                            child: _data!.image != null
                                ? CachedNetworkImage(imageUrl: _data!.image!, fit: BoxFit.cover)
                                : const ColoredBox(color: Colors.black12),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_data!.title, style: Theme.of(context).textTheme.headlineSmall),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: _data!.genres.map((g) => Chip(label: Text(g))).toList(),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (_data!.score != null) Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Row(children: [const Icon(Icons.star), Text('${_data!.score}')]),
                                    ),
                                    if (_data!.year != null) Text('${_data!.year}'),
                                    const SizedBox(width: 16),
                                    if (_data!.episodes != null) Text('${_data!.episodes} eps'),
                                    const SizedBox(width: 16),
                                    if (_data!.duration != null) Text(_data!.duration!),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (_data!.synopsis != null) Text(_data!.synopsis!),
                                const SizedBox(height: 16),
                                if (_data!.trailerUrl != null)
                                  TextButton.icon(
                                    onPressed: () {
                                      html.window.open(_data!.trailerUrl!, '_blank');
                                    },
                                    icon: const Icon(Icons.ondemand_video),
                                    label: const Text('Open trailer'),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}