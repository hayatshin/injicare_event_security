import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:injicare_event/constants/gaps.dart';
import 'package:injicare_event/injicare_color.dart';
import 'package:injicare_event/injicare_font.dart';

class EnlargePhotoCard extends StatelessWidget {
  final String url;
  final String heroTag;
  const EnlargePhotoCard({
    super.key,
    required this.url,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.6),
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            forceMaterialTransparency: true,
            // leading: GestureDetector(
            //   onTap: () {
            //     if (context.canPop()) {
            //       context.pop();
            //     }
            //   },
            //   child: Center(
            //     child: SvgPicture.asset(
            //       "assets/svg/arrow-left.svg",
            //       width: 18,
            //       colorFilter:
            //           const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            //     ),
            //   ),
            // ),
            title: Text(
              "출품작 크게 보기",
              style: InjicareFont().body01.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          body: InteractiveViewer(
            panEnabled: false,
            minScale: 0.5,
            maxScale: 5,
            child: Center(
              child: Hero(
                tag: heroTag,
                child: SizedBox(
                  width: size.width,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    memCacheWidth: (size.width * 2).ceil(),
                    errorWidget: (context, url, error) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/svg_2/warning.svg",
                          colorFilter: ColorFilter.mode(
                              InjicareColor(context: context).gray40,
                              BlendMode.srcIn),
                        ),
                        Gaps.v16,
                        Text(
                          "불러올 수 없는 사진입니다",
                          style: InjicareFont().label01.copyWith(
                                color: InjicareColor(context: context).gray20,
                              ),
                        ),
                      ],
                    ),
                    fadeInDuration: const Duration(milliseconds: 300),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
