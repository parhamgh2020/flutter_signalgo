import 'package:flutter/foundation.dart';

@immutable
class NewsModel {
  const NewsModel({
    required this.id,
    required this.titleEn,
    this.titleFa,
    required this.bodyEn,
    this.bodyFa,
    required this.source,
    this.imageUrl,
    required this.url,
    this.tags = const [],
    required this.publishedAt,
    this.isFeatured = false,
  });

  final String id;
  final String titleEn;
  final String? titleFa;
  final String bodyEn;
  final String? bodyFa;
  final String source;
  final String? imageUrl;
  final String url;
  final List<String> tags;
  final DateTime publishedAt;
  final bool isFeatured;

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
