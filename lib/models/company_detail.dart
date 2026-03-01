class CompanyDetail {
  final String symbol;
  final String name;
  final String description;
  final String exchange;
  final String currency;
  final String country;
  final String sector;
  final String industry;
  final String marketCap;
  final String week52High;
  final String week52Low;
  final String peRatio;
  final String eps;
  final String dividendYield;
  final String beta;
  final String movingAverage50;
  final String movingAverage200;
  final String sharesOutstanding;
  final String analystTargetPrice;

  CompanyDetail({
    required this.symbol,
    required this.name,
    this.description = '',
    this.exchange = '',
    this.currency = 'USD',
    this.country = '',
    this.sector = '',
    this.industry = '',
    this.marketCap = 'N/A',
    this.week52High = 'N/A',
    this.week52Low = 'N/A',
    this.peRatio = 'N/A',
    this.eps = 'N/A',
    this.dividendYield = 'N/A',
    this.beta = 'N/A',
    this.movingAverage50 = 'N/A',
    this.movingAverage200 = 'N/A',
    this.sharesOutstanding = 'N/A',
    this.analystTargetPrice = 'N/A',
  });

  factory CompanyDetail.fromJson(Map<String, dynamic> json) {
    return CompanyDetail(
      symbol: json['Symbol'] ?? '',
      name: json['Name'] ?? '',
      description: json['Description'] ?? '',
      exchange: json['Exchange'] ?? '',
      currency: json['Currency'] ?? 'USD',
      country: json['Country'] ?? '',
      sector: json['Sector'] ?? '',
      industry: json['Industry'] ?? '',
      marketCap: _formatMarketCap(json['MarketCapitalization']),
      week52High: _formatPrice(json['52WeekHigh']),
      week52Low: _formatPrice(json['52WeekLow']),
      peRatio: _formatNum(json['PERatio']),
      eps: _formatNum(json['EPS']),
      dividendYield: _formatPercent(json['DividendYield']),
      beta: _formatNum(json['Beta']),
      movingAverage50: _formatPrice(json['50DayMovingAverage']),
      movingAverage200: _formatPrice(json['200DayMovingAverage']),
      sharesOutstanding: _formatShares(json['SharesOutstanding']),
      analystTargetPrice: _formatPrice(json['AnalystTargetPrice']),
    );
  }

  static String _formatMarketCap(dynamic val) {
    if (val == null || val == 'None') return 'N/A';
    final num = double.tryParse(val.toString()) ?? 0;
    if (num >= 1e12) return '\$${(num / 1e12).toStringAsFixed(2)}T';
    if (num >= 1e9) return '\$${(num / 1e9).toStringAsFixed(2)}B';
    if (num >= 1e6) return '\$${(num / 1e6).toStringAsFixed(2)}M';
    return '\$$num';
  }

  static String _formatPrice(dynamic val) {
    if (val == null || val == 'None' || val == '-') return 'N/A';
    final num = double.tryParse(val.toString());
    if (num == null) return 'N/A';
    return '\$${num.toStringAsFixed(2)}';
  }

  static String _formatNum(dynamic val) {
    if (val == null || val == 'None' || val == '-') return 'N/A';
    final num = double.tryParse(val.toString());
    if (num == null) return 'N/A';
    return num.toStringAsFixed(2);
  }

  static String _formatPercent(dynamic val) {
    if (val == null || val == 'None' || val == '-') return 'N/A';
    final num = double.tryParse(val.toString());
    if (num == null) return 'N/A';
    return '${(num * 100).toStringAsFixed(2)}%';
  }

  static String _formatShares(dynamic val) {
    if (val == null || val == 'None') return 'N/A';
    final num = double.tryParse(val.toString()) ?? 0;
    if (num >= 1e9) return '${(num / 1e9).toStringAsFixed(2)}B';
    if (num >= 1e6) return '${(num / 1e6).toStringAsFixed(2)}M';
    return num.toStringAsFixed(0);
  }
}
