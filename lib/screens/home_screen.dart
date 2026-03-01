import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';
import 'stock_list_screen.dart';
import 'news_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    StockListScreen(),
    NewsScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppTheme.primarySubtle,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.candlestick_chart_outlined,
                color: AppTheme.textTertiary),
            selectedIcon: Icon(Icons.candlestick_chart_rounded,
                color: AppTheme.primary),
            label: 'Markets',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined, color: AppTheme.textTertiary),
            selectedIcon: Icon(Icons.newspaper_rounded, color: AppTheme.primary),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded,
                color: AppTheme.textTertiary),
            selectedIcon:
                Icon(Icons.person_rounded, color: AppTheme.primary),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
