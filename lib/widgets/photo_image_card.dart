import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:injicare_event/constants/gaps.dart';
import 'package:injicare_event/constants/sizes.dart';
import 'package:injicare_event/injicare_color.dart';
import 'package:injicare_event/injicare_font.dart';
import 'package:injicare_event/models/photo_image_model.dart';
import 'package:injicare_event/utils.dart';
import 'package:injicare_event/widgets/enlarge_photo_card.dart';

class PhotoImageCard extends StatelessWidget {
  final int index;
  final PhotoImageModel photoImageModel;
  const PhotoImageCard({
    super.key,
    required this.index,
    required this.photoImageModel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Sizes.size14,
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "$index",
                      style: InjicareFont().body01,
                    ),
                  ),
                  Gaps.h10,
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      width: 56,
                      child: Text(
                        photoImageModel.userName ?? "참가자",
                        overflow: TextOverflow.ellipsis,
                        style: InjicareFont().body01,
                      ),
                    ),
                  ),
                  Gaps.h10,
                  Expanded(
                    flex: 4,
                    child: Text(
                      secondsToStringDateComment(photoImageModel.createdAt),
                      style: InjicareFont().body06.copyWith(
                            color: InjicareColor(context: context).gray60,
                          ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Gaps.v5,
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 5,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            opaque: false, // ✨ 핵심: 뒤 화면을 계속 그리게 함
                            barrierDismissible: true,
                            barrierColor:
                                Colors.black.withValues(alpha: 0.6), // 딤 색상
                            transitionDuration:
                                const Duration(milliseconds: 200),
                            pageBuilder: (context, animation, secondary) =>
                                EnlargePhotoCard(
                              url: photoImageModel.photo,
                              heroTag: photoImageModel.photo,
                            ),
                            transitionsBuilder:
                                (context, animation, secondary, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                          ),
                        );
                      },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: CachedNetworkImage(
                          imageUrl: photoImageModel.photo,
                          placeholder: (context, url) {
                            return const SkeletonAvatar(
                              style: SkeletonAvatarStyle(
                                width: 80,
                                height: 80,
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return Container(
                              color: InjicareColor(context: context).gray40,
                              child: Center(
                                child: Text(
                                  "불러올 수 없는\n이미지입니다",
                                  style: InjicareFont().label03.copyWith(
                                        color: InjicareColor(context: context)
                                            .gray10,
                                      ),
                                ),
                              ),
                            );
                          },
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Gaps.h10,
                  Expanded(
                    flex: 4,
                    child: Text(
                      photoImageModel.title,
                      style: InjicareFont().body01,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
