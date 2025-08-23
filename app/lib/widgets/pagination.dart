import 'package:flutter/material.dart';

class Pager extends StatelessWidget {
  final int page;
  final bool hasNext;
  final void Function(int) onPage;
  const Pager({super.key, required this.page, required this.hasNext, required this.onPage});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      OutlinedButton(onPressed: page > 1 ? () => onPage(page - 1) : null, child: const Text('Prev')),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('Page $page')),
      OutlinedButton(onPressed: hasNext ? () => onPage(page + 1) : null, child: const Text('Next')),
    ]);
  }
}