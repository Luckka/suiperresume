import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:resumo_turbo/pages/history_page.dart';
import 'package:resumo_turbo/pages/home_page.dart';
import 'package:resumo_turbo/pages/login_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resumo Turbo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/history': (_) => const HistoryPage(),
      },
    );
  }
}
