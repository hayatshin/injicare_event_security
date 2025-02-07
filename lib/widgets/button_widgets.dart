import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:injicare_event/injicare_font.dart';

class EventDefaultButton extends StatelessWidget {
  final String text;
  final Color buttonColor;
  final Function()? eventFunction;
  const EventDefaultButton({
    super.key,
    required this.text,
    required this.buttonColor,
    required this.eventFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: eventFunction,
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  text,
                  style: InjicareFont().body01.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EventLoadingButton extends StatelessWidget {
  const EventLoadingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SkeletonAvatar(
            style: SkeletonAvatarStyle(
              height: 55,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ],
    );
  }
}
