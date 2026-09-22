import 'package:flutter_test/flutter_test.dart';
import 'package:signalgo/core/error/result.dart';
import 'package:signalgo/features/news/models/news_model.dart';
import 'package:signalgo/features/news/repositories/news_repository.dart';
import 'package:signalgo/features/news/repositories/news_repository_mock.dart';

void main() {
  group('NewsRepositoryMock', () {
    test('fetchNews returns articles ordered newest first', () async {
      final repo = NewsRepositoryMock();
      final result = await repo.fetchNews();
      final items = (result as Ok<NewsPage>).value.items;

      expect(items, isNotEmpty);
      for (var i = 0; i < items.length - 1; i++) {
        expect(items[i].publishedAt.isAfter(items[i + 1].publishedAt), isTrue);
      }
    });

    test('fetchNews filters by tag', () async {
      final repo = NewsRepositoryMock();
      final result = await repo.fetchNews(tag: 'bitcoin');
      final items = (result as Ok<NewsPage>).value.items;

      expect(items, isNotEmpty);
      expect(items.every((n) => n.tags.contains('bitcoin')), isTrue);
    });

    test('fetchFeatured returns only featured articles', () async {
      final repo = NewsRepositoryMock();
      final result = await repo.fetchFeatured();
      final items = (result as Ok<List<NewsModel>>).value;

      expect(items, isNotEmpty);
      expect(items.every((n) => n.isFeatured == true), isTrue);
    });
  });
}
