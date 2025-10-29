import 'dart:js_interop'; // JSAny / JSObject / JSString
import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injicare_event_security/constants/sizes.dart';
import 'package:injicare_event_security/injicare_color.dart';
import 'package:injicare_event_security/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web; // Window, Document 등

Future<String?> readInjectedToken() async {
  // window.__INJICARE_ID_TOKEN__
  final JSAny? tokenJs =
      (web.window as JSObject).getProperty('__INJICARE_ID_TOKEN__'.toJS);

  // JS → Dart
  final String? token = (tokenJs as JSString?)?.toDart;
  return token;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "env");

  final supabaseUrlDebug = dotenv.env["SUPABASE_URL"];
  final supabaseAnonKeyDebug = dotenv.env["SUPABASE_ANONKEY"];

  await Supabase.initialize(
    url: supabaseUrlDebug!,
    anonKey: supabaseAnonKeyDebug!,
    accessToken: readInjectedToken, // ← 여기!
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
        colorScheme: ColorScheme.light(
          primary: InjicareColor().primary50,
          secondary: InjicareColor().primary20,
        ),
        // textSelectionTheme: const TextSelectionThemeData(
        //   cursorColor: InjicareColor(),
        // ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 5.0,
          surfaceTintColor: const Color.fromARGB(255, 68, 41, 41),
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
          checkmarkColor: InjicareColor().primary50,
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
        primaryColor: InjicareColor().primary50,
        colorScheme: ColorScheme.dark(
          primary: InjicareColor().primary50,
          secondary: InjicareColor().primary20,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: InjicareColor().primary50,
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
