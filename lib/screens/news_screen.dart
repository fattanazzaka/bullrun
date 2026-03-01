import 'package:flutter/material.dart';
import '../models/news_item.dart';
import '../services/alpha_vantage_service.dart';
import '../widgets/news_card.dart';
import '../utils/theme.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _service = AlphaVantageService();
  List<NewsItem> _news = [];
  bool _loading = false;
  String? _error;
  String _selectedTopic = 'All';

  final List<Map<String, String>> _filters = [
    {'label': 'All', 'topic': ''},
    {'label': 'Technology', 'topic': 'technology'},
    {'label': 'Finance', 'topic': 'finance'},
    {'label': 'Earnings', 'topic': 'earnings'},
    {'label': 'IPO', 'topic': 'ipo'},
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews({String? topic}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.getNewsSentiment(
        topics: (topic?.isEmpty ?? true) ? null : topic,
        limit: 30,
      );
      if (mounted) setState(() => _news = items);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSentimentSummary(),
            _buildFilterChips(),
            Expanded(child: _buildNewsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bull News',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                'Sentiment & Financial News',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _loadNews(
                topic: _filters.firstWhere(
                    (f) => f['label'] == _selectedTopic)['topic']),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.refresh_rounded,
                  color: AppTheme.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentSummary() {
    if (_news.isEmpty) return const SizedBox.shrink();

    final bullish = _news.where((n) => n.isBullish).length;
    final bearish = _news.where((n) => n.isBearish).length;
    final neutral = _news.length - bullish - bearish;
    final total = _news.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _sentimentBadge(
              'Bullish', bullish, total, AppTheme.green, Icons.trending_up),
          const SizedBox(width: 8),
          _sentimentBadge(
              'Neutral', neutral, total, AppTheme.textSecondary, Icons.trending_flat),
          const SizedBox(width: 8),
          _sentimentBadge(
              'Bearish', bearish, total, AppTheme.red, Icons.trending_down),
        ],
      ),
    );
  }

  Widget _sentimentBadge(
      String label, int count, int total, Color color, IconData icon) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              '$pct%',
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(label,
                style: TextStyle(color: color.withOpacity(0.7), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: _filters.map((f) {
          final selected = _selectedTopic == f['label'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTopic = f['label']!);
                _loadNews(topic: f['topic']);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.border,
                  ),
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    color: selected ? Colors.white : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNewsList() {
    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.red, size: 40),
            const SizedBox(height: 12),
            const Text('Failed to load news',
                style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadNews, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_news.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.newspaper, color: AppTheme.textTertiary, size: 40),
            SizedBox(height: 12),
            Text('No news available',
                style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNews,
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _news.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => NewsCard(news: _news[i]),
      ),
    );
  }
}
