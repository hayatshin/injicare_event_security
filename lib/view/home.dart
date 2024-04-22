import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANONKEY');

    return const Scaffold(
      body: Column(
        children: [
          Text(supabaseUrl),
          Text(supabaseAnonKey),
        ],
      ),
    );
  }
}
