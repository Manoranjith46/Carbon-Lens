import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'providers/providers.dart';
import 'theme/carbon_theme.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: CarbonLensApp(),
    ),
  );
}

class CarbonLensApp extends ConsumerWidget {
  const CarbonLensApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final carbonStatus = ref.watch(carbonStatusProvider);
    final themeModeSetting = ref.watch(themeModeProvider);

    // Convert ThemeModeSetting to Flutter ThemeMode
    final themeMode = switch (themeModeSetting) {
      ThemeModeSetting.system => ThemeMode.system,
      ThemeModeSetting.light => ThemeMode.light,
      ThemeModeSetting.dark => ThemeMode.dark,
    };

    return MaterialApp.router(
      title: 'CarbonLens',
      debugShowCheckedModeBanner: false,
      theme: CarbonTheme.light(carbonStatus),
      darkTheme: CarbonTheme.dark(carbonStatus),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
