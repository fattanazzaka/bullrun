// lib/widgets/news_card.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_item.dart';
import '../utils/theme.dart';

class NewsCard extends StatelessWidget {
  final NewsItem news;

  const NewsCard({super.key, required this.news});

  Color get _sentimentColor {
    if (news.isBullish) return AppTheme.green;
    if (news.isBearish) return AppTheme.red;
    return AppTheme.textSecondary;
  }

  IconData get _sentimentIcon {
    if (news.isBullish) return Icons.trending_up;
    if (news.isBearish) return Icons.trending_down;
    return Icons.trending_flat;
  }

  Future<void> _openUrl() async {
    final uri = Uri.tryParse(news.url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openUrl,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image
            if (news.bannerImage != null && news.bannerImage!.isNotEmpty)
              ClipRRect(
                child: Image.network(
                  news.bannerImage!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 60,
                    color: AppTheme.surfaceVariant,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: AppTheme.textTertiary),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source & time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          news.source,
                          style: const TextStyle(
                            color: AppTheme.primaryLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(_sentimentIcon, color: _sentimentColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        news.sentimentLabel,
                        style: TextStyle(
                          color: _sentimentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    news.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Summary
                  Text(
                    news.summary,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Topics & time
                  Row(
                    children: [
                      if (news.topics.isNotEmpty)
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            children: news.topics
                                .take(3)
                                .map((t) => Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: AppTheme.border, width: 0.5),
                                      ),
                                      child: Text(
                                        t,
                                        style: const TextStyle(
                                          color: AppTheme.textTertiary,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      Text(
                        news.timePublished,
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
