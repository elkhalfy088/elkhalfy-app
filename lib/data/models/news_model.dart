class NewsModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String fullUrl;
  final String category;
  final String publishedAt;

  NewsModel({
    required this.id,
    required this.title,
    this.description = '',
    this.imageUrl = '',
    this.fullUrl = '',
    this.category = '',
    this.publishedAt = '',
  });

  factory NewsModel.fromDynamic(
    Map<String, dynamic> map,
    Map<String, dynamic> fieldMapping,
  ) {
    String _getValue(String fieldName) {
      if (fieldName.isEmpty) return '';
      final parts = fieldName.split('.');
      dynamic current = map;
      for (final part in parts) {
        if (current is Map) {
          current = current[part];
        } else {
          return '';
        }
      }
      return current?.toString() ?? '';
    }

    return NewsModel(
      id: map['id']?.toString() ?? map.hashCode.toString(),
      title: _getValue(fieldMapping['title'] ?? 'title'),
      description: _getValue(fieldMapping['description'] ?? 'description'),
      imageUrl: _getValue(fieldMapping['image'] ?? 'urlToImage'),
      fullUrl: _getValue(fieldMapping['url'] ?? 'url'),
      category: _getValue(fieldMapping['category'] ?? 'category'),
      publishedAt: _getValue(fieldMapping['date'] ?? 'publishedAt'),
    );
  }
}
