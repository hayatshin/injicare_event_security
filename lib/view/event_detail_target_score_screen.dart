import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:injicare_event/constants/gaps.dart';
import 'package:injicare_event/constants/sizes.dart';
import 'package:injicare_event/injicare_color.dart';
import 'package:injicare_event/injicare_font.dart';
import 'package:injicare_event/models/event_model.dart';
import 'package:injicare_event/models/user_profile.dart';
import 'package:injicare_event/repos/event_repo.dart';
import 'package:injicare_event/utils.dart';
import 'package:injicare_event/view/event_detail_multiple_scores_screen.dart';
import 'package:injicare_event/view_models/event_view_model.dart';
import 'package:injicare_event/widgets/event_detail_template.dart';
import 'package:lottie/lottie.dart';

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

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  Future<void> _getGift(Size size) async {
    final userGifts = await ref
        .read(eventRepo)
        .getEventUserNumbers(widget.eventModel.eventId);
    final achieverNumbers = stateEventModel.achieversNumber;
    bool canGetGift = userGifts < achieverNumbers;

    if (!mounted) return;
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor:
          isDarkMode(context) ? Colors.grey.shade900 : Colors.white,
      elevation: 0,
      context: context,
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: SizedBox(
            width: size.width,
            height: size.height * 0.7,
            child: !canGetGift
                ? const FirstComesFistServesEndWidget()
                : const GiftRequestWidget(),
          ),
        );
      },
    );

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
          ? Row(
              children: [
                Expanded(
                  child: SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                      height: 55,
                      borderRadius: BorderRadius.circular(
                        Sizes.size5,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : stateEventModel.state == "종료"
              ? Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: InjicareColor(context: context).gray50,
                    borderRadius: BorderRadius.circular(
                      Sizes.size5,
                    ),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "종료된 행사입니다",
                      style: InjicareFont().body01.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                )
              : !stateEventModel.userAchieveOrNot!
                  ? !_myParticipation
                      ? GestureDetector(
                          onTap: _participateEvent,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: InjicareColor().primary50,
                              borderRadius: BorderRadius.circular(
                                Sizes.size5,
                              ),
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "참여하기",
                                style: InjicareFont().body01.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: _participateEvent,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: InjicareColor(context: context).gray50,
                              borderRadius: BorderRadius.circular(
                                Sizes.size5,
                              ),
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "참여 중입니다",
                                style: InjicareFont().body01.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),
                        )
                  : _myApplyForGift
                      ? Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: InjicareColor(context: context).gray50,
                            borderRadius: BorderRadius.circular(
                              Sizes.size5,
                            ),
                            border: Border.all(
                              color: isDarkMode(context)
                                  ? Colors.white
                                  : Colors.black,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "선물 신청 완료!",
                                style: InjicareFont().body01.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: () async => await _getGift(size),
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: InjicareColor().primary50,
                              borderRadius: BorderRadius.circular(
                                Sizes.size5,
                              ),
                              border: Border.all(
                                color: isDarkMode(context)
                                    ? Colors.white
                                    : Colors.black,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "누르고",
                                  style: InjicareFont().body01.copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                                Gaps.h10,
                                Image.asset(
                                  "assets/jpg/gift.png",
                                  width: 40,
                                ),
                                Gaps.h10,
                                Text(
                                  "받기",
                                  style: InjicareFont().body01.copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  widget.eventModel.title,
                  softWrap: true,
                  style: InjicareFont().headline02,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          Gaps.v40,
          !_myParticipationLoadingComplete
              ? Container()
              : _myParticipation
                  ? !_completeScoreLoading
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SkeletonLine(
                                  style: SkeletonLineStyle(
                                    width: size.width * 0.5,
                                    height: 20,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Gaps.v32,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SkeletonAvatar(
                                  style: SkeletonAvatarStyle(
                                    shape: BoxShape.circle,
                                    width: size.width * 0.4,
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      : Stack(
                          children: [
                            if (stateEventModel.userAchieveOrNot ?? false)
                              SizedBox(
                                width: 500,
                                height: 200,
                                child: LottieBuilder.asset(
                                  "assets/anims/anim_fanfare.json",
                                ),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Text(
                                          "나의 행사 달성 상황",
                                          style: InjicareFont().body03.copyWith(
                                                color: InjicareColor(
                                                        context: context)
                                                    .gray80,
                                              ),
                                        ),
                                        Gaps.v5,
                                        Text(
                                          "→ ${stateEventModel.userTotalPoint}점",
                                          style: InjicareFont().body01.copyWith(
                                                color:
                                                    InjicareColor().primary50,
                                              ),
                                        ),
                                        // 달성 시
                                        Gaps.v20,
                                        if (stateEventModel.userAchieveOrNot ??
                                            false)
                                          Column(
                                            children: [
                                              Text(
                                                "달성했습니다!",
                                                textAlign: TextAlign.center,
                                                style: InjicareFont()
                                                    .body01
                                                    .copyWith(
                                                      color: InjicareColor(
                                                              context: context)
                                                          .secondary50,
                                                    ),
                                              ),
                                              Gaps.v20,
                                              Text(
                                                "아래 [누르고 선물 받기]\n버튼을 눌러서\n선물을 받아가세요",
                                                textAlign: TextAlign.center,
                                                style: InjicareFont()
                                                    .body07
                                                    .copyWith(
                                                      color: InjicareColor(
                                                              context: context)
                                                          .secondary50,
                                                    ),
                                              ),
                                              Gaps.v32,
                                            ],
                                          ),
                                        if (!stateEventModel.userAchieveOrNot!)
                                          Column(
                                            children: [
                                              MyProgressScreen(
                                                eventModel: widget.eventModel,
                                                userScore: stateEventModel
                                                    .userTotalPoint!,
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                  : UserPointLoadingWidget(
                      size: size,
                      eventModel: widget.eventModel,
                    ),
          Gaps.v24,
          Container(
            decoration: const BoxDecoration(),
            child: Image.network(
              widget.eventModel.eventImage,
              fit: BoxFit.cover,
            ),
          ),
          Gaps.v24,
          const EventHeader(headerText: "설명"),
          Row(
            children: [
              Flexible(
                child: Text(
                  widget.eventModel.description,
                  style: InjicareFont().body02,
                ),
              ),
            ],
          ),
          const DividerWidget(),
          const EventHeader(headerText: "행사 개요"),
          FutureBuilder(
            future: ref.read(eventRepo).convertContractRegionIdToName(
                widget.eventModel.contractRegionId ?? ""),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return EventInfoTile(
                    header: "주최 기관",
                    info: snapshot.data == "-" ? "인지케어" : "${snapshot.data}");
              } else if (snapshot.hasError) {
                // ignore: avoid_print
                print("name: ${snapshot.error}");
              }
              return Container();
            },
          ),
          Gaps.v10,
          EventInfoTile(
              header: "행사 진행일",
              info:
                  "${widget.eventModel.startDate} ~ ${widget.eventModel.endDate}"),
          Gaps.v10,
          EventInfoTile(header: "진행 상황", info: "${widget.eventModel.state}"),
          Gaps.v10,
          EventInfoTile(
              header: "목표 점수", info: "${widget.eventModel.targetScore}점"),
          Gaps.v10,
          EventInfoTile(
              header: "달성 인원",
              info: widget.eventModel.achieversNumber != 0
                  ? "${widget.eventModel.achieversNumber}명"
                  : "제한 없음"),
          Gaps.v10,
          EventInfoTile(
              header: "연령 제한",
              info: widget.eventModel.ageLimit != 0
                  ? "${widget.eventModel.ageLimit}세 이상"
                  : "제한 없음"),
          const DividerWidget(),
          Row(
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
                        DailyMaxTile(
                            maxText: "${widget.eventModel.maxStepCount}보"),
                        Gaps.v4,
                      ],
                    ),
                  if (widget.eventModel.diaryPoint > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PointTile(
                            header: "일기 1회",
                            point: widget.eventModel.diaryPoint),
                        const DailyMaxTile(maxText: "1회"),
                        Gaps.v4,
                      ],
                    ),
                  if (widget.eventModel.quizPoint > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PointTile(
                            header: "문제 풀기 1회",
                            point: widget.eventModel.quizPoint),
                        const DailyMaxTile(maxText: "1회"),
                        Gaps.v4,
                      ],
                    ),
                  if (widget.eventModel.commentPoint > 0)
                    PointTile(
                        header: "댓글 1회", point: widget.eventModel.commentPoint),
                  if (widget.eventModel.likePoint > 0)
                    PointTile(
                        header: "좋아요 1회", point: widget.eventModel.likePoint),
                  if (widget.eventModel.invitationPoint > 0)
                    PointTile(
                        header: "친구초대 1회",
                        point: widget.eventModel.invitationPoint),
                ],
              ),
            ],
          ),
        ],
      ),
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
