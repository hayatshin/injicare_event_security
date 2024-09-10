import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injicare_event/models/event_model.dart';
import 'package:injicare_event/models/user_profile.dart';
import 'package:injicare_event/view/default_screen.dart';
import 'package:injicare_event/view/error_screen.dart';
import 'package:injicare_event/view/event_detail_count_screen.dart';
import 'package:injicare_event/view/event_detail_multiple_scores_screen.dart';
import 'package:injicare_event/view/event_detail_photo_screen.dart';
import 'package:injicare_event/view/event_detail_quiz_screen.dart';
import 'package:injicare_event/view/event_detail_target_score_screen.dart';
import 'package:injicare_event/view_models/event_view_model.dart';
import 'package:injicare_event/view_models/user_provider.dart';

class NavigatorScreen extends ConsumerStatefulWidget {
  final String eventId;
  final String userId;
  const NavigatorScreen({
    super.key,
    required this.eventId,
    required this.userId,
  });

  @override
  ConsumerState<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends ConsumerState<NavigatorScreen> {
  @override
  void initState() {
    super.initState();
    _navigator();
  }

  void _navigator() async {
    EventModel eventModel = await ref
        .read(eventProvider.notifier)
        .fetchCertainEvent(widget.eventId);

    UserProfile userProfile = await ref
        .read(userProvider.notifier)
        .fetchCertainUserProfile(widget.userId);

    if (eventModel.eventType == "targetScore") {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EventDetailTargetScoreScreen(
            eventModel: eventModel,
            userProfile: userProfile,
          ),
        ),
      );
    } else if (eventModel.eventType == "multipleScores") {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EventDetailMultipleScoresScreen(
            eventModel: eventModel,
            userProfile: userProfile,
          ),
        ),
      );
    } else if (eventModel.eventType == "count") {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EventDetailCountScreen(
            eventModel: eventModel,
            userProfile: userProfile,
          ),
        ),
      );
    } else if (eventModel.eventType == "quiz") {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EventDetailQuizScreen(
            eventModel: eventModel,
            userProfile: userProfile,
          ),
        ),
      );
    } else if (eventModel.eventType == "photo") {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EventDetailPhotoScreen(
            eventModel: eventModel,
            userProfile: userProfile,
          ),
        ),
      );
    } else {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ErrorScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const DefaultScreen();
  }
}
