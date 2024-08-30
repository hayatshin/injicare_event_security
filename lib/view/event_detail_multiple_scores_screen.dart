import 'dart:math';

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
import 'package:injicare_event/view_models/event_view_model.dart';
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
              : !_myParticipation
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
          _myParticipation
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
                        Gaps.v10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                          ],
                        )
                      ],
                    )
                  : Stack(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.4),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Text(
                                        "행사 기준 내 점수",
                                        style: InjicareFont().body03.copyWith(
                                              color: InjicareColor(
                                                      context: context)
                                                  .gray80,
                                            ),
                                      ),
                                      Gaps.v5,
                                      Text(
                                        "→ ${stateEventModel.userTotalPoint}점",
                                        style: InjicareFont().body02.copyWith(
                                              color: InjicareColor().primary50,
                                            ),
                                      ),
                                      // 달성 시
                                      Gaps.v20,
                                    ],
                                  ),
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
          const EventHeader(
            headerText: "설명",
          ),
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
          const EventHeader(
            headerText: "행사 개요",
          ),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PointTile(
                            header: "댓글 1회",
                            point: widget.eventModel.commentPoint),
                        if ((widget.eventModel.maxCommentCount ?? 0) > 0)
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
                            header: "좋아요 1회",
                            point: widget.eventModel.likePoint),
                        if ((widget.eventModel.maxLikeCount ?? 0) > 0)
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
                        if ((widget.eventModel.maxInvitationCount ?? 0) > 0)
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
          Gaps.v24,
          Container(
            decoration: const BoxDecoration(),
            child: Image.network(
              widget.eventModel.eventImage,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class EventHeader extends StatelessWidget {
  final String headerText;
  const EventHeader({
    super.key,
    required this.headerText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: InjicareColor(context: context)
                    .secondary20
                    .withOpacity(0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                child: Text(
                  headerText,
                  style: InjicareFont().body04.copyWith(
                        color: InjicareColor(context: context).gray80,
                      ),
                ),
              ),
            ),
          ],
        ),
        Gaps.v20,
      ],
    );
  }
}

class MyProgressScreen extends ConsumerStatefulWidget {
  final EventModel eventModel;
  final int userScore;
  const MyProgressScreen({
    super.key,
    required this.eventModel,
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
    curve: Curves.bounceOut,
  );

  late Animation<double> _progress = Tween(
    begin: 0.005,
    end: 1.0,
  ).animate(_curve);

  Future<void> _setProgressValues() async {
    int targetPoint = widget.eventModel.targetScore;

    if (mounted) {
      setState(() {
        _progress = Tween(
          begin: 0.0,
          end: (widget.userScore / targetPoint) < 1
              ? (widget.userScore / targetPoint)
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
              size: Size(size.width * 0.5, size.width * 0.3),
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
    final radius = size.width / 5;
    const startingAngle = -0.5 * pi;

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    // circle
    final backCirclePaint = Paint()
      ..color = Theme.of(context).primaryColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawCircle(center, radius, backCirclePaint);

    final redArcPaint = Paint()
      ..color = Theme.of(context).primaryColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20;

    // progress
    final progressArcRect = Rect.fromCircle(
      center: center,
      radius: radius,
    );
    canvas.drawArc(
        progressArcRect, startingAngle, progress * pi, false, redArcPaint);
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
      ],
    );
  }
}

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gaps.v32,
        Container(
          height: 1.2,
          decoration: BoxDecoration(
            color: InjicareColor(context: context).gray20,
          ),
        ),
        Gaps.v24,
      ],
    );
  }
}

class EventInfoTile extends StatelessWidget {
  final String header;
  final String info;
  const EventInfoTile({
    super.key,
    required this.header,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: RichText(
            softWrap: true,
            text: TextSpan(
              text: "▪︎ $header:  ",
              style: InjicareFont().body01.copyWith(
                    color: isDarkMode(context) ? Colors.white : Colors.black,
                  ),
              children: [
                TextSpan(
                  text: info,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PointTile extends StatelessWidget {
  final String header;
  final int point;
  const PointTile({
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
                  fontWeight: FontWeight.w400,
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                ),
            children: <TextSpan>[
              TextSpan(
                text: "$point점",
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

class DailyMaxTile extends StatelessWidget {
  final String maxText;
  const DailyMaxTile({
    super.key,
    required this.maxText,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "     - 하루 최대 $maxText",
      style: InjicareFont().body07.copyWith(
            color: InjicareColor(context: context).gray60,
          ),
    );
  }
}
