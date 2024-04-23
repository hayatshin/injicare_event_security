import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final supabaseUrlDebug = dotenv.env["SUPABASE_URL"];
    final supabaseAnonKeyDebug = dotenv.env["SUPABASE_ANONKEY"];

    return Scaffold(
      body: Column(
        children: [
          const Text("check"),
          Text(supabaseUrlDebug ?? "no supabaseUrlDebug"),
          Text(supabaseAnonKeyDebug ?? "no supabaseAnonKey"),
        ],
      ),
    );
  }
}
