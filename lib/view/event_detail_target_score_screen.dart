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
import 'package:injicare_event/widgets/progress/linear_progress_widget.dart';

class EventDetailTargetScoreScreen extends ConsumerStatefulWidget {
  final EventModel eventModel;
  final UserProfile userProfile;

  const EventDetailTargetScoreScreen({
    super.key,
    required this.eventModel,
    required this.userProfile,
  });

  @override
  ConsumerState<EventDetailTargetScoreScreen> createState() =>
      _EventDetailPointScreenState();
}

class _EventDetailPointScreenState
    extends ConsumerState<EventDetailTargetScoreScreen> {
  bool _myParticipationLoadingComplete = false;
  bool _myParticipation = true;

  bool _myApplyForGiftLoadingComplete = false;
  bool _myApplyForGift = false;
  // int _participatingAt = 0;
  EventModel stateEventModel = EventModel.empty();
  bool _completeScoreLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUserScore();
    _initializeMyParticipation();
    _initializeMyApplyingForGift();
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
      });
    }
  }

  Future<void> _initializeMyApplyingForGift() async {
    bool myApplyForGift = await ref.read(eventRepo).userSubmitEventGiftOrNot(
        widget.userProfile.userId, widget.eventModel.eventId);

    if (mounted) {
      setState(() {
        _myApplyForGiftLoadingComplete = true;
        _myApplyForGift = myApplyForGift;
      });
    }
  }

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
  }

  Future<void> _getGift(Size size) async {
    final userGifts = await ref
        .read(eventRepo)
        .getEventUserNumbers(widget.eventModel.eventId);
    final achieverNumbers = stateEventModel.achieversNumber;
    bool canGetGift = achieverNumbers == 0 ? true : userGifts < achieverNumbers;

    if (!mounted) return;

    !canGetGift
        ? showWarningSnackBar(context, "선착순이 마감되었습니다")
        : showCompletingSnackBar(context, "선물 신청이 완료되었어요");

    if (canGetGift) {
      await ref.read(eventRepo).submitEventGift(
          widget.userProfile.userId, widget.eventModel.eventId);

      setState(() {
        _myApplyForGift = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return EventDetailTemplate(
      completeScoreLoading: _completeScoreLoading,
      eventModel: stateEventModel,
      button: !_myParticipationLoadingComplete ||
              !_myApplyForGiftLoadingComplete ||
              !_completeScoreLoading
          ? const EventLoadingButton()
          : EventDefaultButton(
              eventFunction: stateEventModel.state == "종료"
                  ? null
                  : !stateEventModel.userAchieveOrNot!
                      ? !_myParticipation
                          ? _participateEvent
                          : null
                      : _myApplyForGift
                          ? null
                          : () => _getGift(size),
              buttonColor: stateEventModel.state == "종료"
                  ? InjicareColor(context: context).gray70
                  : !stateEventModel.userAchieveOrNot!
                      ? !_myParticipation
                          ? InjicareColor(context: context).primary50
                          : InjicareColor(context: context).gray70
                      : _myApplyForGift
                          ? InjicareColor(context: context).gray70
                          : InjicareColor(context: context).primary50,
              text: stateEventModel.state == "종료"
                  ? "종료된 행사입니다"
                  : !stateEventModel.userAchieveOrNot!
                      ? !_myParticipation
                          ? "참여하기"
                          : "참여 중입니다"
                      : _myApplyForGift
                          ? "선물 신청 완료"
                          : "선물 받기",
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
          _myParticipationLoadingComplete &&
                  _myParticipation &&
                  _completeScoreLoading
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
          Gaps.v10,
          LinearProgressWidget(
            totalScore: stateEventModel.targetScore,
            userScore: stateEventModel.userTotalPoint ?? 1,
            width: size.width * 0.8,
          )
        ],
      ),
      pointMethodWidget: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EventHeader(headerText: "점수 계산 방법"),
              if (widget.eventModel.stepPoint > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PointTile(
                      header: "걸음수 1000보",
                      point: widget.eventModel.stepPoint,
                    ),
                    DailyMaxTile(maxText: "${widget.eventModel.maxStepCount}보"),
                    Gaps.v8,
                  ],
                ),
              if (widget.eventModel.diaryPoint > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PointTile(
                        header: "일기 1회", point: widget.eventModel.diaryPoint),
                    const DailyMaxTile(maxText: "1회"),
                    Gaps.v8,
                  ],
                ),
              if (widget.eventModel.quizPoint > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PointTile(
                        header: "문제 풀기 1회", point: widget.eventModel.quizPoint),
                    const DailyMaxTile(maxText: "1회"),
                    Gaps.v8,
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
                    Gaps.v8,
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
                    Gaps.v8,
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
                    Gaps.v8,
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

class FirstComesFistServesEndWidget extends StatelessWidget {
  const FirstComesFistServesEndWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Gaps.v20,
        SizedBox(
          width: 150,
          child: Image.asset(
            "assets/jpg/girl_fail.png",
            fit: BoxFit.cover,
          ),
        ),
        Gaps.v32,
        Text(
          "선착순이 마감되었습니다.\n다음에 다시 도전해보아요!",
          textAlign: TextAlign.center,
          style: InjicareFont().headline03,
        )
      ],
    );
  }
}

class GiftRequestWidget extends StatelessWidget {
  const GiftRequestWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Gaps.v20,
        SizedBox(
          width: 150,
          child: Image.asset(
            "assets/jpg/girl_success.png",
            fit: BoxFit.cover,
          ),
        ),
        Gaps.v32,
        Text(
          "선물 신청이 완료되었습니다~!",
          textAlign: TextAlign.center,
          style: InjicareFont().headline03,
        )
      ],
    );
  }
}
