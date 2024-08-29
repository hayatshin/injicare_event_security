import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:injicare_event/constants/gaps.dart';
import 'package:injicare_event/constants/sizes.dart';

class DefaultScreen extends StatelessWidget {
  const DefaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: Stack(
            children: [
              // SizedBox(
              //   width: size.width,
              //   height: size.height,
              //   child: const SkeletonAvatar(
              //     style: SkeletonAvatarStyle(
              //       shape: BoxShape.rectangle,
              //     ),
              //   ),
              // ),
              Positioned(
                top: 20,
                left: 16,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/svg/circle-chevron-left-regular.svg",
                      width: 40,
                    ),
                  ],
                ),
              ),
              // const Positioned(
              //   top: 20,
              //   left: 16,
              //   child: Column(
              //     children: [
              //       SkeletonLine(
              //         style: SkeletonLineStyle(
              //           width: 150,
              //           height: 30,
              //           borderRadius: BorderRadius.all(
              //             Radius.circular(10),
              //           ),
              //         ),
              //       ),
              //       Gaps.v12,
              //       SkeletonAvatar(
              //         style: SkeletonAvatarStyle(
              //           width: 40,
              //           height: 40,
              //           shape: BoxShape.circle,
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
                    const Row(
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
                    ),
                    Gaps.v12,
                    Expanded(
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          width: size.width,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(
                            Sizes.size5,
                          ),
                        ),
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
