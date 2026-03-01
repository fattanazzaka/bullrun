import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistProvider extends ChangeNotifier {
  static const String _key = 'watchlist_symbols';
  List<String> _symbols = [];

  List<String> get symbols => List.unmodifiable(_symbols);

  bool isWatched(String symbol) => _symbols.contains(symbol.toUpperCase());

  WatchlistProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _symbols = prefs.getStringList(_key) ?? [];
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _symbols);
  }

  Future<void> add(String symbol) async {
    final upper = symbol.toUpperCase();
    if (!_symbols.contains(upper)) {
      _symbols.add(upper);
      notifyListeners();
      await _save();
    }
  }

  Future<void> remove(String symbol) async {
    final upper = symbol.toUpperCase();
    _symbols.remove(upper);
    notifyListeners();
    await _save();
  }

  Future<void> toggle(String symbol) async {
    isWatched(symbol) ? await remove(symbol) : await add(symbol);
  }
}
