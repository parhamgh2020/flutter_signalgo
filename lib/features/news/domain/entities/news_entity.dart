import 'package:flutter/foundation.dart';

@immutable
class NewsEntity {
  const NewsEntity({
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
}
