import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:injicare_event/constants/gaps.dart';
import 'package:injicare_event/constants/sizes.dart';
import 'package:injicare_event/injicare_color.dart';
import 'package:injicare_event/injicare_font.dart';
import 'package:injicare_event/models/event_model.dart';
import 'package:injicare_event/utils.dart';

class EventDetailTemplate extends StatelessWidget {
  final bool completeScoreLoading;
  final EventModel eventModel;

  final Widget child;
  final Widget button;
  const EventDetailTemplate({
    super.key,
    required this.completeScoreLoading,
    required this.eventModel,
    required this.child,
    required this.button,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: eventModel.eventImage,
                width: size.width,
                height: size.height,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: size.width,
                  height: size.height,
                  color: InjicareColor(context: context).gray10,
                ),
                errorWidget: (context, url, error) => Container(
                  width: size.width,
                  height: size.height,
                  color: InjicareColor(context: context).gray10,
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5,
                  sigmaY: 5,
                ),
                child: Container(
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              // Positioned(
              //   top: 20,
              //   left: 16,
              //   child: Row(
              //     children: [
              //       GestureDetector(
              //         onTap: () {
              //           Navigator.of(context).pop();
              //         },
              //         child: SvgPicture.asset(
              //           "assets/svg/circle-chevron-left-regular.svg",
              //           width: 40,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Positioned(
                top: 60,
                left: 16,
                right: 16,
                bottom: 20,
                child: Column(
                  children: [
                    !completeScoreLoading
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
                                  color: InjicareColor().secondary50,
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
                                      color: Colors.black,
                                    ),
                              ),
                            ],
                          ),
                    Gaps.v12,
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDarkMode(context)
                                    ? Colors.black
                                    : Colors.white,
                                border: Border.all(
                                  width: 2,
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(
                                  Sizes.size5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: InjicareColor(context: context)
                                          .gray20,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: RichText(
                                              text: TextSpan(
                                                  text: "아래로 내려 행사 내용을 ",
                                                  style: InjicareFont()
                                                      .body07
                                                      .copyWith(
                                                          color: InjicareColor(
                                                                  context:
                                                                      context)
                                                              .gray70),
                                                  children: [
                                                    TextSpan(
                                                      text: "꼼꼼히",
                                                      style: TextStyle(
                                                        color: InjicareColor(
                                                                context:
                                                                    context)
                                                            .secondary40,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                        text: " 확인해주세요")
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 20,
                                              ),
                                              child: child),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Gaps.v24,
                          button,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
