import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injicare_event_security/constants/gaps.dart';
import 'package:injicare_event_security/constants/sizes.dart';
import 'package:injicare_event_security/injicare_color.dart';
import 'package:injicare_event_security/injicare_font.dart';
import 'package:injicare_event_security/models/event_model.dart';
import 'package:injicare_event_security/models/photo_image_model.dart';
import 'package:injicare_event_security/models/user_profile.dart';
import 'package:injicare_event_security/repos/event_repo.dart';
import 'package:injicare_event_security/utils.dart';
import 'package:injicare_event_security/view_models/event_view_model.dart';
import 'package:injicare_event_security/widgets/button_widgets.dart';
import 'package:injicare_event_security/widgets/desc_tile_widgets.dart';
import 'package:injicare_event_security/widgets/event_detail_template.dart';
import 'package:injicare_event_security/widgets/photo_image_card.dart';

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

      // 업로드 실패 방어막
      if (photoUrl.isEmpty) {
        submitPhotoEvent.value = false;
        if (!mounted) return;
        showWarningSnackBar(context, '사진 업로드에 실패했습니다. 다시 시도해 주세요.');

        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      } else {
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
      }
    } catch (e) {
      submitPhotoEvent.value = false;
      // ignore: avoid_print
      print("_submitPhotoEvent -> $e");
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
            ? const EventLoadingButton()
            : EventDefaultButton(
                eventFunction: stateEventModel.state == "종료"
                    ? null
                    : !_myParticipation
                        ? _participateEvent
                        : null,
                text: stateEventModel.state == "종료"
                    ? "종료된 행사입니다"
                    : !_myParticipation
                        ? "사진 제출하기"
                        : "이미 참여했습니다",
                buttonColor: stateEventModel.state == "종료"
                    ? InjicareColor(context: context).gray70
                    : !_myParticipation
                        ? InjicareColor(context: context).primary50
                        : InjicareColor(context: context).gray70,
              ),
        userPointWidget: Container(),
        pointMethodWidget: Container(),
        specialWidget: _imagesList.isNotEmpty
            ? Column(
                children: [
                  const EventHeader(
                    headerText: "출품작들",
                  ),
                  CustomScrollView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
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
              )
            : Container(),
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
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
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
              ),
              Gaps.v20,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
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
                                              color: InjicareColor(
                                                      context: context)
                                                  .gray10,
                                              borderRadius:
                                                  BorderRadius.circular(
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
                          ],
                        ),
                      ),
                      const DividerWidget(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
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
                                        color: InjicareColor(context: context)
                                            .gray20,
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
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: Image.network(
                                              _photo!.path,
                                              fit: BoxFit.cover,
                                              frameBuilder: (context,
                                                  child,
                                                  frame,
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
                                                    overflow:
                                                        TextOverflow.visible,
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
                                          color: InjicareColor(context: context)
                                              .gray80,
                                        ),
                                  )
                                ],
                              ),
                            ),
                            Gaps.v60,
                          ],
                        ),
                      )
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: InjicareColor(context: context).primary50,
                          borderRadius: BorderRadius.circular(18),
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
