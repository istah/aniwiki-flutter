import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final String initialQuery;
  final void Function(String) onSearch;
  const SearchBarWidget({super.key, required this.initialQuery, required this.onSearch});
  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _c = TextEditingController(text: widget.initialQuery);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _c,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Search anime, manga, characters...'),
            onSubmitted: (v) => widget.onSearch(v.trim()),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: () => widget.onSearch(_c.text.trim()), child: const Text('Search')),
      ]),
    );
  }
}