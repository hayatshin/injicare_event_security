import 'package:flutter/material.dart';
import 'package:injicare_event_security/constants/gaps.dart';
import 'package:injicare_event_security/injicare_color.dart';
import 'package:injicare_event_security/injicare_font.dart';
import 'package:injicare_event_security/models/event_model.dart';

class UserPointLoadingWidget extends StatefulWidget {
  final Size size;
  final EventModel eventModel;
  final Widget loadingWidget;
  const UserPointLoadingWidget({
    super.key,
    required this.size,
    required this.eventModel,
    required this.loadingWidget,
  });

  @override
  State<UserPointLoadingWidget> createState() => _UserPointLoadingWidgetState();
}

class _UserPointLoadingWidgetState extends State<UserPointLoadingWidget> {
  // bool _completeLoading = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        completeLoading.value = true;
      }
    });
  }

  final completeLoading = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "행사 기준 내 점수",
          style: InjicareFont().body03.copyWith(
                color: InjicareColor(context: context).gray80,
              ),
        ),
        Gaps.v5,
        Text(
          "→ 참여 후 계산됩니다",
          style: InjicareFont().body02.copyWith(
                color: InjicareColor().primary50,
              ),
        ),
        Gaps.v20,
        widget.loadingWidget,
        // ValueListenableBuilder(
        //   valueListenable: completeLoading,
        //   builder: (context, value, child) {
        //     if (value) {
        //       return MyProgressScreen(
        //         eventModel: widget.eventModel,
        //         userScore: 0,
        //       );
        //     }
        //   },
        // ),
      ],
    );
  }
}
