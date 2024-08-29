import 'package:flutter/material.dart';
import 'package:injicare_event/utils.dart';

class InjicareColor {
  final BuildContext? context;

  late final Color primary50;
  late final Color primary40;
  late final Color primary30;
  late final Color primary20;
  late final Color secondary50;
  late final Color secondary40;
  late final Color secondary30;
  late final Color secondary20;
  late final Color gray100;
  late final Color gray90;
  late final Color gray80;
  late final Color gray70;
  late final Color gray60;
  late final Color gray50;
  late final Color gray40;
  late final Color gray30;
  late final Color gray20;
  late final Color gray10;

  InjicareColor({this.context}) {
    primary50 = context == null
        ? const Color(0xffFF2D78)
        : isDarkMode(context!)
            ? const Color(0xffFF2D78)
            : const Color(0xffFF2D78);
    primary40 = context == null
        ? const Color(0xffFF7AA9)
        : isDarkMode(context!)
            ? const Color(0xffFF7AA9)
            : const Color(0xffFF7AA9);
    primary30 = context == null
        ? const Color(0xffFFB4CE)
        : isDarkMode(context!)
            ? const Color(0xffFFB4CE)
            : const Color(0xffFFB4CE);
    primary20 = context == null
        ? const Color(0xffFFE2EC)
        : isDarkMode(context!)
            ? const Color(0xffFFE2EC)
            : const Color(0xffFFE2EC);
    secondary50 = context == null
        ? const Color(0xff1B3883)
        : isDarkMode(context!)
            ? const Color(0xffC6D4F8)
            : const Color(0xff1B3883);
    secondary40 = context == null
        ? const Color(0xff4063BC)
        : isDarkMode(context!)
            ? const Color(0xff819DE4)
            : const Color(0xff4063BC);
    secondary30 = context == null
        ? const Color(0xff819DE4)
        : isDarkMode(context!)
            ? const Color(0xff4063BC)
            : const Color(0xff819DE4);
    secondary20 = context == null
        ? const Color(0xffC6D4F8)
        : isDarkMode(context!)
            ? const Color(0xff1B3883)
            : const Color(0xffC6D4F8);
    gray100 = context == null
        ? const Color(0xff151515)
        : isDarkMode(context!)
            ? const Color(0xffF4F4F4)
            : const Color(0xff151515);
    gray90 = context == null
        ? const Color(0xff303030)
        : isDarkMode(context!)
            ? const Color(0xffEDEDED)
            : const Color(0xff303030);
    gray80 = context == null
        ? const Color(0xff4D4D4D)
        : isDarkMode(context!)
            ? const Color(0xffDEDEDE)
            : const Color(0xff4D4D4D);
    gray70 = context == null
        ? const Color(0xff707070)
        : isDarkMode(context!)
            ? const Color(0xffCCCCCC)
            : const Color(0xff707070);
    gray60 = context == null
        ? const Color(0xff959595)
        : isDarkMode(context!)
            ? const Color(0xffB0B0B0)
            : const Color(0xff959595);
    gray50 = context == null
        ? const Color(0xffB0B0B0)
        : isDarkMode(context!)
            ? const Color(0xff959595)
            : const Color(0xffB0B0B0);
    gray40 = context == null
        ? const Color(0xffCCCCCC)
        : isDarkMode(context!)
            ? const Color(0xff707070)
            : const Color(0xffCCCCCC);
    gray30 = context == null
        ? const Color(0xffDEDEDE)
        : isDarkMode(context!)
            ? const Color(0xff4D4D4D)
            : const Color(0xffDEDEDE);
    gray20 = context == null
        ? const Color(0xffEDEDED)
        : isDarkMode(context!)
            ? const Color(0xff303030)
            : const Color(0xffEDEDED);
    gray10 = context == null
        ? const Color(0xffF4F4F4)
        : isDarkMode(context!)
            ? const Color(0xff151515)
            : const Color(0xffF4F4F4);
  }
}
