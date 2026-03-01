// lib/widgets/stock_card.dart
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../utils/theme.dart';

class StockCard extends StatelessWidget {
  final Stock stock;
  final VoidCallback? onTap;
  final bool isWatched;
  final VoidCallback? onWatchlistToggle;

  const StockCard({
    super.key,
    required this.stock,
    this.onTap,
    this.isWatched = false,
    this.onWatchlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.isPositive;
    final priceColor = isPositive ? AppTheme.green : AppTheme.red;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Symbol avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                stock.symbol.length > 4
                    ? stock.symbol.substring(0, 4)
                    : stock.symbol,
                style: const TextStyle(
                  color: AppTheme.primaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name & info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stock.name.isNotEmpty ? stock.name : stock.symbol,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Price info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (stock.price != null)
                  Text(
                    '\$${stock.price!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  const Text(
                    '—',
                    style: TextStyle(color: AppTheme.textTertiary, fontSize: 15),
                  ),
                const SizedBox(height: 4),
                if (stock.changePercent != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: priceColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: priceColor,
                          size: 14,
                        ),
                        Text(
                          '${stock.changePercent!.abs().toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: priceColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Watchlist button
            if (onWatchlistToggle != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onWatchlistToggle,
                child: Icon(
                  isWatched ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isWatched ? AppTheme.gold : AppTheme.textTertiary,
                  size: 22,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
