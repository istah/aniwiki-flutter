class PageMeta {
  final int page;
  final bool hasNextPage;
  final int count;
  const PageMeta({required this.page, required this.hasNextPage, required this.count});
  Map<String, Object> toJson() => {'page': page, 'hasNextPage': hasNextPage, 'count': count};
}

Map<String, Object> normalizePage(Map<String, Object?> jikan) {
  final pagination = (jikan['pagination'] as Map<String, Object?>?) ?? const {};
  final items = (pagination['items'] as Map<String, Object?>?) ?? const {};
  final data = (jikan['data'] as List<Object>?) ?? const [];
  return {
    'data': data,
    'meta': PageMeta(
      page: (pagination['current_page'] as int?) ?? 1,
      hasNextPage: (pagination['has_next_page'] as bool?) ?? false,
      count: (items['count'] as int?) ?? data.length,
    ).toJson(),
  };
}