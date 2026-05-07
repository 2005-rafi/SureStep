import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/theme.dart';
import 'theme/util.dart';
import 'providers/theme_provider.dart';
import 'widgets/map_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SureStepApp()));
}

class SureStepApp extends ConsumerWidget {
  const SureStepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final textTheme = createTextTheme();
    final materialTheme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'SureStep',
      themeMode: themeMode,
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      debugShowCheckedModeBanner: false,
      home: const MapView(),
    );
  }
}
