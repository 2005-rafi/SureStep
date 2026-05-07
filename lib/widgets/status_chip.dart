import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final bool isOnline;
  const StatusChip({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(isOnline),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOnline ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOnline ? Icons.gps_fixed : Icons.gps_off,
              size: 14,
              color: isOnline ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              isOnline ? 'Live' : 'Last Known',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isOnline
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
