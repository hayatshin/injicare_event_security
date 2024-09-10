import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:injicare_event/constants/gaps.dart';
import 'package:injicare_event/constants/sizes.dart';
import 'package:injicare_event/injicare_color.dart';
import 'package:injicare_event/injicare_font.dart';
import 'package:injicare_event/models/photo_image_model.dart';
import 'package:injicare_event/utils.dart';

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
                  Text(
                    "$index",
                    style: InjicareFont().body01,
                  ),
                  Gaps.h10,
                  Expanded(
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
                  Flexible(
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
                    child: Container(
                      width: 80,
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
                      ),
                    ),
                  ),
                  Gaps.h10,
                  Flexible(
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
