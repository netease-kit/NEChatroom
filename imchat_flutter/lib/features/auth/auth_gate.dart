import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/data_repository.dart';
import '../home/app_shell.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    return StreamBuilder<AuthState>(
      stream: client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (client.auth.currentSession == null) return const LoginPage();
        return FutureBuilder<Map<String, dynamic>>(
          future: DataRepository(client).ensureProfile(),
          builder: (context, profile) {
            if (profile.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (profile.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'تعذر تجهيز ملف الحساب: ${profile.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }
            return const AppShell();
          },
        );
      },
    );
  }
}
