import 'package:appwrite/appwrite.dart';

import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/cache/offline_cache.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../models/news_model.dart';
import 'news_repository.dart';

const _cacheKey = 'news.page1';

class NewsRepositoryAppwrite implements NewsRepository {
  NewsRepositoryAppwrite({
    required Databases databases,
    required AppwriteConfig config,
    required OfflineCache cache,
  })  : _databases = databases,
        _config = config,
        _cache = cache;

  final Databases _databases;
  final AppwriteConfig _config;
  final OfflineCache _cache;

  @override
  Future<Result<NewsPage>> fetchNews({
    int limit = 20,
    String? cursor,
    String? tag,
    String? search,
  }) async {
    try {
      final queries = <String>[
        Query.limit(limit),
        Query.orderDesc('published_at'),
      ];
      if (cursor != null) queries.add(Query.cursorAfter(cursor));
      if (tag != null && tag.isNotEmpty) queries.add(Query.equal('tags', tag));
      if (search != null && search.trim().isNotEmpty) {
        queries.add(Query.search('title_en', search.trim()));
      }

      final res = await _databases.listDocuments(
        databaseId: _config.databaseId,
        collectionId: AppwriteCollections.news,
        queries: queries,
      );
      final items = res.documents.map((d) => NewsModel.fromMap(d.data..[r'$id'] = d.$id)).toList();

      if (cursor == null) {
        await _cache.writeList(_cacheKey, items.map((e) => e.toCacheMap()).toList());
      }

      return Ok(NewsPage(items: items, nextCursor: items.length == limit ? items.last.id : null));
    } on AppwriteException catch (e) {
      if (cursor == null) {
        final cached = _cache.readList(_cacheKey);
        if (cached != null) {
          return Ok(NewsPage(items: cached.map(NewsModel.fromMap).toList(), nextCursor: null));
        }
      }
      return Err(Failure.fromAppwriteException(e));
    } catch (e) {
      return Err(UnknownFailure(e));
    }
  }

  @override
  Future<Result<List<NewsModel>>> fetchFeatured() async {
    try {
      final res = await _databases.listDocuments(
        databaseId: _config.databaseId,
        collectionId: AppwriteCollections.news,
        queries: [
          Query.equal('is_featured', true),
          Query.orderDesc('published_at'),
          Query.limit(10),
        ],
      );
      return Ok(res.documents.map((d) => NewsModel.fromMap(d.data..[r'$id'] = d.$id)).toList());
    } on AppwriteException catch (e) {
      return Err(Failure.fromAppwriteException(e));
    } catch (e) {
      return Err(UnknownFailure(e));
    }
  }
}
