import 'package:flutter/material.dart';
import 'package:injicare_event/constants/gaps.dart';
import 'package:injicare_event/injicare_color.dart';
import 'package:injicare_event/injicare_font.dart';
import 'package:injicare_event/utils.dart';

class PointTile extends StatelessWidget {
  final String header;
  final int point;
  const PointTile({
    super.key,
    required this.header,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            text: "・ ",
            style: InjicareFont().body01.copyWith(
                  color: isDarkMode(context)
                      ? Colors.white
                      : InjicareColor().gray80,
                ),
            children: <TextSpan>[
              TextSpan(
                text: "$header  →  ",
                style: InjicareFont().body01.copyWith(
                      fontWeight: FontWeight.w400,
                      color: isDarkMode(context)
                          ? Colors.white
                          : InjicareColor().gray90,
                    ),
              ),
              TextSpan(
                text: "$point점",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Gaps.v5,
      ],
    );
  }
}

class CountTile extends StatelessWidget {
  final String header;
  final int point;
  const CountTile({
    super.key,
    required this.header,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            text: "・ ",
            style: InjicareFont().body01.copyWith(
                  color: isDarkMode(context)
                      ? Colors.white
                      : InjicareColor().gray80,
                ),
            children: <TextSpan>[
              TextSpan(
                text: "$header  →  ",
                style: InjicareFont().body01.copyWith(
                      color: isDarkMode(context)
                          ? Colors.white
                          : InjicareColor().gray90,
                    ),
              ),
              TextSpan(
                text: "$point회",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Gaps.v5,
      ],
    );
  }
}

class DailyMaxTile extends StatelessWidget {
  final String maxText;
  const DailyMaxTile({
    super.key,
    required this.maxText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Gaps.h16,
        Text(
          "- 하루 최대 $maxText",
          style: InjicareFont().body07.copyWith(
                color: InjicareColor(context: context).gray60,
              ),
        ),
      ],
    );
  }
}

class EventInfoTile extends StatelessWidget {
  final String header;
  final String info;
  const EventInfoTile({
    super.key,
    required this.header,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: RichText(
            softWrap: true,
            text: TextSpan(
              text: "・ ",
              style: InjicareFont().body01.copyWith(
                    color: isDarkMode(context)
                        ? Colors.white
                        : InjicareColor().gray80,
                  ),
              children: [
                TextSpan(
                  text: "$header:  ",
                  style: InjicareFont().body01.copyWith(
                        color: isDarkMode(context)
                            ? Colors.white
                            : InjicareColor().gray90,
                      ),
                ),
                TextSpan(
                  text: info,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EventHeader extends StatelessWidget {
  final String headerText;
  const EventHeader({
    super.key,
    required this.headerText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color:
                    InjicareColor(context: context).primary50.withOpacity(0.1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                child: Text(
                  headerText,
                  style: InjicareFont().body04.copyWith(
                        color: InjicareColor(context: context).gray80,
                      ),
                ),
              ),
            ),
          ],
        ),
        Gaps.v20,
      ],
    );
  }
}

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gaps.v32,
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: InjicareColor(context: context).gray10,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
          ),
        ),
        Gaps.v24,
      ],
    );
  }
}
