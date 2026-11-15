import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? message;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() { busy = true; message = null; });
    try {
      await action();
    } on AuthException catch (e) {
      if (mounted) setState(() => message = e.message);
    } catch (e) {
      if (mounted) setState(() => message = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> signIn() => _run(() async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email.text.trim(),
      password: password.text,
    );
  });

  Future<void> signUp() => _run(() async {
    await Supabase.instance.client.auth.signUp(
      email: email.text.trim(),
      password: password.text,
    );
    if (mounted) {
      setState(() => message =
          'تم إرسال طلب إنشاء الحساب. تحقق من بريدك إذا كان تأكيد البريد مفعّلًا.');
    }
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.forum_rounded, size: 72),
                const SizedBox(height: 16),
                Text('Im Chat',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 28),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 12),
                  Text(message!, style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: busy ? null : signIn,
                  child: Text(busy ? 'انتظر...' : 'تسجيل الدخول'),
                ),
                TextButton(
                  onPressed: busy ? null : signUp,
                  child: const Text('إنشاء حساب'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
