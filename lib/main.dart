import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injicare_event/constants/sizes.dart';
import 'package:injicare_event/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "env");

  final supabaseUrlDebug = dotenv.env["SUPABASE_URL"];
  final supabaseAnonKeyDebug = dotenv.env["SUPABASE_ANONKEY"];

  await Supabase.initialize(
    url: supabaseUrlDebug!,
    anonKey: supabaseAnonKeyDebug!,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: router,
      // routeInformationParser: MyRouteInformationParser(),
      title: 'Onldocc Flutter App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Pretendard",
        textTheme: Typography.blackMountainView,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFF2D78),
          secondary: Color(0xfff3b4c9),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFFF2D78),
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 5.0,
          surfaceTintColor: Colors.grey.shade200,
          indicatorColor: Colors.pinkAccent.shade100.withOpacity(0.1),
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(
              fontSize: Sizes.size16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          iconTheme: WidgetStateProperty.all(
            IconThemeData(
              color: Colors.grey.shade700,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          checkmarkColor: const Color(0xFFFF2D78),
          side: BorderSide(
            color: Colors.grey.shade500,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFFFF2D78),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF2D78),
          secondary: Color(0xfff3b4c9),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFFF2D78),
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 5.0,
          // surfaceTintColor: Colors.grey.shade100,
          indicatorColor: Colors.pinkAccent.shade100.withOpacity(0.1),
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(
              fontSize: Sizes.size16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          iconTheme: WidgetStateProperty.all(
            IconThemeData(
              color: Colors.grey.shade400,
            ),
          ),
        ),
        textTheme: Typography.whiteMountainView,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        chipTheme: ChipThemeData(
          checkmarkColor: Colors.pinkAccent.shade100.withOpacity(0.1),
          side: BorderSide(
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
