import 'package:flutter/material.dart';
import 'screens/home_shell.dart';

class ImChatRebuildApp extends StatelessWidget {
  const ImChatRebuildApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF17152B);
    const accent = Color(0xFF7655E8);
    return MaterialApp(
      title: 'Im Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F6FB),
        colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.light),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF7F6FB), foregroundColor: ink, elevation: 0),
        fontFamily: 'Roboto',
      ),
      home: const Directionality(textDirection: TextDirection.rtl, child: HomeShell()),
    );
  }
}
