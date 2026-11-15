import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
      children: [
        const CircleAvatar(radius: 42, child: Icon(Icons.forum, size: 42)),
        const SizedBox(height: 18),
        const Text('مرحبًا بك في Im Chat', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8), const Text('سجّل الدخول للانضمام إلى مجتمعك'),
        const SizedBox(height: 28),
        const TextField(decoration: InputDecoration(labelText: 'البريد الإلكتروني أو رقم الهاتف', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        const TextField(obscureText: true, decoration: InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder())),
        const SizedBox(height: 18),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () {}, child: const Text('تسجيل الدخول'))),
        TextButton(onPressed: () {}, child: const Text('إنشاء حساب جديد')),
      ],
    )))),
  );
}
