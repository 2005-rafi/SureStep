import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/route_provider.dart';
import '../models/route_state.dart';

class SearchPanel extends ConsumerStatefulWidget {
  final bool visible;
  const SearchPanel({super.key, required this.visible});

  @override
  ConsumerState<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends ConsumerState<SearchPanel> {
  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final origin = _originCtrl.text.trim();
    final dest = _destCtrl.text.trim();
    if (origin.isEmpty || dest.isEmpty) return;
    ref.read(routeProvider.notifier).setOrigin(origin);
    ref.read(routeProvider.notifier).setDestination(dest);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final route = ref.watch(routeProvider);
    final isLoading = route.status == RouteStatus.loading;

    return AnimatedSlide(
      offset: widget.visible ? Offset.zero : const Offset(0, -1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: widget.visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(
                controller: _originCtrl,
                hint: 'From (origin)',
                icon: Icons.trip_origin,
                color: cs.secondary,
              ),
              const SizedBox(height: 8),
              _field(
                controller: _destCtrl,
                hint: 'To (destination)',
                icon: Icons.location_on,
                color: cs.tertiary,
                onSubmit: _submit,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isLoading ? null : _submit,
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.directions),
                      label: Text(isLoading ? 'Finding route…' : 'Get Route'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: () {
                      _originCtrl.clear();
                      _destCtrl.clear();
                      ref.read(routeProvider.notifier).clearRoute();
                    },
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear route',
                  ),
                ],
              ),
              if (route.status == RouteStatus.error && route.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    route.errorMessage!,
                    style: TextStyle(color: cs.error, fontSize: 12),
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
    required Color color,
    VoidCallback? onSubmit,
  }) =>
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: color, size: 20),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        textInputAction:
            onSubmit != null ? TextInputAction.go : TextInputAction.next,
        onSubmitted: onSubmit != null ? (_) => onSubmit() : null,
      );
}
