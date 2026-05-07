import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/route_state.dart';
import '../providers/route_provider.dart';
import '../providers/route_overlay_provider.dart';
import '../providers/location_provider.dart';

class RouteSearchOverlay extends ConsumerStatefulWidget {
  const RouteSearchOverlay({super.key});

  @override
  ConsumerState<RouteSearchOverlay> createState() =>
      _RouteSearchOverlayState();
}

class _RouteSearchOverlayState extends ConsumerState<RouteSearchOverlay>
    with SingleTickerProviderStateMixin {
  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  late final AnimationController _animCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    // Pre-fill origin with "My Location" if GPS is live
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = ref.read(locationProvider).valueOrNull;
      if (loc?.isOnline == true) {
        _originCtrl.text = 'My Location';
      }
      _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _animCtrl.reverse();
    if (mounted) {
      ref.read(routeOverlayVisibleProvider.notifier).state = false;
    }
  }

  Future<void> _submit() async {
    final origin = _originCtrl.text.trim();
    final dest = _destCtrl.text.trim();
    if (origin.isEmpty || dest.isEmpty) return;
    FocusScope.of(context).unfocus();

    // If origin is "My Location", use current GPS coords
    final loc = ref.read(locationProvider).valueOrNull;
    if (origin == 'My Location' && loc?.latLng != null) {
      final ll = loc!.latLng!;
      await ref
          .read(routeProvider.notifier)
          .setOriginLatLng(ll, 'My Location');
    } else {
      await ref.read(routeProvider.notifier).setOrigin(origin);
    }
    await ref.read(routeProvider.notifier).setDestination(dest);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final route = ref.watch(routeProvider);
    final isLoading = route.status == RouteStatus.loading;

    // Auto-close on success
    ref.listen(routeProvider, (prev, next) {
      if (next.status == RouteStatus.success) _dismiss();
    });

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle + close
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(
                  children: [
                    Icon(Icons.directions, color: cs.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Plan Route',
                      style: tt.titleSmall
                          ?.copyWith(color: cs.onSurface),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _dismiss,
                      icon: Icon(Icons.close,
                          color: cs.onSurfaceVariant, size: 20),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                          minWidth: 40, minHeight: 40),
                      tooltip: 'Dismiss',
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(
                      controller: _originCtrl,
                      hint: 'From (origin)',
                      icon: Icons.trip_origin,
                      iconColor: cs.secondary,
                      cs: cs,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      controller: _destCtrl,
                      hint: 'To (destination)',
                      icon: Icons.location_on,
                      iconColor: cs.tertiary,
                      cs: cs,
                      onSubmit: _submit,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isLoading ? null : _submit,
                        icon: isLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.onPrimary,
                                ),
                              )
                            : const Icon(Icons.directions, size: 18),
                        label: Text(
                          isLoading ? 'Finding route…' : 'Get Route',
                          style: tt.labelLarge,
                        ),
                      ),
                    ),
                    if (route.status == RouteStatus.error &&
                        route.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                size: 14, color: cs.error),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                route.errorMessage!,
                                style: tt.labelSmall
                                    ?.copyWith(color: cs.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required ColorScheme cs,
    VoidCallback? onSubmit,
  }) =>
      TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
            ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: cs.onSurfaceVariant),
          prefixIcon: Icon(icon, color: iconColor, size: 20),
          isDense: true,
          filled: true,
          fillColor: cs.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        textInputAction:
            onSubmit != null ? TextInputAction.go : TextInputAction.next,
        onSubmitted: onSubmit != null ? (_) => onSubmit() : null,
      );
}
