import 'package:flutter/material.dart';
import 'screens/splash_page.dart';

class ImChatRebuildApp extends StatelessWidget {
  const ImChatRebuildApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6D4AE6);
    return MaterialApp(
      title: 'Im Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF7F6FB),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF7F6FB), foregroundColor: Color(0xFF1B1830), elevation: 0),
      ),
      home: const Directionality(textDirection: TextDirection.rtl, child: SplashPage()),
    );
  }
}
