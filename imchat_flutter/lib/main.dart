import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app_config.dart';
import 'features/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configured = AppConfig.supabaseUrl.startsWith('https://') &&
      AppConfig.supabasePublishableKey.startsWith('sb_publishable_');
  if (configured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabasePublishableKey,
    );
  }
  runApp(ImChatApp(configured: configured));
}

class ImChatApp extends StatelessWidget {
  const ImChatApp({super.key, required this.configured});
  final bool configured;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Im Chat',
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff7b45d6),
          ),
        ),
        home: configured ? const AuthGate() : const _SetupRequired(),
      );
}

class _SetupRequired extends StatelessWidget {
  const _SetupRequired();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'بيانات Supabase غير مضبوطة. شغّل التطبيق باستخدام '
              'SUPABASE_URL وSUPABASE_PUBLISHABLE_KEY عبر dart-define.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
}
