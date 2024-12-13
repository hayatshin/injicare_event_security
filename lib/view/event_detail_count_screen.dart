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
import 'package:injicare_event/view/event_detail_target_score_screen.dart';
import 'package:injicare_event/view_models/event_view_model.dart';
import 'package:injicare_event/widgets/event_detail_template.dart';
import 'package:lottie/lottie.dart';

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
                                style: InjicareFont().body04.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),
                        )
                      : Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SkeletonLine(
                                  style: SkeletonLineStyle(
                                    width: size.width * 0.4,
                                    height: 25,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                                SkeletonLine(
                                  style: SkeletonLineStyle(
                                    width: size.width * 0.2,
                                    height: 25,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
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
                                        Gaps.v20,
                                        // 달성 시
                                        if (stateEventModel.userAchieveOrNot ??
                                            false)
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  SizedBox(
                                                    child: LottieBuilder.asset(
                                                      "assets/anims/congratulation.json",
                                                      width: 40,
                                                    ),
                                                  ),
                                                  Gaps.h5,
                                                  Text(
                                                    "달성했습니다!",
                                                    textAlign: TextAlign.center,
                                                    style: InjicareFont()
                                                        .body01
                                                        .copyWith(
                                                          color: InjicareColor(
                                                                  context:
                                                                      context)
                                                              .secondary50,
                                                        ),
                                                  ),
                                                ],
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
                                        if (widget.eventModel.diaryCount > 0)
                                          EachCountProgressWidget(
                                            eachText: "일기",
                                            userCount: stateEventModel
                                                    .userDiaryCount ??
                                                0,
                                            eventCount:
                                                stateEventModel.diaryCount,
                                          ),
                                        if (widget.eventModel.quizCount > 0)
                                          EachCountProgressWidget(
                                            eachText: "문제 풀기",
                                            userCount:
                                                stateEventModel.userQuizCount ??
                                                    0,
                                            eventCount:
                                                stateEventModel.quizCount,
                                          ),
                                        if (widget.eventModel.commentCount > 0)
                                          EachCountProgressWidget(
                                            eachText: "댓글",
                                            userCount: stateEventModel
                                                    .userCommentCount ??
                                                0,
                                            eventCount:
                                                stateEventModel.commentCount,
                                          ),
                                        if (widget.eventModel.likeCount > 0)
                                          EachCountProgressWidget(
                                            eachText: "좋아요",
                                            userCount:
                                                stateEventModel.userLikeCount ??
                                                    0,
                                            eventCount:
                                                stateEventModel.likeCount,
                                          ),
                                        if (widget.eventModel.invitationCount >
                                            0)
                                          EachCountProgressWidget(
                                            eachText: "친구 초대",
                                            userCount: stateEventModel
                                                    .userInvitationCount ??
                                                0,
                                            eventCount:
                                                stateEventModel.invitationCount,
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
                            header: "문제 풀기",
                            point: widget.eventModel.quizCount),
                        const DailyMaxTile(maxText: "1회"),
                        Gaps.v4,
                      ],
                    ),
                  if (widget.eventModel.commentCount > 0)
                    Column(
                      children: [
                        CountTile(
                            header: "댓글",
                            point: widget.eventModel.commentCount),
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
                              maxText:
                                  "${widget.eventModel.maxInvitationCount}회"),
                        Gaps.v4,
                      ],
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "▪︎  $eachText",
          style: InjicareFont().body01.copyWith(
                color: InjicareColor(context: context).gray100,
              ),
        ),
        Gaps.v10,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyProgressScreen(
              totalScore: eventCount,
              userScore: userCount,
            ),
            Flexible(
              child: RichText(
                text: TextSpan(
                  text: "$userCount회",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: Sizes.size36,
                    color: InjicareColor(context: context).primary50,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: " / $eventCount회",
                        style: TextStyle(
                          color: InjicareColor(context: context).gray100,
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

class LoadingProgressScreen extends StatefulWidget {
  const LoadingProgressScreen({super.key});

  @override
  State<LoadingProgressScreen> createState() => _LoadingProgressScreenState();
}

class _LoadingProgressScreenState extends State<LoadingProgressScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _animationController,
    curve: Curves.linear,
  );

  late Animation<double> _progress = Tween(
    begin: 0.000,
    end: 1.0,
  ).animate(_curve);

  Future<void> _setProgressValues() async {
    // int targetPoint = widget.eventModel.targetScore;

    if (mounted) {
      setState(() {
        _progress = Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(_curve);
      });
    }

    _animationController.repeat(
      reverse: true,
    );
  }

  @override
  void initState() {
    super.initState();

    _setProgressValues();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _progress,
          builder: (context, child) {
            return CustomPaint(
              painter: MyProgressPainter(
                  progress: _progress.value, context: context),
              size: Size(size.width, size.width * 0.12),
            );
          },
        ),
      ],
    );
  }
}

