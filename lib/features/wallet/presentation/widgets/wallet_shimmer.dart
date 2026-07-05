import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// Skeleton we show on first load. Feels faster than a bare spinner and hints
// at the layout that's coming.
class WalletShimmer extends StatelessWidget {
  const WalletShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _box(height: 170, radius: 16),
          const SizedBox(height: 24),
          _box(height: 40, width: 220, radius: 12),
          const SizedBox(height: 16),
          for (var i = 0; i < 6; i++) ...[
            Row(
              children: [
                _box(height: 48, width: 48, radius: 24),
                const SizedBox(width: 12),
                Expanded(child: _box(height: 44, radius: 8)),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _box({double? height, double? width, double radius = 8}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
