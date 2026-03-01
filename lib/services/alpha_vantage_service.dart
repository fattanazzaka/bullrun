import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock.dart';
import '../models/company_detail.dart';
import '../models/news_item.dart';
import '../utils/constants.dart';


class ChartPoint {
  final String time;
  final double price;
  const ChartPoint({required this.time, required this.price});
}


enum ChartTimeframe { oneDay, oneWeek, oneMonth, oneYear, all }

extension ChartTimeframeLabel on ChartTimeframe {
  String get label {
    switch (this) {
      case ChartTimeframe.oneDay:   return '1D';
      case ChartTimeframe.oneWeek:  return '1W';
      case ChartTimeframe.oneMonth: return '1M';
      case ChartTimeframe.oneYear:  return '1Y';
      case ChartTimeframe.all:      return 'All';
    }
  }
}

class AlphaVantageService {
  static const String _cachePrefix = 'av_cache_';

  Future<Map<String, dynamic>> _get(
    Map<String, String> params, {
    int cacheMins = 15,
  }) async {
    final uri = Uri.parse(AppConstants.baseUrl).replace(queryParameters: {
      ...params,
      'apikey': AppConstants.apiKey,
    });

    final cacheKey = '$_cachePrefix${uri.toString()}';
    final prefs = await SharedPreferences.getInstance();

    final cachedData = prefs.getString(cacheKey);
    final cachedTime = prefs.getInt('${cacheKey}_time') ?? 0;
    final ageMin =
        (DateTime.now().millisecondsSinceEpoch - cachedTime) / 60000;

    if (cachedData != null && ageMin < cacheMins) {
      return json.decode(cachedData) as Map<String, dynamic>;
    }

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;

    if (!data.containsKey('Information') && !data.containsKey('Note')) {
      await prefs.setString(cacheKey, response.body);
      await prefs.setInt(
          '${cacheKey}_time', DateTime.now().millisecondsSinceEpoch);
    }

    return data;
  }

  Future<List<Stock>> searchStocks(String query) async {
    if (query.trim().isEmpty) return [];
    final data = await _get({'function': 'SYMBOL_SEARCH', 'keywords': query});
    final matches = data['bestMatches'] as List<dynamic>? ?? [];
    return matches
        .map((m) => Stock.fromSearchJson(m as Map<String, dynamic>))
        .take(10)
        .toList();
  }

  Future<Stock> getQuote(String symbol) async {
    final data =
        await _get({'function': 'GLOBAL_QUOTE', 'symbol': symbol});
    return Stock.fromQuoteJson(symbol, data);
  }

  Future<List<Stock>> getMultipleQuotes(List<String> symbols) async {
    final results = <Stock>[];
    for (final symbol in symbols) {
      try {
        results.add(await getQuote(symbol));
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (_) {
        results.add(Stock(symbol: symbol, name: symbol));
      }
    }
    return results;
  }

  Future<Map<String, List<Stock>>> getTopMovers() async {
    final data = await _get({'function': 'TOP_GAINERS_LOSERS'});

    List<Stock> parse(dynamic list) => (list as List<dynamic>? ?? [])
        .map((e) => Stock.fromTrendingJson(e as Map<String, dynamic>))
        .toList();

    return {
      'gainers': parse(data['top_gainers']),
      'losers':  parse(data['top_losers']),
      'active':  parse(data['most_actively_traded']),
    };
  }

  Future<CompanyDetail> getCompanyOverview(String symbol) async {
    final data =
        await _get({'function': 'OVERVIEW', 'symbol': symbol}, cacheMins: 60);
    if (data.isEmpty || data.containsKey('Information')) {
      throw Exception('Company data unavailable for $symbol');
    }
    return CompanyDetail.fromJson(data);
  }

  Future<List<ChartPoint>> getChartData(
      String symbol, ChartTimeframe tf) async {
    switch (tf) {
      case ChartTimeframe.oneDay:   return _fetchIntraday(symbol);
      case ChartTimeframe.oneWeek:  return _fetchDaily(symbol, limit: 7);
      case ChartTimeframe.oneMonth: return _fetchDaily(symbol, limit: 30);
      case ChartTimeframe.oneYear:  return _fetchWeekly(symbol, limit: 52);
      case ChartTimeframe.all:      return _fetchMonthly(symbol);
    }
  }
  Future<List<ChartPoint>> _fetchIntraday(String symbol) async {
    final data = await _get({
      'function':   'TIME_SERIES_INTRADAY',
      'symbol':     symbol,
      'interval':   '15min',
      'outputsize': 'compact', 
    }, cacheMins: 5); 

    final series =
        data['Time Series (15min)'] as Map<String, dynamic>?;
    if (series == null) return [];

    return _parseAndSort(series);
  }

  Future<List<ChartPoint>> _fetchDaily(
      String symbol, {required int limit}) async {
    final data = await _get({
      'function':   'TIME_SERIES_DAILY',
      'symbol':     symbol,
      'outputsize': 'compact', 
    }, cacheMins: 30);

    final series =
        data['Time Series (Daily)'] as Map<String, dynamic>?;
    if (series == null) return [];

    final all = _parseAndSort(series);
    return all.length > limit ? all.sublist(all.length - limit) : all;
  }

  Future<List<ChartPoint>> _fetchWeekly(
      String symbol, {required int limit}) async {
    final data = await _get({
      'function': 'TIME_SERIES_WEEKLY',
      'symbol':   symbol,
    }, cacheMins: 60);

    final series =
        data['Weekly Time Series'] as Map<String, dynamic>?;
    if (series == null) return [];

    final all = _parseAndSort(series);
    return all.length > limit ? all.sublist(all.length - limit) : all;
  }

  Future<List<ChartPoint>> _fetchMonthly(String symbol) async {
    final data = await _get({
      'function': 'TIME_SERIES_MONTHLY',
      'symbol':   symbol,
    }, cacheMins: 120);

    final series =
        data['Monthly Time Series'] as Map<String, dynamic>?;
    if (series == null) return [];

    return _parseAndSort(series);
  }

  List<ChartPoint> _parseAndSort(Map<String, dynamic> series) {
    final points = series.entries.map((e) {
      final close =
          double.tryParse((e.value as Map)['4. close'] ?? '0') ?? 0;
      return ChartPoint(time: e.key, price: close);
    }).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return points;
  }

  Future<List<NewsItem>> getNewsSentiment({
    String? tickers,
    String? topics,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'function': 'NEWS_SENTIMENT',
      'limit': limit.toString(),
    };
    if (tickers != null) params['tickers'] = tickers;
    if (topics != null)  params['topics']  = topics;

    final data = await _get(params, cacheMins: 20);
    final feed = data['feed'] as List<dynamic>? ?? [];
    return feed
        .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
