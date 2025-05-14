import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:injicare_event/constants/gaps.dart';
import 'package:injicare_event/constants/sizes.dart';
import 'package:injicare_event/injicare_color.dart';
import 'package:injicare_event/injicare_font.dart';
import 'package:injicare_event/models/event_model.dart';
import 'package:injicare_event/repos/event_repo.dart';
import 'package:injicare_event/widgets/desc_tile_widgets.dart';

class EventDetailTemplate extends ConsumerWidget {
  final bool completeScoreLoading;
  final EventModel eventModel;
  final Widget userPointWidget;
  final Widget pointMethodWidget;
  final Widget specialWidget;
  final Widget button;
  const EventDetailTemplate({
    super.key,
    required this.completeScoreLoading,
    required this.eventModel,
    required this.userPointWidget,
    required this.pointMethodWidget,
    required this.specialWidget,
    required this.button,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 90,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: InjicareColor(context: context).gray10,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(3),
                                    topRight: Radius.circular(3),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 5,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                              text: "아래로 내려 행사 내용을 ",
                                              style: InjicareFont()
                                                  .body07
                                                  .copyWith(
                                                      color: InjicareColor(
                                                              context: context)
                                                          .gray70),
                                              children: [
                                                TextSpan(
                                                  text: "꼼꼼히",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: InjicareColor(
                                                            context: context)
                                                        .gray80,
                                                  ),
                                                ),
                                                const TextSpan(text: " 확인해주세요")
                                              ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Column(
                                          children: [
                                            Gaps.v40,
                                            specialWidget,
                                            userPointWidget,
                                            Gaps.v20,
                                            Image.network(
                                              eventModel.eventImage,
                                              width: size.width,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container();
                                              },
                                            ),
                                            Gaps.v20,
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    eventModel.title,
                                                    softWrap: true,
                                                    style: InjicareFont()
                                                        .headline03
                                                        .copyWith(
                                                          color: InjicareColor(
                                                                  context:
                                                                      context)
                                                              .gray80,
                                                        ),
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Gaps.v24,
                                            const EventHeader(headerText: "설명"),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    eventModel.description,
                                                    style:
                                                        InjicareFont().body02,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Gaps.v24,
                                      Container(
                                        decoration: BoxDecoration(
                                          color: InjicareColor(context: context)
                                              .primary50
                                              .withOpacity(0.02),
                                        ),
                                        child: Column(
                                          children: [
                                            Gaps.v24,
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                              ),
                                              child: Column(
                                                children: [
                                                  const EventHeader(
                                                      headerText: "행사 개요"),
                                                  FutureBuilder(
                                                    future: ref
                                                        .read(eventRepo)
                                                        .convertContractRegionIdToName(
                                                            eventModel
                                                                    .contractRegionId ??
                                                                ""),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        return EventInfoTile(
                                                            header: "주최 기관",
                                                            info: snapshot
                                                                        .data ==
                                                                    "-"
                                                                ? "인지케어"
                                                                : "${snapshot.data}");
                                                      } else if (snapshot
                                                          .hasError) {
                                                        // ignore: avoid_print
                                                        print(
                                                            "name: ${snapshot.error}");
                                                      }
                                                      return Container();
                                                    },
                                                  ),
                                                  Gaps.v10,
                                                  EventInfoTile(
                                                      header: "행사 진행일",
                                                      info:
                                                          "${eventModel.startDate} ~ ${eventModel.endDate}"),
                                                  Gaps.v10,
                                                  EventInfoTile(
                                                      header: "진행 상황",
                                                      info:
                                                          "${eventModel.state}"),
                                                  Gaps.v10,
                                                  if (eventModel.targetScore !=
                                                      0)
                                                    Column(
                                                      children: [
                                                        EventInfoTile(
                                                            header: "목표 점수",
                                                            info:
                                                                "${eventModel.targetScore}점"),
                                                        Gaps.v10,
                                                      ],
                                                    ),
                                                  EventInfoTile(
                                                      header: "달성 인원",
                                                      info: eventModel
                                                                  .achieversNumber !=
                                                              0
                                                          ? "${eventModel.achieversNumber}명"
                                                          : "제한 없음"),
                                                  Gaps.v10,
                                                  EventInfoTile(
                                                      header: "연령 제한",
                                                      info: eventModel
                                                                  .ageLimit !=
                                                              0
                                                          ? "${eventModel.ageLimit}세 이상"
                                                          : "제한 없음"),
                                                ],
                                              ),
                                            ),
                                            Gaps.v40,
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: pointMethodWidget,
                                            ),
                                            const SizedBox(
                                              height: 120,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 45,
                right: 16,
                child: !completeScoreLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SkeletonLine(
                            style: SkeletonLineStyle(
                              width: 150,
                              height: 30,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: eventModel.state == "종료"
                                  ? InjicareColor(context: context).gray70
                                  : InjicareColor(context: context).primary50,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Sizes.size3,
                                horizontal: Sizes.size10,
                              ),
                              child: Text(
                                eventModel.state == "종료"
                                    ? "종료"
                                    : "${eventModel.leftDays}일 남음",
                                style: InjicareFont().body04.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),
                          Gaps.h10,
                          Text(
                            "${eventModel.participantsNumber}명 참여",
                            style: InjicareFont().body02.copyWith(
                                  color: InjicareColor(context: context).gray90,
                                ),
                          ),
                        ],
                      ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.8],
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 20,
                      bottom: 20,
                    ),
                    child: button,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
