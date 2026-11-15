import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/data_repository.dart';
import 'room_page.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});
  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  late final DataRepository repo;
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    repo = DataRepository(Supabase.instance.client);
    future = repo.rooms();
  }

  Future<void> refresh() async {
    final next = repo.rooms();
    setState(() => future = next);
    await next;
  }

  Future<void> createRoom() async {
    final title = TextEditingController();
    final description = TextEditingController();
    var isPrivate = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('إنشاء غرفة جديدة'),
          content: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, maxLength: 50,
                decoration: const InputDecoration(labelText: 'اسم الغرفة')),
              TextField(controller: description, maxLength: 180,
                decoration: const InputDecoration(labelText: 'وصف الغرفة')),
              SwitchListTile(
                value: isPrivate,
                onChanged: (value) => setDialogState(() => isPrivate = value),
                title: const Text('غرفة خاصة'),
              ),
            ],
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('إنشاء'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) {
      title.dispose();
      description.dispose();
      return;
    }
    if (title.text.trim().isEmpty) {
      title.dispose();
      description.dispose();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب اسم الغرفة')),
      );
      return;
    }
    try {
      final room = await repo.createRoom(
        title: title.text,
        description: description.text,
        isPrivate: isPrivate,
      );
      await refresh();
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => RoomPage(room: room, alreadyMember: true),
      ));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إنشاء الغرفة: $e')),
      );
    } finally {
      title.dispose();
      description.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: createRoom,
      icon: const Icon(Icons.add),
      label: const Text('إنشاء غرفة'),
    ),
    body: RefreshIndicator(
      onRefresh: refresh,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return ListView(children: [
            const SizedBox(height: 100),
            Center(child: Text(
              'تعذر تحميل الغرف\n${snapshot.error}',
              textAlign: TextAlign.center,
            )),
          ]);
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) return ListView(children: const [
            SizedBox(height: 120),
            Icon(Icons.meeting_room_outlined, size: 64),
            Center(child: Text('لا توجد غرف بعد. أنشئ أول غرفة!')),
          ]);
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final room = rows[index];
              final cover = room['cover_url']?.toString();
              return Card(child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: cover == null ? null : NetworkImage(cover),
                  child: cover == null ? const Icon(Icons.groups) : null,
                ),
                title: Text((room['title'] ?? 'غرفة').toString(),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${room['room_type'] == 'private' ? 'خاصة' : 'عامة'} • '
                  '${room['description'] ?? 'انضم للمحادثة'}',
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  try {
                    await repo.joinRoom(room['id'].toString());
                    if (!context.mounted) return;
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => RoomPage(room: room, alreadyMember: true),
                    ));
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('لا يمكن الانضمام: $e')),
                    );
                  }
                },
              ));
            },
          );
        },
      ),
    ),
  );
}
