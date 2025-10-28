import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:injicare_event_security/constants/gaps.dart';
import 'package:injicare_event_security/injicare_color.dart';
import 'package:injicare_event_security/injicare_font.dart';
import 'package:injicare_event_security/models/event_model.dart';
import 'package:injicare_event_security/models/quiz_answer_model.dart';
import 'package:injicare_event_security/models/user_profile.dart';
import 'package:injicare_event_security/repos/event_repo.dart';
import 'package:injicare_event_security/utils.dart';
import 'package:injicare_event_security/view_models/event_view_model.dart';
import 'package:injicare_event_security/widgets/answer_card.dart';
import 'package:injicare_event_security/widgets/button_widgets.dart';
import 'package:injicare_event_security/widgets/desc_tile_widgets.dart';
import 'package:injicare_event_security/widgets/event_detail_template.dart';

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
  bool _submitQuizEvent = false;
  final lastParticipantKey = ValueNotifier<GlobalKey?>(null);

  @override
  void initState() {
    super.initState();

    _initializeUserEventInfo();
    _initializeMyParticipation();
  }

  @override
  void dispose() {
    // _answerController.dispose();
    lastParticipantKey.dispose();
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

  void _scrollToLastParticipantBottom() {
    if (lastParticipantKey.value != null &&
        lastParticipantKey.value!.currentContext != null) {
      Scrollable.ensureVisible(
        lastParticipantKey.value!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }
  }

  Future<void> _participateEvent() async {
    if (_myParticipation) return;

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

    setState(() {
      _submitQuizEvent = true;
    });

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
      _answerList.add(answerModel);
      stateEventModel = participantUpdateEventModel;
      _myParticipation = true;
    });
    _scrollToLastParticipantBottom();
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
    return GestureDetector(
      onTap: () {
        closeKeyboard(context);
      },
      child: EventDetailTemplate(
        completeScoreLoading: _completeScoreLoading,
        eventModel: stateEventModel,
        button: !_myParticipationLoadingComplete || !_completeScoreLoading
            ? const EventLoadingButton()
            : EventDefaultButton(
                eventFunction: stateEventModel.state == "종료"
                    ? null
                    : !_myParticipation && !_submitQuizEvent
                        ? _participateEvent
                        : null,
                text: stateEventModel.state == "종료"
                    ? "종료된 행사입니다"
                    : !_myParticipation && !_submitQuizEvent
                        ? "답 제출하기"
                        : "이미 참여했습니다",
                buttonColor: stateEventModel.state == "종료"
                    ? InjicareColor(context: context).gray70
                    : !_myParticipation && !_submitQuizEvent
                        ? InjicareColor(context: context).primary50
                        : InjicareColor(context: context).gray70,
              ),
        userPointWidget: Container(),
        pointMethodWidget: Container(),
        specialWidget: Column(
          children: [
            // 참여
            !_myParticipationLoadingComplete
                ? Container()
                : !_myParticipation
                    ? Column(
                        children: [
                          const EventHeader(
                            headerText: "문제",
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: InjicareColor(context: context)
                                  .primary50
                                  .withOpacity(0.05),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
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
                        ],
                      )
                    : Column(
                        children: [
                          const EventHeader(
                            headerText: "정답자 목록",
                          ),
                          CustomScrollView(
                            shrinkWrap: true,
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final dataKey = GlobalKey();
                                    if (index == _answerList.length - 1) {
                                      lastParticipantKey.value = dataKey;
                                    }
                                    return AnswerCard(
                                      key: dataKey,
                                      index: index + 1,
                                      quizAnswerModel: _answerList[index],
                                    );
                                  },
                                  childCount: _answerList.length,
                                ),
                              )
                            ],
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
