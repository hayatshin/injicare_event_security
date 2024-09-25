import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injicare_event/constants/gaps.dart';
import 'package:injicare_event/constants/sizes.dart';
import 'package:injicare_event/injicare_color.dart';
import 'package:injicare_event/injicare_font.dart';
import 'package:injicare_event/models/event_model.dart';
import 'package:injicare_event/models/photo_image_model.dart';
import 'package:injicare_event/models/user_profile.dart';
import 'package:injicare_event/repos/event_repo.dart';
import 'package:injicare_event/utils.dart';
import 'package:injicare_event/view/event_detail_multiple_scores_screen.dart';
import 'package:injicare_event/view_models/event_view_model.dart';
import 'package:injicare_event/widgets/event_detail_template.dart';
import 'package:injicare_event/widgets/photo_image_card.dart';

final isImageAccessible = ValueNotifier<bool>(true);
final submitPhotoEvent = ValueNotifier<bool>(false);

class EventDetailPhotoScreen extends ConsumerStatefulWidget {
  final EventModel eventModel;
  final UserProfile userProfile;

  const EventDetailPhotoScreen({
    super.key,
    required this.eventModel,
    required this.userProfile,
  });

  @override
  ConsumerState<EventDetailPhotoScreen> createState() =>
      _EventDetailPointScreenState();
}

class _EventDetailPointScreenState
    extends ConsumerState<EventDetailPhotoScreen> {
  bool _myParticipationLoadingComplete = false;
  bool _myParticipation = true;

  EventModel stateEventModel = EventModel.empty();
  // final TextEditingController _answerController = TextEditingController();

  bool _completeScoreLoading = false;

  List<PhotoImageModel> _imagesList = [];

  String _title = "";
  XFile? _photo;

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
        .updateUserPhotoEventState(widget.eventModel);
    setState(() {
      _completeScoreLoading = true;
      stateEventModel = updateScoreModel;
    });
  }

  Future<void> _initializeMyParticipation() async {
    List<Map<String, dynamic>> dbMyParticipation = await ref
        .read(eventRepo)
        .checkMyParticiapationPhotoEvent(
            widget.eventModel.eventId, widget.userProfile.userId);

    // 참여 중일 경우 answers 가져오기
    final imagesList = await ref
        .read(eventProvider.notifier)
        .fetchCertainPhotoEventImages(widget.eventModel.eventId);

    if (mounted) {
      setState(() {
        _imagesList = imagesList;
        _myParticipationLoadingComplete = true;
        _myParticipation = dbMyParticipation.isNotEmpty;
      });
    }
  }

  void _selectTitle(String title) {
    setState(() {
      _title = title;
    });
  }

  void _selectPhoto(XFile photo) {
    setState(() {
      _photo = photo;
    });
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

  void _submitPhotoEvent() async {
    try {
      if (_title.isEmpty || _photo == null || !isImageAccessible.value) return;

      submitPhotoEvent.value = true;

      // participate_event를 해야할까?
      final participantUpdateEventModel = stateEventModel.copyWith(
          participantsNumber: stateEventModel.participantsNumber != null
              ? stateEventModel.participantsNumber! + 1
              : 1);

      // 사진 추가
      final photoUrl = await ref.read(eventRepo).uploadPhotoImageToStorage(
            _photo!,
            stateEventModel.eventId,
            widget.userProfile.userId,
          );

      final photoImageModel = PhotoImageModel(
        eventId: stateEventModel.eventId,
        userId: widget.userProfile.userId,
        createdAt: getCurrentSeconds(),
        photo: photoUrl,
        title: _title,
      );

      await ref.read(eventRepo).savePhotoEventAnswer(photoImageModel);

      setState(() {
        _imagesList.insert(0, photoImageModel);
        stateEventModel = participantUpdateEventModel;
        _myParticipation = true;
      });

      if (!mounted) return;
      Navigator.of(context).pop();

      _scrollToLastParticipantBottom();
    } catch (e) {
      submitPhotoEvent.value = false;
      // ignore: avoid_print
      print("_submitPhotoEvent -> $e");
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

    // 사진 제출하고 참여하기
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor:
          isDarkMode(context) ? Colors.grey.shade900 : Colors.white,
      elevation: 0,
      context: context,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return SelectPhotoWidget(
          size: size,
          selectTitle: _selectTitle,
          selectPhoto: _selectPhoto,
          submitPhotoEvent: _submitPhotoEvent,
        );
      },
    );
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
                              "사진 제출하고 참여하기",
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
                            headerText: "출품작들",
                          ),
                          CustomScrollView(
                            shrinkWrap: true,
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final dataKey = GlobalKey();
                                    if (index == _imagesList.length - 1) {
                                      lastParticipantKey.value = dataKey;
                                    }
                                    return PhotoImageCard(
                                      key: dataKey,
                                      index: index + 1,
                                      photoImageModel: _imagesList[index],
                                    );
                                  },
                                  childCount: _imagesList.length,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
          ],
        ),
      ),
    );
  }
}

