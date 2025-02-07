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
        ? const Color(0xfff62459)
        : isDarkMode(context!)
            ? const Color(0xfff62459)
            : const Color(0xfff62459);
    primary40 = context == null
        ? const Color(0xffF97B9B)
        : isDarkMode(context!)
            ? const Color(0xffF97B9B)
            : const Color(0xffF97B9B);
    primary30 = context == null
        ? const Color(0xffFBA7BC)
        : isDarkMode(context!)
            ? const Color(0xffFBA7BC)
            : const Color(0xffFBA7BC);
    primary20 = context == null
        ? const Color(0xffFDD3DD)
        : isDarkMode(context!)
            ? const Color(0xffFDD3DD)
            : const Color(0xffFDD3DD);
    secondary50 = context == null
        ? const Color(0xff277EFF)
        : isDarkMode(context!)
            ? const Color(0xffD3E5FF)
            : const Color(0xff277EFF);
    secondary40 = context == null
        ? const Color(0xff7DB1FF)
        : isDarkMode(context!)
            ? const Color(0xffA8CBFF)
            : const Color(0xff7DB1FF);
    secondary30 = context == null
        ? const Color(0xffA8CBFF)
        : isDarkMode(context!)
            ? const Color(0xff7DB1FF)
            : const Color(0xffA8CBFF);
    secondary20 = context == null
        ? const Color(0xffD3E5FF)
        : isDarkMode(context!)
            ? const Color(0xff277EFF)
            : const Color(0xffD3E5FF);
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
