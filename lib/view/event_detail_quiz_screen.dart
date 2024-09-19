import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:injicare_event/constants/gaps.dart';
import 'package:injicare_event/constants/sizes.dart';
import 'package:injicare_event/injicare_color.dart';
import 'package:injicare_event/injicare_font.dart';
import 'package:injicare_event/models/event_model.dart';
import 'package:injicare_event/models/quiz_answer_model.dart';
import 'package:injicare_event/models/user_profile.dart';
import 'package:injicare_event/repos/event_repo.dart';
import 'package:injicare_event/utils.dart';
import 'package:injicare_event/view/event_detail_multiple_scores_screen.dart';
import 'package:injicare_event/view_models/event_view_model.dart';
import 'package:injicare_event/widgets/answer_card.dart';
import 'package:injicare_event/widgets/event_detail_template.dart';

class EventDetailQuizScreen extends ConsumerStatefulWidget {
  final EventModel eventModel;
  final UserProfile userProfile;

  const EventDetailQuizScreen({
    super.key,
    required this.eventModel,
    required this.userProfile,
  });

  @override
  ConsumerState<EventDetailQuizScreen> createState() =>
      _EventDetailPointScreenState();
}

class _EventDetailPointScreenState
    extends ConsumerState<EventDetailQuizScreen> {
  bool _myParticipationLoadingComplete = false;
  bool _myParticipation = true;

  EventModel stateEventModel = EventModel.empty();
  // final TextEditingController _answerController = TextEditingController();
  List<QuizAnswerModel> _answerList = [];
  bool _completeScoreLoading = false;
  int _selectedMultipleChoice = 0;

  @override
  void initState() {
    super.initState();

    _initializeUserEventInfo();
    _initializeMyParticipation();
  }

  @override
  void dispose() {
    // _answerController.dispose();
    super.dispose();
  }

  Future<void> _initializeUserEventInfo() async {
    final updateScoreModel = await ref
        .read(eventProvider.notifier)
        .updateUserQuizState(widget.eventModel);
    setState(() {
      _completeScoreLoading = true;
      stateEventModel = updateScoreModel;
    });
  }

  Future<void> _initializeMyParticipation() async {
    List<Map<String, dynamic>> dbMyParticipation = await ref
        .read(eventRepo)
        .checkMyParticiapationQuizEvent(
            widget.eventModel.eventId, widget.userProfile.userId);

    // 참여 중일 경우 answers 가져오기
    final answerList = await ref
        .read(eventProvider.notifier)
        .fetchCertainQuizEventAnswers(widget.eventModel.eventId);
    final correctAnswerList = answerList
        .where((a) => a.answer == widget.eventModel.quizAnswer)
        .toList();

    if (mounted) {
      setState(() {
        _myParticipationLoadingComplete = true;
        _myParticipation = dbMyParticipation.isNotEmpty;
        _answerList = correctAnswerList;
      });
    }
  }

  Future<void> _participateEvent() async {
    int startSeconds =
        convertStartDateStringToSeconds(widget.eventModel.startDate);
    int currentSeconds = getCurrentSeconds();
    if (currentSeconds < startSeconds) {
      showWarningSnackBar(context, "행사가 아직 시작하지 않았습니다");
      return;
    }
    if (_selectedMultipleChoice == 0) {
      showWarningSnackBar(context, "정답을 선택해주세요");
      return;
    }

    int userAge = widget.userProfile.userAge != null
        ? int.parse(widget.userProfile.userAge!)
        : 0;
    bool userAgeCheck = stateEventModel.ageLimit != null
        ? userAge >= stateEventModel.ageLimit!
        : true;

    if (!userAgeCheck) {
      showWarningSnackBar(context, "참여하실 수 없는 연령입니다");
      return;
    }

    final participantUpdateEventModel = stateEventModel.copyWith(
        participantsNumber: stateEventModel.participantsNumber != null
            ? stateEventModel.participantsNumber! + 1
            : 1);

    // await ref.read(eventRepo).pariticipateEvent(
    //     widget.userProfile.userId, widget.eventModel.eventId);

    // 답변 추가
    final answerModel = QuizAnswerModel(
      userId: widget.userProfile.userId,
      eventId: stateEventModel.eventId,
      quizEventId: stateEventModel.quizEventId,
      answer: _selectedMultipleChoice,
      createdAt: getCurrentSeconds(),
      userName: widget.userProfile.name,
    );

    await ref.read(eventRepo).saveQuizEventAnswer(answerModel);

    setState(() {
      _answerList.insert(0, answerModel);
      stateEventModel = participantUpdateEventModel;
      _myParticipation = true;
    });

    // Future.delayed(const Duration(seconds: 1), () {
    //   Navigator.of(context).pop();
    // });
  }

  void _onTapMultipleChoice(int i) {
    setState(() {
      _selectedMultipleChoice = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        closeKeyboard(context);
      },
      child: EventDetailTemplate(
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
                            color: InjicareColor(context: context).primary50,
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
                              "답 제출하고 참여하기",
                              style: InjicareFont().body01.copyWith(
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

            // 참여
            !_myParticipationLoadingComplete
                ? Container()
                : !_myParticipation
                    ? Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(),
                            child: Image.network(
                              widget.eventModel.eventImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Gaps.v24,
                          const EventHeader(
                            headerText: "문제",
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: InjicareColor(context: context).gray10,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.eventModel.quiz ?? "",
                                        softWrap: true,
                                        style:
                                            InjicareFont().headline02.copyWith(
                                                  color: InjicareColor(
                                                          context: context)
                                                      .gray100,
                                                ),
                                        overflow: TextOverflow.visible,
                                      ),
                                      Gaps.v32,
                                      for (int i = 1; i <= 4; i++)
                                        EventMultipleChoiceWidget(
                                          multipleChoice: i,
                                          quiz: i == 1
                                              ? widget.eventModel.firstChoice
                                              : i == 2
                                                  ? widget
                                                      .eventModel.secondChoice
                                                  : i == 3
                                                      ? widget.eventModel
                                                          .thirdChoice
                                                      : i == 4
                                                          ? widget.eventModel
                                                              .fourthChoice
                                                          : widget.eventModel
                                                              .firstChoice,
                                          selected:
                                              _selectedMultipleChoice == i,
                                          onTapMultipleChoice: () =>
                                              _onTapMultipleChoice(i),
                                        ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          const DividerWidget(),
                          const EventHeader(
                            headerText: "설명",
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                            future: ref
                                .read(eventRepo)
                                .convertContractRegionIdToName(
                                    widget.eventModel.contractRegionId ?? ""),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return EventInfoTile(
                                    header: "주최 기관",
                                    info: snapshot.data == "-"
                                        ? "인지케어"
                                        : "${snapshot.data}");
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
                          EventInfoTile(
                              header: "진행 상황",
                              info: "${widget.eventModel.state}"),
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
                          Gaps.v20,
                        ],
                      )
                    : Column(
                        children: [
                          const EventHeader(
                            headerText: "정답자 목록",
                          ),
                          for (int i = 0; i < _answerList.length; i++)
                            AnswerCard(
                              index: i + 1,
                              quizAnswerModel: _answerList[i],
                            ),
                        ],
                      ),
          ],
        ),
      ),
    );
  }
}

class EventMultipleChoiceWidget extends StatelessWidget {
  final int multipleChoice;
  final String? quiz;
  final bool selected;
  final Function() onTapMultipleChoice;
  const EventMultipleChoiceWidget(
      {super.key,
      required this.multipleChoice,
      required this.quiz,
      required this.selected,
      required this.onTapMultipleChoice});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onTapMultipleChoice,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  selected
                      ? InjicareColor(context: context).secondary50
                      : InjicareColor(context: context).gray50,
                  BlendMode.srcIn,
                ),
                child: SvgPicture.asset(
                  "assets/number/circle-$multipleChoice.svg",
                  width: 40,
                ),
              ),
            ),
            Gaps.h16,
            Flexible(
              child: Text(
                quiz ?? "",
                style: InjicareFont().headline03.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
        Gaps.v10,
      ],
    );
  }
}
