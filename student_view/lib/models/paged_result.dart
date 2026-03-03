class PagedResult<T> {
  PagedResult({
    required this.records,
    required this.total,
    required this.page,
    required this.size,
  });

  final List<T> records;
  final int total;
  final int page;
  final int size;

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic raw) itemParser,
  ) {
    final rawRecords = (json['records'] as List<dynamic>? ?? []);
    return PagedResult<T>(
      records: rawRecords.map(itemParser).toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
    );
  }
}
