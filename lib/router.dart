import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:injicare_event/view/home.dart';
import 'package:injicare_event/view/navigator_screen.dart';

final routerProvider = Provider((ref) {
  return GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(
        name: "home",
        path: "/",
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const Home(),
        ),
        routes: [
          GoRoute(
            name: "eventDetail",
            path: ":userId",
            pageBuilder: (context, state) {
              final userId = state.pathParameters["userId"];
              final eventId = state.pathParameters["eventId"];

              if (userId != null && eventId != null) {
                return NoTransitionPage(
                  child: NavigatorScreen(
                    eventId: eventId,
                    userId: userId,
                  ),
                );
              }
              return const NoTransitionPage(
                child: Home(),
              );
            },
          ),
        ],
      ),
    ],
  );
});
