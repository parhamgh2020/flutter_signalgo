import 'package:flutter/material.dart';

import '../../../../core/localization/jalali_date.dart';
import '../../../../core/localization/localized_field.dart';
import '../../domain/entities/news_entity.dart';

class NewsListItem extends StatelessWidget {
  const NewsListItem({super.key, required this.article, required this.onTap});

  final NewsEntity article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFarsi = context.isRtl;
    final title = context.localizedField(en: article.titleEn, fa: article.titleFa);
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.article_outlined),
      ),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${article.source} · ${formatLocalizedDate(article.publishedAt, isFarsi: isFarsi)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
