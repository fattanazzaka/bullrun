import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock.dart';
import '../models/company_detail.dart';
import '../models/news_item.dart';
import '../services/alpha_vantage_service.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/price_chart.dart';
import '../widgets/news_card.dart';
import '../utils/theme.dart';

class StockDetailScreen extends StatefulWidget {
  final Stock stock;
  const StockDetailScreen({super.key, required this.stock});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final _service = AlphaVantageService();

  CompanyDetail?      _detail;
  List<ChartPoint>    _chartPoints = [];
  List<NewsItem>      _news = [];

  bool _loadingDetail = false;
  bool _loadingChart  = false;
  bool _loadingNews   = false;
  String? _chartError;

  ChartTimeframe _timeframe = ChartTimeframe.oneMonth; 

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _loadChart();
    _loadNews();
  }


  Future<void> _loadDetail() async {
    setState(() => _loadingDetail = true);
    try {
      final d = await _service.getCompanyOverview(widget.stock.symbol);
      if (mounted) setState(() => _detail = d);
    } catch (_) {} finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  Future<void> _loadChart() async {
    setState(() {
      _loadingChart = true;
      _chartError   = null;
    });
    try {
      final pts = await _service.getChartData(widget.stock.symbol, _timeframe);
      if (mounted) {
        setState(() {
          _chartPoints = pts;
          if (pts.isEmpty) _chartError = _chartEmptyMessage();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _chartError = 'Gagal memuat data chart');
    } finally {
      if (mounted) setState(() => _loadingChart = false);
    }
  }

  Future<void> _loadNews() async {
    setState(() => _loadingNews = true);
    try {
      final items = await _service.getNewsSentiment(
          tickers: widget.stock.symbol, limit: 5);
      if (mounted) setState(() => _news = items);
    } catch (_) {} finally {
      if (mounted) setState(() => _loadingNews = false);
    }
  }

  void _switchTimeframe(ChartTimeframe tf) {
    if (_timeframe == tf) return;
    setState(() {
      _timeframe   = tf;
      _chartPoints = [];
    });
    _loadChart();
  }

  String _chartEmptyMessage() {
    if (_timeframe == ChartTimeframe.oneDay) {
      return 'Data intraday tidak tersedia\n(Butuh AlphaVantage premium)';
    }
    return 'Data chart tidak tersedia';
  }

  bool get _isPositive => widget.stock.isPositive;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildPriceHeader()),
          SliverToBoxAdapter(child: _buildChartSection()),
          SliverToBoxAdapter(child: _buildAboutSection()),
          SliverToBoxAdapter(child: _buildStatsSection()),
          SliverToBoxAdapter(child: _buildNewsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }


  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppTheme.background,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.stock.symbol,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          if (_detail != null)
            Text(_detail!.exchange,
                style: const TextStyle(
                    color: AppTheme.textTertiary, fontSize: 11)),
        ],
      ),
      actions: [
        Consumer<WatchlistProvider>(
          builder: (ctx, wl, _) => IconButton(
            icon: Icon(
              wl.isWatched(widget.stock.symbol)
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: wl.isWatched(widget.stock.symbol)
                  ? AppTheme.gold
                  : AppTheme.textTertiary,
              size: 24,
            ),
            onPressed: () =>
                ctx.read<WatchlistProvider>().toggle(widget.stock.symbol),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.border),
      ),
    );
  }


  Widget _buildPriceHeader() {
    final color = _isPositive ? AppTheme.green : AppTheme.red;
    final bgColor = _isPositive ? AppTheme.greenBg : AppTheme.redBg;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _detail?.name ?? widget.stock.name,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.stock.price != null
                    ? '\$${widget.stock.price!.toStringAsFixed(2)}'
                    : '—',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              if (widget.stock.changePercent != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isPositive
                              ? Icons.arrow_drop_up_rounded
                              : Icons.arrow_drop_down_rounded,
                          color: color,
                          size: 16,
                        ),
                        Text(
                          '${widget.stock.changePercent!.abs().toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (_detail != null)
            Wrap(
              spacing: 6,
              children: [
                if (_detail!.sector.isNotEmpty) _tag(_detail!.sector),
                if (_detail!.country.isNotEmpty) _tag(_detail!.country),
                if (_detail!.currency.isNotEmpty) _tag(_detail!.currency),
              ],
            ),
        ],
      ),
    );
  }

  Widget _tag(String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 11)),
      );

  Widget _buildChartSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildTimeframeSelector(),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _loadingChart
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary, strokeWidth: 2))
                : _chartError != null || _chartPoints.isEmpty
                    ? _buildChartEmpty()
                    : PriceChart(
                        points: _chartPoints,
                        isPositive: _isPositive),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ChartTimeframe.values.map((tf) {
          final selected = _timeframe == tf;
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchTimeframe(tf),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  tf.label,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : AppTheme.textTertiary,
                    fontSize: 13,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart_outlined,
              color: AppTheme.textTertiary, size: 36),
          const SizedBox(height: 8),
          Text(
            _chartError ?? 'Data tidak tersedia',
            style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 12,
                height: 1.5),
            textAlign: TextAlign.center,
          ),
          if (_timeframe == ChartTimeframe.oneDay) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _switchTimeframe(ChartTimeframe.oneMonth),
              child: const Text('Lihat 1 Bulan →',
                  style: TextStyle(
                      color: AppTheme.primaryLight, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    if (_loadingDetail) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
            child: CircularProgressIndicator(
                color: AppTheme.primary, strokeWidth: 2)),
      );
    }
    if (_detail == null) return const SizedBox.shrink();

    return _card(
      title: 'Tentang Perusahaan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _detail!.description.isEmpty
                ? 'Deskripsi tidak tersedia.'
                : _detail!.description,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.65,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          if (_detail!.industry.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppTheme.border, height: 1),
            const SizedBox(height: 12),
            _infoRow('Industri', _detail!.industry),
            _infoRow('Negara', _detail!.country),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_detail == null) return const SizedBox.shrink();

    final stats = [
      ('Market Cap',   _detail!.marketCap),
      ('P/E Ratio',    _detail!.peRatio),
      ('EPS',          _detail!.eps),
      ('Beta',         _detail!.beta),
      ('52W High',     _detail!.week52High),
      ('52W Low',      _detail!.week52Low),
      ('Div. Yield',   _detail!.dividendYield),
      ('Shares Out.',  _detail!.sharesOutstanding),
      ('50D MA',       _detail!.movingAverage50),
      ('200D MA',      _detail!.movingAverage200),
    ];

    return _card(
      title: 'Statistik Utama',
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 3.0,
        children: stats.map((s) => _statCell(s.$1, s.$2)).toList(),
      ),
    );
  }

  Widget _statCell(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textTertiary, fontSize: 11)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text('Berita Terkait',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
        if (_loadingNews)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
                child: CircularProgressIndicator(
                    color: AppTheme.primary, strokeWidth: 2)),
          )
        else if (_news.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Tidak ada berita tersedia',
                style: TextStyle(color: AppTheme.textSecondary)),
          )
        else
          ...(_news.map((n) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: NewsCard(news: n),
              ))),
      ],
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          children: [
            Text('$label  ',
                style: const TextStyle(
                    color: AppTheme.textTertiary, fontSize: 12)),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                  textAlign: TextAlign.end),
            ),
          ],
        ),
      );
}
