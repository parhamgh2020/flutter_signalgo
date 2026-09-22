import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/jalali_date.dart';
import '../../../core/localization/localized_field.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/news_model.dart';

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({super.key, required this.article});

  final NewsModel article;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFarsi = context.isRtl;
    final title = context.localizedField(en: article.titleEn, fa: article.titleFa);
    final body = context.localizedField(en: article.bodyEn, fa: article.bodyFa);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: l10n.share,
            onPressed: () => Share.share('$title\n${article.url}'),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: l10n.openOriginal,
            onPressed: () => launchUrl(Uri.parse(article.url), mode: LaunchMode.externalApplication),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '${article.source} · ${formatLocalizedDate(article.publishedAt, isFarsi: isFarsi)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [for (final tag in article.tags) Chip(label: Text(tag), visualDensity: VisualDensity.compact)],
            ),
            const SizedBox(height: 16),
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
