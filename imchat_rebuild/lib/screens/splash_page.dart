import 'package:flutter/material.dart';
import '../core/app_assets.dart';
import '../core/asset_image_or.dart';
import 'home_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
    });
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(fit: StackFit.expand, children: [
      AssetImageOr(path: AppAssets.intro, fit: BoxFit.cover, fallback: const ColoredBox(color: Color(0xFF6E45D8))),
      Center(child: Container(
        width: 128, height: 128, decoration: BoxDecoration(color: Colors.black.withOpacity(.28), borderRadius: BorderRadius.circular(28)),
        child: AssetImageOr(path: AppAssets.logo, fit: BoxFit.contain, borderRadius: BorderRadius.circular(28), fallback: const Icon(Icons.forum, color: Colors.white, size: 70)),
      )),
    ]),
  );
}
