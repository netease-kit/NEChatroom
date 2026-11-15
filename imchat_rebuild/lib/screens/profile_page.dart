import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const SizedBox(height: 16),
    const Center(child: CircleAvatar(radius: 44, child: Icon(Icons.person, size: 44))),
    const SizedBox(height: 10),
    const Center(child: Text('اسم المستخدم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    const Center(child: Text('ID: —', style: TextStyle(color: Colors.black54))),
    const SizedBox(height: 20),
    Card(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
      _Stat('المتابَعون', '0'), _Stat('المتابِعون', '0'), _Stat('الإعجابات', '0'),
    ])),
    for (final item in [
      (Icons.account_balance_wallet_outlined, 'المحفظة'),
      (Icons.card_giftcard, 'الهدايا'),
      (Icons.workspace_premium_outlined, 'عضوية VIP'),
      (Icons.groups_outlined, 'العائلة'),
      (Icons.business_outlined, 'الوكالة'),
      (Icons.settings_outlined, 'الإعدادات'),
    ]) Card(child: ListTile(leading: Icon(item.$1), title: Text(item.$2), trailing: const Icon(Icons.chevron_left))),
  ]);
}
class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(14), child: Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(label)]));
}
