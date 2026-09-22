import '../../../core/error/result.dart';
import '../models/news_model.dart';

class NewsPage {
  const NewsPage({required this.items, required this.nextCursor});

  final List<NewsModel> items;
  final String? nextCursor;
}

abstract class NewsRepository {
  Future<Result<NewsPage>> fetchNews({
    int limit = 20,
    String? cursor,
    String? tag,
    String? search,
  });

  Future<Result<List<NewsModel>>> fetchFeatured();
}
