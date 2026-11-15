import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/data_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final DataRepository repo;
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    repo = DataRepository(Supabase.instance.client);
    future = load();
  }

  Future<List<dynamic>> load() async =>
      Future.wait([repo.ensureProfile(), repo.wallet()]);

  Future<void> editName(String current) async {
    final controller = TextEditingController(text: current);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تعديل الاسم'),
        content: TextField(
          controller: controller,
          maxLength: 40,
          decoration: const InputDecoration(labelText: 'الاسم الظاهر'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (ok == true && controller.text.trim().isNotEmpty) {
      try {
        await repo.updateDisplayName(controller.text);
        if (mounted) setState(() => future = load());
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تحديث الاسم: $e')),
        );
      }
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<dynamic>>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) return Center(
        child: Text('تعذر تحميل الحساب: ${snapshot.error}'),
      );
      final profile = Map<String, dynamic>.from(snapshot.data![0] as Map);
      final wallet = snapshot.data![1] as Map<String, dynamic>?;
      final user = Supabase.instance.client.auth.currentUser;
      return ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 18),
        const Center(child: CircleAvatar(
          radius: 48, child: Icon(Icons.person, size: 52),
        )),
        const SizedBox(height: 12),
        Center(child: Text(
          (profile['display_name'] ?? 'مستخدم').toString(),
          style: Theme.of(context).textTheme.headlineSmall,
        )),
        Center(child: Text((profile['username'] ?? '').toString())),
        Center(child: Text(user?.email ?? '')),
        const SizedBox(height: 20),
        Card(child: ListTile(
          leading: const Icon(Icons.stars),
          title: const Text('المستوى'),
          trailing: Text('${profile['level'] ?? 1}'),
        )),
        Card(child: ListTile(
          leading: const Icon(Icons.monetization_on),
          title: const Text('العملات'),
          trailing: Text('${wallet?['coins'] ?? 0}'),
        )),
        Card(child: ListTile(
          leading: const Icon(Icons.diamond),
          title: const Text('الماس'),
          trailing: Text('${wallet?['diamonds'] ?? 0}'),
        )),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => editName((profile['display_name'] ?? '').toString()),
          icon: const Icon(Icons.edit),
          label: const Text('تعديل الاسم'),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() => future = load()),
          icon: const Icon(Icons.refresh),
          label: const Text('تحديث البيانات'),
        ),
        const SizedBox(height: 18),
        FilledButton.tonalIcon(
          onPressed: () => Supabase.instance.client.auth.signOut(),
          icon: const Icon(Icons.logout),
          label: const Text('تسجيل الخروج'),
        ),
      ]);
    },
  );
}
