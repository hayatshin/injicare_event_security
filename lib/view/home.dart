import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String url = "";
  String anonkey = "";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    await dotenv.load(fileName: ".env");

    final supabaseUrlDebug = dotenv.env["SUPABASE_URL"] ?? "no";
    final supabaseAnonKeyDebug = dotenv.env["SUPABASE_ANONKEY"] ?? "no";

    setState(() {
      url = supabaseUrlDebug;
      anonkey = supabaseAnonKeyDebug;
    });
  }

  @override
  Widget build(BuildContext context) {
    const supabaseUrl =
        String.fromEnvironment('envkey_SUPABASE_URL', defaultValue: "check1");
    const supabaseAnonKey = String.fromEnvironment('envkey_SUPABASE_ANONKEY',
        defaultValue: "check2");

    return Scaffold(
      body: Row(
        children: [
          Column(
            children: [
              const Text("check"),
              Text(".env 1 -> $url"),
              Text(".env 2 -> $anonkey"),
              const Text("String 3 -> $supabaseUrl"),
              const Text("String 4 -> $supabaseAnonKey"),
            ],
          ),
        ],
      ),
    );
  }
}
