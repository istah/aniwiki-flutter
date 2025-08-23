import 'package:flutter/material.dart';

class AnimeCard extends StatelessWidget {
  final int id;
  final String title;
  final String? imageUrl;
  final double? score;
  final VoidCallback onTap;
  const AnimeCard({super.key, required this.id, required this.title, this.imageUrl, this.score, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: imageUrl != null ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.network(imageUrl!, fit: BoxFit.cover)) : Container(height: 120, color: Theme.of(context).colorScheme.surfaceVariant)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (score != null) Text('⭐ ${score!.toStringAsFixed(1)}', style: Theme.of(context).textTheme.bodySmall),
            ]),
          )
        ]),
      ),
    );
  }
}