class Stock {
  final String symbol;
  final String name;
  final String type;
  final String region;
  final String currency;

  final double? price;
  final double? changeAmount;
  final double? changePercent;
  final String? volume;

  Stock({
    required this.symbol,
    required this.name,
    this.type = 'Equity',
    this.region = 'United States',
    this.currency = 'USD',
    this.price,
    this.changeAmount,
    this.changePercent,
    this.volume,
  });

  bool get isPositive => (changeAmount ?? 0) >= 0;

  factory Stock.fromSearchJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['1. symbol'] ?? '',
      name: json['2. name'] ?? '',
      type: json['3. type'] ?? 'Equity',
      region: json['4. region'] ?? '',
      currency: json['8. currency'] ?? 'USD',
    );
  }

  // From TOP_GAINERS_LOSERS
  factory Stock.fromTrendingJson(Map<String, dynamic> json) {
    final changeStr = (json['change_percentage'] as String? ?? '0%')
        .replaceAll('%', '');
    final price = double.tryParse(json['price'] ?? '0') ?? 0;
    final change = double.tryParse(json['change_amount'] ?? '0') ?? 0;
    final percent = double.tryParse(changeStr) ?? 0;

    return Stock(
      symbol: json['ticker'] ?? '',
      name: json['ticker'] ?? '',
      price: price,
      changeAmount: change,
      changePercent: percent,
      volume: json['volume'],
    );
  }

  // From GLOBAL_QUOTE
  factory Stock.fromQuoteJson(String symbol, Map<String, dynamic> json) {
    final quote = json['Global Quote'] as Map<String, dynamic>? ?? {};
    final price = double.tryParse(quote['05. price'] ?? '0') ?? 0;
    final change = double.tryParse(quote['09. change'] ?? '0') ?? 0;
    final changeStr = (quote['10. change percent'] as String? ?? '0%')
        .replaceAll('%', '');
    final percent = double.tryParse(changeStr) ?? 0;

    return Stock(
      symbol: symbol,
      name: symbol,
      price: price,
      changeAmount: change,
      changePercent: percent,
      volume: quote['06. volume'],
    );
  }

  Stock copyWith({
    String? symbol,
    String? name,
    double? price,
    double? changeAmount,
    double? changePercent,
    String? volume,
  }) {
    return Stock(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      type: this.type,
      region: this.region,
      currency: this.currency,
      price: price ?? this.price,
      changeAmount: changeAmount ?? this.changeAmount,
      changePercent: changePercent ?? this.changePercent,
      volume: volume ?? this.volume,
    );
  }
}
