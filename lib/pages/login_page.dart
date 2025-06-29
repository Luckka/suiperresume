import 'package:flutter/material.dart';
import 'package:resumo_turbo/controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  
  LoginPage({super.key});

  final controller = LoginController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Resumo Turbo', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Entrar com Google'),
              onPressed: () => controller.signInWithGoogle(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}