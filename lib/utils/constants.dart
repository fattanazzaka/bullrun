// lib/utils/constants.dart

class AppConstants {
  static const String apiKey = 'X3FDBXCMMJZ8K0SD';

  static const String baseUrl = 'https://www.alphavantage.co/query';

  static const List<String> defaultStocks = [
    'AAPL', 'GOOGL', 'MSFT', 'AMZN', 'TSLA',
    'META', 'NVDA', 'NFLX', 'AMD', 'BABA',
  ];

  static const int cacheDurationMinutes = 15;
}
