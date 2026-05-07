import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/map_style_provider.dart';
import '../providers/route_overlay_provider.dart';
import 'status_chip.dart';

class FloatingAppBar extends ConsumerWidget {
  const FloatingAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final locationAsync = ref.watch(locationProvider);
    final isDark = ref.watch(themeProvider.notifier).isDark;
    final activeStyle = ref.watch(mapStyleProvider);

    final isOnline = locationAsync.valueOrNull?.isOnline ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Route search trigger
            _BarIconButton(
              icon: Icons.search,
              tooltip: 'Search route',
              onPressed: () => ref
                  .read(routeOverlayVisibleProvider.notifier)
                  .state = true,
            ),

            _divider(cs),

            // Map style switcher
            _StyleSwitcherButton(
              activeStyle: activeStyle,
              onSelected: (style) =>
                  ref.read(mapStyleProvider.notifier).switchStyle(style),
            ),

            _divider(cs),

            // Theme toggle
            _BarIconButton(
              icon: isDark ? Icons.light_mode : Icons.dark_mode,
              tooltip: isDark ? 'Light mode' : 'Dark mode',
              onPressed: () => ref.read(themeProvider.notifier).toggle(),
              animKey: ValueKey(isDark),
            ),

            _divider(cs),

            // GPS status chip (informational only)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: StatusChip(isOnline: isOnline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(ColorScheme cs) => Container(
        width: 1,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        color: cs.outlineVariant.withValues(alpha: 0.5),
      );
}

class _BarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Key? animKey;

  const _BarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.animKey,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: Icon(icon, key: animKey, color: cs.onSurface, size: 22),
      ),
      padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }
}

class _StyleSwitcherButton extends StatelessWidget {
  final MapStyle activeStyle;
  final ValueChanged<MapStyle> onSelected;

  const _StyleSwitcherButton({
    required this.activeStyle,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return PopupMenuButton<MapStyle>(
      tooltip: 'Map style',
      icon: Icon(Icons.layers_outlined, color: cs.onSurface, size: 22),
      padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: onSelected,
      itemBuilder: (_) => MapStyle.values.map((style) {
        final isActive = style == activeStyle;
        return PopupMenuItem<MapStyle>(
          value: style,
          child: Row(
            children: [
              Icon(
                isActive ? Icons.check_circle : Icons.circle_outlined,
                size: 18,
                color: isActive ? cs.primary : cs.outlineVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      style.label,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    Text(
                      style.description,
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
