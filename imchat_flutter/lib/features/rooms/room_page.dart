import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/data_repository.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key, required this.room, this.alreadyMember = false});
  final Map<String, dynamic> room;
  final bool alreadyMember;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late final DataRepository repo;
  final input = TextEditingController();
  bool sending = false;

  @override
  void initState() {
    super.initState();
    repo = DataRepository(Supabase.instance.client);
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (sending || input.text.trim().isEmpty) return;
    final value = input.text;
    input.clear();
    setState(() => sending = true);
    try {
      await repo.sendRoomMessage(widget.room['id'].toString(), value);
    } catch (e) {
      input.text = value;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال الرسالة: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text((widget.room['title'] ?? 'الغرفة').toString())),
    body: Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text(
          widget.room['description']?.toString().isNotEmpty == true
              ? widget.room['description'].toString()
              : 'مرحبًا بك في الغرفة',
        ),
      ),
      Expanded(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: repo.roomMessages(widget.room['id'].toString()),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text(
              'تعذر تحميل المحادثة: ${snapshot.error}',
              textAlign: TextAlign.center,
            ));
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final messages = snapshot.data!;
            if (messages.isEmpty) {
              return const Center(child: Text('ابدأ المحادثة برسالة جديدة'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final mine = message['sender_id'] ==
                    Supabase.instance.client.auth.currentUser?.id;
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * .78,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: mine
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text((message['body'] ?? '[محتوى]').toString()),
                  ),
                );
              },
            );
          },
        ),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          child: Row(children: [
            Expanded(child: TextField(
              controller: input,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => send(),
              decoration: const InputDecoration(
                hintText: 'اكتب رسالة...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            )),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: sending ? null : send,
              icon: sending
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ]),
        ),
      ),
    ]),
  );
}