class MyProgressScreen extends ConsumerStatefulWidget {
  // final EventModel eventModel;
  final int totalScore;
  final int userScore;
  const MyProgressScreen({
    super.key,
    // required this.eventModel,
    required this.totalScore,
    required this.userScore,
  });

  @override
  ConsumerState<MyProgressScreen> createState() => _MyProgressScreenState();
}

class _MyProgressScreenState extends ConsumerState<MyProgressScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..forward();

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _animationController,
    curve: Curves.linear,
  );

  late Animation<double> _progress = Tween(
    begin: 0.005,
    end: 1.0,
  ).animate(_curve);

  Future<void> _setProgressValues() async {
    // int targetPoint = widget.eventModel.targetScore;

    if (mounted) {
      setState(() {
        _progress = Tween(
          begin: 0.0,
          end: (widget.userScore / widget.totalScore) < 1
              ? (widget.userScore / widget.totalScore)
              : 1.0,
        ).animate(_curve);
      });
    }

    _animationController.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();

    _setProgressValues();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progress,
          builder: (context, child) {
            return CustomPaint(
              painter: MyProgressPainter(
                  progress: _progress.value, context: context),
              size: Size(size.width * 0.3, 20),
            );
          },
        ),
      ],
    );
  }
}

class MyProgressPainter extends CustomPainter {
  final BuildContext context;
  final double progress;

  MyProgressPainter({
    required this.context,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // final radius = size.width / 5;
    // const startingAngle = -0.5 * pi;

    // circle
    final backCirclePaint = Paint()
      ..color = Theme.of(context).primaryColor.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..strokeWidth = 20;

    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, 20), const Radius.circular(20));
    canvas.drawRRect(rrect, backCirclePaint);

    final redArcPaint = Paint()
      ..color = Theme.of(context).primaryColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20;

    // progress
    // final progressArcRect = Rect.fromCircle(
    //   center: center,
    //   radius: radius,
    // );
    // canvas.drawArc(
    //     progressArcRect, startingAngle, progress * pi, false, redArcPaint);

    final redRrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width * progress, 20),
        const Radius.circular(20));
    canvas.drawRRect(redRrect, redArcPaint);
  }

  @override
  bool shouldRepaint(covariant MyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class UserPointLoadingWidget extends StatefulWidget {
  final Size size;
  final EventModel eventModel;
  const UserPointLoadingWidget({
    super.key,
    required this.size,
    required this.eventModel,
  });

  @override
  State<UserPointLoadingWidget> createState() => _UserPointLoadingWidgetState();
}

class _UserPointLoadingWidgetState extends State<UserPointLoadingWidget> {
  // bool _completeLoading = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        completeLoading.value = true;
      }
    });
  }

  final completeLoading = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "행사 기준 내 점수",
          style: InjicareFont().body03.copyWith(
                color: InjicareColor(context: context).gray80,
              ),
        ),
        Gaps.v5,
        Text(
          "→ 참여 후 계산됩니다",
          style: InjicareFont().body02.copyWith(
                color: InjicareColor().primary50,
              ),
        ),
        Gaps.v20,
        const LoadingProgressScreen(),
        // ValueListenableBuilder(
        //   valueListenable: completeLoading,
        //   builder: (context, value, child) {
        //     if (value) {
        //       return MyProgressScreen(
        //         eventModel: widget.eventModel,
        //         userScore: 0,
        //       );
        //     }
        //   },
        // ),
      ],
    );
  }
}

class CountTile extends StatelessWidget {
  final String header;
  final int point;
  const CountTile({
    super.key,
    required this.header,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            text: "▪︎ $header  →  ",
            style: InjicareFont().body01.copyWith(
                  color: InjicareColor(context: context).gray100,
                ),
            children: <TextSpan>[
              TextSpan(
                text: "$point회",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Gaps.v5,
      ],
    );
  }
}
