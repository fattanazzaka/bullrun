import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/stock.dart';
import '../services/alpha_vantage_service.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/stock_card.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import 'stock_detail_screen.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen>
    with SingleTickerProviderStateMixin {
  final _service = AlphaVantageService();
  final _searchController = TextEditingController();
  late final TabController _tabController;

  List<Stock> _searchResults = [];
  List<Stock> _defaultStocks = [];
  Map<String, List<Stock>> _movers = {};
  bool _loadingDefault = false;
  bool _loadingSearch = false;
  bool _loadingMovers = false;
  bool _searching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDefaultStocks();
    _loadMovers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultStocks() async {
    if (_loadingDefault) return;
    setState(() {
      _loadingDefault = true;
      _error = null;
    });
    try {
      final stocks =
          await _service.getMultipleQuotes(AppConstants.defaultStocks);
      if (mounted) setState(() => _defaultStocks = stocks);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loadingDefault = false);
    }
  }

  Future<void> _loadMovers() async {
    setState(() => _loadingMovers = true);
    try {
      final data = await _service.getTopMovers();
      if (mounted) setState(() => _movers = data);
    } catch (_) {} finally {
      if (mounted) setState(() => _loadingMovers = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _searching = true;
      _loadingSearch = true;
    });

    try {
      final results = await _service.searchStocks(query);
      if (mounted) setState(() => _searchResults = results);
    } catch (_) {} finally {
      if (mounted) setState(() => _loadingSearch = false);
    }
  }

  void _openDetail(Stock stock) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StockDetailScreen(stock: stock)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            if (_searching)
              Expanded(child: _buildSearchResults())
            else ...[
              _buildTabBar(),
              Expanded(child: _buildTabContent()),
            ],
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
                'Bull Run',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                'Stocks & Markets Screener',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => _search(v),
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search stocks (e.g. AAPL, Tesla)...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searching = false;
                      _searchResults = [];
                    });
                  },
                  child: const Icon(Icons.close_rounded,
                      color: AppTheme.textTertiary, size: 18),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Watchlist'),
          Tab(text: 'Trending'),
          Tab(text: 'Popular'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildWatchlistTab(),
        _buildTrendingTab(),
        _buildPopularStocksTab(),
      ],
    );
  }

  Widget _buildWatchlistTab() {
    return Consumer<WatchlistProvider>(
      builder: (context, watchlist, _) {
        if (watchlist.symbols.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_outline_rounded,
                    color: AppTheme.textTertiary, size: 48),
                const SizedBox(height: 12),
                const Text('No stocks in watchlist',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 15)),
                const SizedBox(height: 6),
                Text(
                  'Tap ★ on any stock to add it',
                  style: TextStyle(
                      color: AppTheme.textTertiary, fontSize: 13),
                ),
              ],
            ),
          );
        }

        final watchedStocks = _defaultStocks
            .where((s) => watchlist.isWatched(s.symbol))
            .toList();

        if (watchedStocks.isEmpty) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: watchlist.symbols.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => StockCard(
              stock: Stock(
                  symbol: watchlist.symbols[i],
                  name: watchlist.symbols[i]),
              isWatched: true,
              onWatchlistToggle: () =>
                  context.read<WatchlistProvider>().toggle(watchlist.symbols[i]),
              onTap: () => _openDetail(
                  Stock(symbol: watchlist.symbols[i], name: watchlist.symbols[i])),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: watchedStocks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final stock = watchedStocks[i];
            return StockCard(
              stock: stock,
              isWatched: true,
              onWatchlistToggle: () =>
                  context.read<WatchlistProvider>().toggle(stock.symbol),
              onTap: () => _openDetail(stock),
            );
          },
        );
      },
    );
  }

  Widget _buildTrendingTab() {
    if (_loadingMovers) return _buildShimmerList();

    final gainers = _movers['gainers'] ?? [];
    final losers = _movers['losers'] ?? [];

    if (gainers.isEmpty && losers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.trending_up, color: AppTheme.textTertiary, size: 40),
            const SizedBox(height: 12),
            const Text('No trending data available',
                style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadMovers, child: const Text('Retry')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMoverSection('Top Gainers', gainers, true),
          const SizedBox(height: 20),
          _buildMoverSection('Top Losers', losers, false),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMoverSection(String title, List<Stock> stocks, bool? isGainer) {
    if (stocks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ),
        ...stocks.take(5).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Consumer<WatchlistProvider>(
                builder: (ctx, watchlist, _) => StockCard(
                  stock: s,
                  isWatched: watchlist.isWatched(s.symbol),
                  onWatchlistToggle: () =>
                      ctx.read<WatchlistProvider>().toggle(s.symbol),
                  onTap: () => _openDetail(s),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildPopularStocksTab() {
    if (_loadingDefault) return _buildShimmerList();

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.red, size: 40),
            const SizedBox(height: 12),
            Text('Failed to load stocks',
                style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadDefaultStocks, child: const Text('Retry')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDefaultStocks,
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _defaultStocks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final stock = _defaultStocks[i];
          return Consumer<WatchlistProvider>(
            builder: (ctx, watchlist, _) => StockCard(
              stock: stock,
              isWatched: watchlist.isWatched(stock.symbol),
              onWatchlistToggle: () =>
                  ctx.read<WatchlistProvider>().toggle(stock.symbol),
              onTap: () => _openDetail(stock),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_loadingSearch) return _buildShimmerList();

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: AppTheme.textTertiary, size: 40),
            SizedBox(height: 12),
            Text('No results found',
                style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final stock = _searchResults[i];
        return Consumer<WatchlistProvider>(
          builder: (ctx, watchlist, _) => StockCard(
            stock: stock,
            isWatched: watchlist.isWatched(stock.symbol),
            onWatchlistToggle: () =>
                ctx.read<WatchlistProvider>().toggle(stock.symbol),
            onTap: () => _openDetail(stock),
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface,
      highlightColor: AppTheme.surfaceHigh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => Container(
          height: 70,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
