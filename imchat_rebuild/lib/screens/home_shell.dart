import 'package:flutter/material.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  static const pages = ['الغرف', 'الرسائل', 'لحظات', 'أنا'];
  @override
  Widget build(BuildContext context) {
    final bodies = [const _Rooms(), const _Messages(), const _Moments(), const _Profile()];
    return Scaffold(
      appBar: AppBar(
        title: Text(pages[index], style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search)), IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))],
      ),
      body: IndexedStack(index: index, children: bodies),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.meeting_room_outlined), selectedIcon: Icon(Icons.meeting_room), label: 'الغرف'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'الرسائل'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'لحظات'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'أنا'),
        ],
      ),
    );
  }
}

class _Rooms extends StatelessWidget {
  const _Rooms();
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Row(children: [const Expanded(child: Text('اكتشف الغرف الصوتية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('إنشاء غرفة'))]),
    const SizedBox(height: 14),
    const Wrap(spacing: 8, children: [Chip(label: Text('الكل')), Chip(label: Text('الأكثر نشاطًا')), Chip(label: Text('جديد'))]),
    const SizedBox(height: 8),
    for (var i = 0; i < 8; i++) _RoomCard(number: i + 1),
  ]);
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.number});
  final int number;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12), clipBehavior: Clip.antiAlias,
    child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      CircleAvatar(radius: 27, backgroundColor: const Color(0xFFE9E3FF), child: Icon(Icons.headphones, color: Color(0xFF7655E8))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('غرفة دردشة $number', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4), const Text('مرحبًا بالجميع • غرفة صوتية', style: TextStyle(color: Colors.black54, fontSize: 12)),
      ])),
      const Column(children: [Icon(Icons.people_alt_outlined, size: 18), Text('12', style: TextStyle(fontSize: 12))]),
    ])),
  );
}

class _Messages extends StatelessWidget {
  const _Messages();
  @override
  Widget build(BuildContext context) => ListView(children: const [
    ListTile(leading: CircleAvatar(child: Icon(Icons.person)), title: Text('المحادثات'), subtitle: Text('ستظهر رسائلك هنا بعد ربط الحساب')),
    Divider(height: 1),
    ListTile(leading: CircleAvatar(child: Icon(Icons.group)), title: Text('مجموعات'), subtitle: Text('محادثاتك الجماعية')),
  ]);
}
class _Moments extends StatelessWidget {
  const _Moments();
  @override
  Widget build(BuildContext context) => const Center(child: Text('قسم اللحظات والفيديوهات — قيد التنفيذ'));
}
class _Profile extends StatelessWidget {
  const _Profile();
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: const [
    CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)),
    SizedBox(height: 12),
    Center(child: Text('ملفي الشخصي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    SizedBox(height: 20),
    Card(child: ListTile(leading: Icon(Icons.account_balance_wallet_outlined), title: Text('المحفظة'), subtitle: Text('الرصيد سيظهر بعد ربط قاعدة البيانات'))),
    Card(child: ListTile(leading: Icon(Icons.workspace_premium_outlined), title: Text('VIP'))),
    Card(child: ListTile(leading: Icon(Icons.settings_outlined), title: Text('الإعدادات'))),
  ]);
}
