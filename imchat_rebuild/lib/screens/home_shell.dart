import 'package:flutter/material.dart';
import 'messages_page.dart';
import 'profile_page.dart';
import 'room_detail_page.dart';
import 'moments_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  static const pages = ['الرئيسية', 'الرسائل', 'اللحظات', 'أنا'];
  @override
  Widget build(BuildContext context) {
    final bodies = [const _Rooms(), const MessagesPage(), const MomentsPage(), const ProfilePage()];
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
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'الرسائل'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'اللحظات'),
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
    Row(children: [const Expanded(child: Text('اكتشف الغرف', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('إنشاء غرفة'))]),
    const SizedBox(height: 14),
    const Wrap(spacing: 8, children: [Chip(label: Text('الكل')), Chip(label: Text('نشطة')), Chip(label: Text('جديدة'))]),
    const SizedBox(height: 8),
    for (var i = 0; i < 8; i++) _RoomCard(number: i + 1),
  ]);
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.number});
  final int number;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RoomDetailPage(roomName: 'غرفة دردشة $number'))),
      child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
        const CircleAvatar(radius: 27, backgroundColor: Color(0xFFE9E3FF), child: Icon(Icons.headphones, color: Color(0xFF6D4AE6))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('غرفة دردشة $number', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('غرفة صوتية ومحادثة مباشرة', style: TextStyle(color: Colors.black54, fontSize: 12)),
        ])),
        const Column(children: [Icon(Icons.people_alt_outlined, size: 18), Text('12', style: TextStyle(fontSize: 12))]),
      ])),
    ),
  );
}
