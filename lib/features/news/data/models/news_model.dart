import '../../domain/entities/news_entity.dart';

class NewsModel extends NewsEntity {
  const NewsModel({
    required super.id,
    required super.titleEn,
    super.titleFa,
    required super.bodyEn,
    super.bodyFa,
    required super.source,
    super.imageUrl,
    required super.url,
    super.tags,
    required super.publishedAt,
    super.isFeatured,
  });

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      id: map[r'$id'] as String? ?? map['id'] as String,
      titleEn: map['title_en'] as String? ?? '',
      titleFa: map['title_fa'] as String?,
      bodyEn: map['body_en'] as String? ?? '',
      bodyFa: map['body_fa'] as String?,
      source: map['source'] as String? ?? '',
      imageUrl: map['image_url'] as String?,
      url: map['url'] as String? ?? '',
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      publishedAt: DateTime.tryParse(map['published_at'] as String? ?? '') ?? DateTime.now(),
      isFeatured: map['is_featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toCacheMap() {
    return {
      r'$id': id,
      'title_en': titleEn,
      'title_fa': titleFa,
      'body_en': bodyEn,
      'body_fa': bodyFa,
      'source': source,
      'image_url': imageUrl,
      'url': url,
      'tags': tags,
      'published_at': publishedAt.toIso8601String(),
      'is_featured': isFeatured,
    };
  }
}
