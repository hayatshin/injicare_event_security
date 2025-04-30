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

class EventDetailCountScreen extends ConsumerStatefulWidget {
  final EventModel eventModel;
  final UserProfile userProfile;

  const EventDetailCountScreen({
    super.key,
    required this.eventModel,
    required this.userProfile,
  });

  @override
  ConsumerState<EventDetailCountScreen> createState() =>
      _EventDetailCountScreenState();
}

class _EventDetailCountScreenState
    extends ConsumerState<EventDetailCountScreen> {
  bool _myParticipationLoadingComplete = false;
  bool _myParticipation = false;

  bool _myApplyForGiftLoadingComplete = false;
  bool _myApplyForGift = false;
  EventModel stateEventModel = EventModel.empty();
  bool _completeScoreLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUserScore();
    _initializeMyParticipation();
    _initializeMyApplyingForGift();
    // _initializeScore();
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

  // Future<void> _initializeScore() async {
  //   int startSeconds =
  //       convertStartDateStringToSeconds(widget.eventModel.startDate);
  //   int userStartSeconds =
  //       _participatingAt > startSeconds ? _participatingAt : startSeconds;

  //   int endSeconds = convertEndDateStringToSeconds(widget.eventModel.endDate);
  //   setState(() {
  //     _userStartSeconds = userStartSeconds;
  //     _userEndSeconds = endSeconds;
  //   });
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
          if (_myParticipation)
            Column(
              children: [
                Text(
                  "현재 나의 달성",
                  style: InjicareFont().body01.copyWith(
                        fontWeight: FontWeight.w400,
                        color: InjicareColor(context: context).gray60,
                      ),
                ),
                Gaps.v20,
              ],
            ),
          _myParticipationLoadingComplete &&
                  _myParticipation &&
                  _completeScoreLoading
              ? Column(
                  children: [
                    if (widget.eventModel.diaryCount > 0)
                      EachCountProgressWidget(
                        eachText: "일기",
                        userCount: stateEventModel.userDiaryCount ?? 0,
                        eventCount: stateEventModel.diaryCount,
                      ),
                    if (widget.eventModel.quizCount > 0)
                      EachCountProgressWidget(
                        eachText: "문제 풀기",
                        userCount: stateEventModel.userQuizCount ?? 0,
                        eventCount: stateEventModel.quizCount,
                      ),
                    if (widget.eventModel.commentCount > 0)
                      EachCountProgressWidget(
                        eachText: "댓글",
                        userCount: stateEventModel.userCommentCount ?? 0,
                        eventCount: stateEventModel.commentCount,
                      ),
                    if (widget.eventModel.likeCount > 0)
                      EachCountProgressWidget(
                        eachText: "좋아요",
                        userCount: stateEventModel.userLikeCount ?? 0,
                        eventCount: stateEventModel.likeCount,
                      ),
                    if (widget.eventModel.invitationCount > 0)
                      EachCountProgressWidget(
                        eachText: "친구 초대",
                        userCount: stateEventModel.userInvitationCount ?? 0,
                        eventCount: stateEventModel.invitationCount,
                      ),
                  ],
                )
              : Container(),
        ],
      ),
      pointMethodWidget: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EventHeader(headerText: "계산 방법"),
              if (widget.eventModel.diaryCount > 0)
                Column(
                  children: [
                    CountTile(
                        header: "일기", point: widget.eventModel.diaryCount),
                    const DailyMaxTile(maxText: "1회"),
                    Gaps.v4,
                  ],
                ),
              if (widget.eventModel.quizCount > 0)
                Column(
                  children: [
                    CountTile(
                        header: "문제 풀기", point: widget.eventModel.quizCount),
                    const DailyMaxTile(maxText: "1회"),
                    Gaps.v4,
                  ],
                ),
              if (widget.eventModel.commentCount > 0)
                Column(
                  children: [
                    CountTile(
                        header: "댓글", point: widget.eventModel.commentCount),
                    if ((widget.eventModel.maxCommentCount) > 0)
                      DailyMaxTile(
                          maxText: "${widget.eventModel.maxCommentCount}회"),
                    Gaps.v4,
                  ],
                ),
              if (widget.eventModel.likeCount > 0)
                Column(
                  children: [
                    CountTile(
                        header: "좋아요", point: widget.eventModel.likeCount),
                    if ((widget.eventModel.maxLikeCount) > 0)
                      DailyMaxTile(
                          maxText: "${widget.eventModel.maxLikeCount}회"),
                    Gaps.v4,
                  ],
                ),
              if (widget.eventModel.invitationCount > 0)
                Column(
                  children: [
                    CountTile(
                        header: "친구초대",
                        point: widget.eventModel.invitationCount),
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

class EachCountProgressWidget extends StatelessWidget {
  final String eachText;
  final int userCount;
  final int eventCount;
  const EachCountProgressWidget({
    super.key,
    required this.eachText,
    required this.userCount,
    required this.eventCount,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eachText,
          style: InjicareFont().body01.copyWith(
                color: InjicareColor(context: context).gray80,
              ),
        ),
        Gaps.v2,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            LinearProgressWidget(
              totalScore: eventCount,
              userScore: userCount,
              width: size.width * 0.4,
            ),
            Flexible(
              child: RichText(
                text: TextSpan(
                  text: "$userCount회",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: Sizes.size28,
                    color: InjicareColor(context: context).gray100,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: " / $eventCount회",
                        style: TextStyle(
                          color: InjicareColor(context: context).gray60,
                        )),
                  ],
                ),
              ),
            )
          ],
        ),
        Gaps.v10,
      ],
    );
  }
}
