import 'package:flutter/material.dart';
import 'package:injicare_event/constants/gaps.dart';
import 'package:injicare_event/constants/sizes.dart';
import 'package:injicare_event/injicare_color.dart';
import 'package:injicare_event/injicare_font.dart';
import 'package:injicare_event/models/quiz_answer_model.dart';
import 'package:injicare_event/utils.dart';

class AnswerCard extends StatelessWidget {
  final int index;
  final QuizAnswerModel quizAnswerModel;
  const AnswerCard({
    super.key,
    required this.index,
    required this.quizAnswerModel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Sizes.size14,
            ),
            child: Row(
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
                      quizAnswerModel.userName ?? "참가자",
                      overflow: TextOverflow.ellipsis,
                      style: InjicareFont().body01,
                    ),
                  ),
                ),
                Gaps.h10,
                Flexible(
                  child: Text(
                    secondsToStringDateComment(quizAnswerModel.createdAt),
                    style: InjicareFont().body06.copyWith(
                          color: InjicareColor(context: context).gray60,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
