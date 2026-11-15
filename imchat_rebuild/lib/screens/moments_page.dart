import 'package:flutter/material.dart';
import '../core/app_assets.dart';
import '../core/asset_image_or.dart';

class MomentsPage extends StatelessWidget {
  const MomentsPage({super.key});
  @override
  Widget build(BuildContext context) => Stack(children: [
    Positioned.fill(child: AssetImageOr(path: AppAssets.messageBackground, fit: BoxFit.cover, fallback: const ColoredBox(color: Color(0xFFF8F7FC)))),
    ListView(padding: const EdgeInsets.all(16), children: [
      const Text('اللحظات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      for (final title in ['مشاركة جديدة', 'أحدث الفيديوهات', 'الأكثر تفاعلًا'])
        Card(child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.play_arrow)),
          title: Text(title),
          subtitle: const Text('سيتم ربط المحتوى الحقيقي بعد إعداد خدمات البيانات'),
          trailing: const Icon(Icons.chevron_left),
        )),
    ]),
  ]);
}
