import '../../../../core/error/result.dart';
import '../entities/news_entity.dart';

class NewsPage {
  const NewsPage({required this.items, required this.nextCursor});

  final List<NewsEntity> items;
  final String? nextCursor;
}

abstract class NewsRepository {
  Future<Result<NewsPage>> fetchNews({
    int limit = 20,
    String? cursor,
    String? tag,
    String? search,
  });

  Future<Result<List<NewsEntity>>> fetchFeatured();
}
