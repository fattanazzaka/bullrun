class NewsItem {
  final String title;
  final String url;
  final String timePublished;
  final List<String> authors;
  final String summary;
  final String? bannerImage;
  final String source;
  final double sentimentScore;
  final String sentimentLabel;
  final List<String> topics;

  NewsItem({
    required this.title,
    required this.url,
    required this.timePublished,
    required this.authors,
    required this.summary,
    this.bannerImage,
    required this.source,
    this.sentimentScore = 0,
    this.sentimentLabel = 'Neutral',
    this.topics = const [],
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    final authors = (json['authors'] as List<dynamic>? ?? [])
        .map((a) => a.toString())
        .toList();

    final topics = (json['topics'] as List<dynamic>? ?? [])
        .map((t) => (t as Map<String, dynamic>)['topic']?.toString() ?? '')
        .where((t) => t.isNotEmpty)
        .toList();

    return NewsItem(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      timePublished: _formatDate(json['time_published'] ?? ''),
      authors: authors,
      summary: json['summary'] ?? '',
      bannerImage: json['banner_image'],
      source: json['source'] ?? '',
      sentimentScore:
          double.tryParse(json['overall_sentiment_score']?.toString() ?? '0') ??
              0,
      sentimentLabel: json['overall_sentiment_label'] ?? 'Neutral',
      topics: topics,
    );
  }

  static String _formatDate(String raw) {
    if (raw.length < 8) return raw;
    try {
      final year = raw.substring(0, 4);
      final month = raw.substring(4, 6);
      final day = raw.substring(6, 8);
      final hour = raw.length >= 11 ? raw.substring(9, 11) : '00';
      final min = raw.length >= 13 ? raw.substring(11, 13) : '00';
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final monthNum = int.tryParse(month) ?? 1;
      return '${months[monthNum]} $day, $year  $hour:$min';
    } catch (_) {
      return raw;
    }
  }

  bool get isBullish =>
      sentimentLabel.toLowerCase().contains('bullish') ||
      sentimentLabel.toLowerCase().contains('positive');

  bool get isBearish =>
      sentimentLabel.toLowerCase().contains('bearish') ||
      sentimentLabel.toLowerCase().contains('negative');
}
