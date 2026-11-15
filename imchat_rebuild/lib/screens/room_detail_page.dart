import 'package:flutter/material.dart';

class RoomDetailPage extends StatelessWidget {
  const RoomDetailPage({super.key, required this.roomName});
  final String roomName;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(roomName)),
    body: Column(children: [
      Container(
        width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF7655E8), Color(0xFFB39AF7)])),
        child: const Column(children: [
          CircleAvatar(radius: 34, child: Icon(Icons.headphones, size: 32)),
          SizedBox(height: 8), Text('غرفة صوتية', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('وصف الغرفة يظهر هنا', style: TextStyle(color: Colors.white70)),
        ]),
      ),
      const Padding(padding: EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _Seat(), _Seat(), _Seat(), _Seat(),
      ])),
      const Divider(),
      const Expanded(child: Center(child: Text('رسائل الغرفة ستظهر هنا بعد تنفيذ خدمة الدردشة'))),
      SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
        const Expanded(child: TextField(decoration: InputDecoration(hintText: 'اكتب رسالة...', border: OutlineInputBorder(), isDense: true))),
        IconButton(onPressed: () {}, icon: const Icon(Icons.card_giftcard)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.mic)),
      ]))),
    ]),
  );
}

class _Seat extends StatelessWidget {
  const _Seat();
  @override
  Widget build(BuildContext context) => const Column(children: [
    CircleAvatar(radius: 25, child: Icon(Icons.person)),
    SizedBox(height: 4), Text('مقعد'),
  ]);
}
