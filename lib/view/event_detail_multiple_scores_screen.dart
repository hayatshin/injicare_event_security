import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injicare_event/constants/gaps.dart';
import 'package:injicare_event/constants/sizes.dart';
import 'package:injicare_event/injicare_color.dart';
import 'package:injicare_event/injicare_font.dart';
import 'package:injicare_event/models/event_model.dart';
import 'package:injicare_event/models/user_profile.dart';
import 'package:injicare_event/repos/event_repo.dart';
import 'package:injicare_event/utils.dart';
import 'package:injicare_event/view_models/event_view_model.dart';
import 'package:injicare_event/widgets/button_widgets.dart';
import 'package:injicare_event/widgets/desc_tile_widgets.dart';
import 'package:injicare_event/widgets/event_detail_template.dart';

class EventDetailMultipleScoresScreen extends ConsumerStatefulWidget {
  final EventModel eventModel;
  final UserProfile userProfile;

  const EventDetailMultipleScoresScreen({
    super.key,
    required this.eventModel,
    required this.userProfile,
  });

  @override
  ConsumerState<EventDetailMultipleScoresScreen> createState() =>
      _EventDetailPointScreenState();
}

class _EventDetailPointScreenState
    extends ConsumerState<EventDetailMultipleScoresScreen> {
  bool _myParticipationLoadingComplete = false;
  bool _myParticipation = true;

  EventModel stateEventModel = EventModel.empty();
  bool _completeScoreLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUserScore();
    _initializeMyParticipation();
  }

  Future<void> _initializeUserScore() async {
    final updateScoreModel = await ref
        .read(eventProvider.notifier)
        .updateUserScore(widget.eventModel, widget.userProfile.userId);

    setState(() {
      _completeScoreLoading = true;
      stateEventModel = updateScoreModel;
    });
  }

  Future<void> _initializeMyParticipation() async {
    List<Map<String, dynamic>> dbMyParticipation = await ref
        .read(eventRepo)
        .checkMyParticiapationEvent(
            widget.eventModel.eventId, widget.userProfile.userId);

    if (mounted) {
      setState(() {
        _myParticipationLoadingComplete = true;
        _myParticipation = dbMyParticipation.isNotEmpty;
        // _participatingAt = dbMyParticipation.isNotEmpty
        //     ? dbMyParticipation[0]["createdAt"]
        //     : 0;
      });
    }
  }

  // Future<int> _getUserScore() async {
  //   int startSeconds =
  //       convertStartDateStringToSeconds(widget.eventModel.startDate);
  //   int userStartSeconds =
  //       _participatingAt > startSeconds ? _participatingAt : startSeconds;

  //   int endSeconds = convertEndDateStringToSeconds(widget.eventModel.endDate);
  //   List<dynamic> userPoint = await ref.read(eventRepo).getEventUserScore(
  //       userStartSeconds,
  //       endSeconds,
  //       widget.eventModel.stepPoint,
  //       widget.eventModel.diaryPoint,
  //       widget.eventModel.commentPoint,
  //       widget.eventModel.likePoint);

  //   if (userPoint.isNotEmpty) {
  //     return userPoint[0]["totalPoint"];
  //   } else {
  //     return 0;
  //   }
  // }

  Future<void> _participateEvent() async {
    if (_myParticipation) return;

    int userAge = widget.userProfile.userAge != null
        ? int.parse(widget.userProfile.userAge!)
        : 0;
    bool userAgeCheck = stateEventModel.ageLimit != null
        ? userAge >= stateEventModel.ageLimit!
        : true;
    if (!userAgeCheck) {
      if (!mounted) return;
      showWarningSnackBar(context, "참여하실 수 없는 연령입니다");
      return;
    }

    final participantUpdateEventModel = stateEventModel.copyWith(
        participantsNumber: stateEventModel.participantsNumber != null
            ? stateEventModel.participantsNumber! + 1
            : 1);

    await ref.read(eventRepo).pariticipateEvent(
        widget.userProfile.userId, widget.eventModel.eventId);

    setState(() {
      stateEventModel = participantUpdateEventModel;
      _myParticipation = true;
    });

    // Future.delayed(const Duration(seconds: 1), () {
    //   Navigator.of(context).pop();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return EventDetailTemplate(
      completeScoreLoading: _completeScoreLoading,
      eventModel: stateEventModel,
      button: !_myParticipationLoadingComplete || !_completeScoreLoading
          ? const EventLoadingButton()
          : EventDefaultButton(
              eventFunction: stateEventModel.state == "종료"
                  ? null
                  : !_myParticipation
                      ? _participateEvent
                      : null,
              buttonColor: stateEventModel.state == "종료"
                  ? InjicareColor(context: context).gray70
                  : InjicareColor(context: context).primary50,
              text: stateEventModel.state == "종료"
                  ? "종료된 행사입니다"
                  : !_myParticipation
                      ? "참여하기"
                      : "참여 중입니다",
            ),
      userPointWidget: Column(
        children: [
          Text(
            "현재 나의 점수",
            style: InjicareFont().body01.copyWith(
                  fontWeight: FontWeight.w400,
                  color: InjicareColor(context: context).gray60,
                ),
          ),
          Gaps.v20,
          _myParticipation && _completeScoreLoading
              ? Text(
                  "${formatNumber(stateEventModel.userTotalPoint ?? 0)}점",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: Sizes.size36,
                    color: InjicareColor(context: context).gray100,
                  ),
                )
              : Text(
                  "0점",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: Sizes.size36,
                    color: InjicareColor(context: context).gray100,
                  ),
                ),
        ],
      ),
      pointMethodWidget: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EventHeader(
                headerText: "점수 계산 방법",
              ),
              if (widget.eventModel.stepPoint > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PointTile(
                      header: "걸음수 1000보",
                      point: widget.eventModel.stepPoint,
                    ),
                    DailyMaxTile(maxText: "${widget.eventModel.maxStepCount}보"),
                    Gaps.v4,
                  ],
                ),
              if (widget.eventModel.diaryPoint > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PointTile(
                        header: "일기 1회", point: widget.eventModel.diaryPoint),
                    const DailyMaxTile(maxText: "1회"),
                    Gaps.v4,
                  ],
                ),
              if (widget.eventModel.quizPoint > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PointTile(
                        header: "문제 풀기 1회", point: widget.eventModel.quizPoint),
                    const DailyMaxTile(maxText: "1회"),
                    Gaps.v4,
                  ],
                ),
              if (widget.eventModel.commentPoint > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PointTile(
                        header: "댓글 1회", point: widget.eventModel.commentPoint),
                    if ((widget.eventModel.maxCommentCount) > 0)
                      DailyMaxTile(
                          maxText: "${widget.eventModel.maxCommentCount}회"),
                    Gaps.v4,
                  ],
                ),
              if (widget.eventModel.likePoint > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PointTile(
                        header: "좋아요 1회", point: widget.eventModel.likePoint),
                    if ((widget.eventModel.maxLikeCount) > 0)
                      DailyMaxTile(
                          maxText: "${widget.eventModel.maxLikeCount}회"),
                    Gaps.v4,
                  ],
                ),
              if (widget.eventModel.invitationPoint > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PointTile(
                        header: "친구초대 1회",
                        point: widget.eventModel.invitationPoint),
                    if ((widget.eventModel.maxInvitationCount) > 0)
                      DailyMaxTile(
                          maxText: "${widget.eventModel.maxInvitationCount}회"),
                    Gaps.v4,
                  ],
                ),
            ],
          ),
        ],
      ),
      specialWidget: Container(),
    );
  }
}
