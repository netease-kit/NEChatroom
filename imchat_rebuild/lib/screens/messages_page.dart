import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(12), children: [
    const Text('الرسائل', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    for (final title in ['المحادثات الخاصة', 'مجموعات الدردشة', 'إشعارات النظام'])
      Card(child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.chat_bubble_outline)),
        title: Text(title), subtitle: const Text('ستظهر المحادثات بعد ربط الحساب والخدمات'),
        trailing: const Icon(Icons.chevron_left),
      )),
  ]);
}