class SelectPhotoWidget extends StatefulWidget {
  final void Function(String) selectTitle;
  final void Function(XFile) selectPhoto;
  final void Function() submitPhotoEvent;
  const SelectPhotoWidget({
    super.key,
    required this.size,
    required this.selectTitle,
    required this.selectPhoto,
    required this.submitPhotoEvent,
  });

  final Size size;

  @override
  State<SelectPhotoWidget> createState() => _SelectPhotoWidgetState();
}

class _SelectPhotoWidgetState extends State<SelectPhotoWidget> {
  String _title = "";
  XFile? _photo;
  bool _tapSubmitPhotoEvent = false;

  void _writeTitle(String title) {
    setState(() {
      _title = title;
    });
    widget.selectTitle(title);
  }

  void _selectPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (photo != null) {
      setState(() {
        _tapSubmitPhotoEvent = false;
        _photo = photo;
      });
      widget.selectPhoto(photo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 30,
            horizontal: 16,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      "사진 제출하기",
                      softWrap: true,
                      style: InjicareFont().headline02,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              Gaps.v20,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Gaps.v20,
                      const EventHeader(
                        headerText: "작품명",
                      ),
                      if (_tapSubmitPhotoEvent && _title.isEmpty)
                        const EmptyWidget(
                          text: "작품명을 작성해주세요",
                        ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: IgnorePointer(
                              ignoring: false,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: InjicareColor(context: context)
                                            .gray10,
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size20,
                                        ),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: TextFormField(
                                        // controller: _shortAnswerControllder,
                                        onChanged: (value) {
                                          setState(() {
                                            _tapSubmitPhotoEvent = false;
                                          });
                                          _writeTitle(value);
                                        },
                                        maxLines: 1,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        style: InjicareFont().headline03,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "작품 제목을 적어주세요",
                                          hintStyle: InjicareFont()
                                              .headline03
                                              .copyWith(
                                                color: InjicareColor(
                                                        context: context)
                                                    .gray50,
                                              ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: Sizes.size20,
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const DividerWidget(),
                      const EventHeader(
                        headerText: "사진",
                      ),
                      if (_tapSubmitPhotoEvent && _photo == null)
                        const EmptyWidget(
                          text: "제출할 사진을 선택해주세요",
                        ),
                      GestureDetector(
                        onTap: _selectPhoto,
                        child: Column(
                          children: [
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: InjicareColor(context: context).gray20,
                                  width: 5,
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: _photo == null
                                  ? Padding(
                                      padding: const EdgeInsets.all(50),
                                      child: ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          InjicareColor(context: context)
                                              .gray40,
                                          BlendMode.srcIn,
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/svg/photo.svg",
                                          width: 28,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 180,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.network(
                                        _photo!.path,
                                        fit: BoxFit.cover,
                                        frameBuilder: (context, child, frame,
                                            wasSynchronouslyLoaded) {
                                          isImageAccessible.value = true;
                                          return child;
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          isImageAccessible.value = false;
                                          return Center(
                                            child: Text(
                                              "사진을 선택해주세요",
                                              textAlign: TextAlign.center,
                                              style: InjicareFont()
                                                  .body06
                                                  .copyWith(
                                                    color: Colors.red,
                                                  ),
                                              overflow: TextOverflow.visible,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ),
                            Gaps.v10,
                            Text(
                              "사진 선택하기",
                              style: InjicareFont().body03.copyWith(
                                    color:
                                        InjicareColor(context: context).gray80,
                                  ),
                            )
                          ],
                        ),
                      ),
                      Gaps.v60,
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: submitPhotoEvent,
                builder: (context, submitPhotoEventValue, child) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _tapSubmitPhotoEvent = true;
                      });
                      if (submitPhotoEventValue) return;
                      widget.submitPhotoEvent();
                    },
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
                        child: submitPhotoEventValue
                            ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator.adaptive(
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                "사진전에 제출하기",
                                style: InjicareFont().body01.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  final String text;
  const EmptyWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Text(
              text,
              style: InjicareFont().body06.copyWith(
                    color: Colors.red,
                  ),
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
            Gaps.v20,
          ],
        ),
      ],
    );
  }
}
