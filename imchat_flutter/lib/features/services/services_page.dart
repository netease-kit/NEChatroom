import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/data_repository.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  late final DataRepository repo;
  late Future<List<List<Map<String, dynamic>>>> future;

  @override
  void initState() {
    super.initState();
    repo = DataRepository(Supabase.instance.client);
    future = load();
  }

  Future<List<List<Map<String, dynamic>>>> load() => Future.wait([
    repo.families(),
    repo.agencies(),
    repo.gifts(),
    repo.vipPackages(),
    repo.notifications(),
  ]);

  Future<void> refresh() async {
    final next = load();
    setState(() => future = next);
    await next;
  }

  Future<void> createEntity({required bool family}) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(family ? 'إنشاء عائلة' : 'إنشاء وكالة'),
        content: TextField(
          controller: controller,
          maxLength: 60,
          decoration: const InputDecoration(labelText: 'الاسم'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    try {
      if (family) {
        await repo.createFamily(name);
      } else {
        await repo.createAgency(name);
      }
      await refresh();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الإنشاء')),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الإنشاء: $e')),
      );
    }
  }

  Widget section(String title, List<Map<String, dynamic>> rows,
      {String subtitle = 'name', IconData icon = Icons.circle_outlined}) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text('$title (${rows.length})'),
        children: rows.isEmpty
            ? const [ListTile(title: Text('لا توجد بيانات بعد'))]
            : rows.take(20).map((row) => ListTile(
                title: Text((row['name'] ?? row['title'] ?? 'عنصر').toString()),
                subtitle: row[subtitle] == null || subtitle == 'name'
                    ? null : Text(row[subtitle].toString()),
              )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: refresh,
    child: FutureBuilder<List<List<Map<String, dynamic>>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return ListView(children: [
          const SizedBox(height: 100),
          Center(child: Text(
            'تعذر تحميل الخدمات: ${snapshot.error}',
            textAlign: TextAlign.center,
          )),
        ]);
        final data = snapshot.data!;
        return ListView(padding: const EdgeInsets.all(12), children: [
          Row(children: [
            Expanded(child: FilledButton.tonalIcon(
              onPressed: () => createEntity(family: true),
              icon: const Icon(Icons.groups),
              label: const Text('إنشاء عائلة'),
            )),
            const SizedBox(width: 8),
            Expanded(child: FilledButton.tonalIcon(
              onPressed: () => createEntity(family: false),
              icon: const Icon(Icons.business),
              label: const Text('إنشاء وكالة'),
            )),
          ]),
          section('العائلات', data[0], icon: Icons.groups),
          section('الوكالات', data[1], icon: Icons.business),
          section('الهدايا المتاحة', data[2], icon: Icons.card_giftcard),
          section('باقات VIP', data[3], icon: Icons.workspace_premium),
          section('الإشعارات', data[4], subtitle: 'body', icon: Icons.notifications),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'الشراء والشحن وإرسال الهدايا يتطلبان تحققًا آمنًا من الرصيد '
              'داخل قاعدة البيانات أو Edge Functions. لا تنفذ هذه العمليات '
              'من واجهة التطبيق مباشرة.',
              textAlign: TextAlign.center,
            ),
          ),
        ]);
      },
    ),
  );
}
