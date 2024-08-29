import 'package:flutter/widgets.dart';

class InjicareFont {
  late final TextStyle headline01;
  late final TextStyle headline02;
  late final TextStyle headline03;
  late final TextStyle headline04;
  late final TextStyle body01;
  late final TextStyle body02;
  late final TextStyle body03;
  late final TextStyle body04;
  late final TextStyle body05;
  late final TextStyle body06;
  late final TextStyle body07;
  late final TextStyle label01;
  late final TextStyle label02;
  late final TextStyle label03;

  InjicareFont() {
    headline01 = const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 29,
      height: 36 / 29,
    );
    headline02 = const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 25,
      height: 36 / 25,
    );
    headline03 = const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 21,
      height: 30 / 21,
    );
    headline04 = const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 19,
      height: 26 / 19,
    );
    body01 = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 19,
      height: 26 / 19,
    );
    body02 = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 19,
      height: 26 / 19,
    );
    body03 = const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 17,
      height: 24 / 17,
    );
    body04 = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 17,
      height: 24 / 17,
    );
    body05 = const TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 17,
      height: 24 / 17,
    );
    body06 = const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 15,
      height: 22 / 15,
    );
    body07 = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 15,
      height: 22 / 15,
    );
    label01 = const TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 15,
      height: 20 / 15,
    );
    label02 = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 13,
      height: 18 / 13,
    );
    label03 = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 13,
      height: 18 / 13,
    );
  }
}
