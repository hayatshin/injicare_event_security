import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const supabaseUrl =
        String.fromEnvironment('SUPABASE_URL', defaultValue: "url");
    const supabaseAnonKey =
        String.fromEnvironment('SUPABASE_ANONKEY', defaultValue: "anonkey");
    return const Scaffold(
      body: Row(
        children: [
          Column(
            children: [
              Text("check"),
              Text(supabaseUrl),
              Text(supabaseAnonKey),
            ],
          ),
        ],
      ),
    );
  }
}
