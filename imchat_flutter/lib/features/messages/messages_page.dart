import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/data_repository.dart';
import '../rooms/room_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late final DataRepository repo;
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    repo = DataRepository(Supabase.instance.client);
    future = repo.myMessages();
  }

  Future<void> refresh() async {
    final next = repo.myMessages();
    setState(() => future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: refresh,
    child: FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ListView(children: [
            const SizedBox(height: 100),
            Center(child: Text(
              'تعذر تحميل الرسائل: ${snapshot.error}',
              textAlign: TextAlign.center,
            )),
          ]);
        }
        final rows = snapshot.data ?? [];
        if (rows.isEmpty) {
          return ListView(children: const [
            SizedBox(height: 120),
            Icon(Icons.forum_outlined, size: 60),
            Center(child: Text('لا توجد رسائل بعد. ادخل غرفة وابدأ الكلام.')),
          ]);
        }
        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final message = rows[index];
            final room = message['rooms'] is Map
                ? Map<String, dynamic>.from(message['rooms'])
                : <String, dynamic>{};
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.forum)),
              title: Text((room['title'] ?? 'غرفة').toString()),
              subtitle: Text(
                (message['body'] ?? 'رسالة').toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: room['id'] == null ? null : () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => RoomPage(room: room, alreadyMember: true),
                ));
              },
            );
          },
        );
      },
    ),
  );
}
