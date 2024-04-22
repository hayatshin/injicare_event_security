import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:injicare_event/constants/sizes.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

bool isDarkMode(BuildContext context) =>
    MediaQuery.of(context).platformBrightness == Brightness.dark;

final RegExp isAllNumbersRegex = RegExp(r'^[0-9]+$');

DateTime currentKoreaDateTime() {
  tz.initializeTimeZones();
  final koreaTimeZone = tz.getLocation('Asia/Seoul');
  final koreaNow = tz.TZDateTime.now(koreaTimeZone);
  return koreaNow;
}

String todayToStringLine() {
  final formattedDate = DateFormat('yyyy-MM-dd').format(currentKoreaDateTime());
  return formattedDate;
  // DateTime dateTime = DateTime.now();
  // String formattedDate =
  //     '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  // return formattedDate;
}

DateTime dateStringToDateTimeDot(String dateString) {
  return DateTime.parse(dateString.replaceAll('.', '-'));
}

String dateTimeToStringDiaryTimeLine(DateTime dateTime) {
  String diaryHour = dateTime.hour == 24 || dateTime.hour == 0
      ? "오전 12시"
      : dateTime.hour == 12
          ? "오후 12시"
          : dateTime.hour > 12
              ? "오후 ${dateTime.hour - 12}시"
              : "오전 ${dateTime.hour}시";

  String formattedDate =
      '${dateTime.month}/${dateTime.day} $diaryHour ${dateTime.minute}분';
  return formattedDate;
}

String dateTimeToStringDateLine(DateTime dateTime) {
  final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
  return formattedDate;

  // String formattedDate =
  //     '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  // return formattedDate;
}

String dateTimeToStringDateDot(DateTime dateTime) {
  final formattedDate = DateFormat('yyyy. MM. dd').format(dateTime);
  return formattedDate;

  // String formattedDate =
  //     '${dateTime.year}. ${dateTime.month.toString().padLeft(2, '0')}. ${dateTime.day.toString().padLeft(2, '0')}';
  // return formattedDate;
}

String dateTimeToStringDateSlash(DateTime dateTime) {
  final formattedDate = DateFormat('yyyy/MM/dd').format(dateTime);
  return formattedDate;

  // String formattedDate =
  //     '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  // return formattedDate;
}

String dateTimeToStringDateComment(DateTime dateTime) {
  String formattedDate =
      '${dateTime.year.toString().substring(2)}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  return formattedDate;
}

DateTime dbBirthdayToDateTime(String birthYear, String birthDay) {
  return DateTime.parse(
      "$birthYear-${birthDay.substring(0, 2)}-${birthDay.substring(2)}");
}

bool isDatePassed(String certainBirthday) {
  late bool passedOrNot;
  final now = currentKoreaDateTime();
  final currentMonth = now.month;
  final currentDate = now.day;
  final certainMonth = int.parse(certainBirthday.substring(0, 2));
  final certainDate = int.parse(certainBirthday.substring(2, 4));

  passedOrNot = currentMonth == certainMonth
      ? currentDate > certainDate
      : currentMonth > certainMonth;
  return passedOrNot;
}

String userAgeCalculation(String birthYear, String birthDay) {
  try {
    late int returnAge;
    final int currentYear = currentKoreaDateTime().year;
    final initialAge = currentYear - int.parse(birthYear);
    returnAge = isDatePassed(birthDay) ? initialAge : initialAge - 1;
    return returnAge.toString();
  } catch (e) {
    // ignore: avoid_print
    return "";
  }
}

Future<void> saveDynamicToSharedPrefs(
    dynamic dynamicData, String prefName) async {
  final prefs = await SharedPreferences.getInstance();
  final encodedList = json.encode(dynamicData);
  await prefs.setString(prefName, encodedList);
}

Future<List<dynamic>> loadDynamicFromPrefs(String prefName) async {
  final prefs = await SharedPreferences.getInstance();
  final encodedList = prefs.getString(prefName);
  if (encodedList != null) {
    final decodedList = jsonDecode(encodedList) as List<dynamic>;
    return decodedList;
  }
  return [];
}

void showSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      showCloseIcon: true,
      content: Text(
        message,
        style: const TextStyle(
          fontSize: Sizes.size18,
        ),
      ),
    ),
  );
}

Future<File?> copyImageToAppDir(String sourcePath) async {
  try {
    final appDir = await getApplicationDocumentsDirectory();
    final newImagePath =
        '${appDir.path}/image.png'; // Provide a desired file name and extension

    final file = File(sourcePath);
    File newFile = await file.copy(newImagePath);
    return newFile;
    // Now, use newImagePath to display the image.
  } catch (e) {
    // ignore: avoid_print
    print('Error copying image: $e');
  }
  return null;
}

Future<File> getLocalFile(String relativePath) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  String absolutePath = join(appDocPath, relativePath);

  return File(absolutePath);
}

void closeKeyboard(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FocusScope.of(context).requestFocus(FocusNode());
  });
}

void slidePushRemoveNavigation(BuildContext context, Widget nextScreen) {
  Navigator.pushAndRemoveUntil(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        Offset begin = const Offset(1, 0);
        Offset end = Offset.zero;
        Animation<Offset> tween =
            Tween(begin: begin, end: end).animate(animation);
        return SlideTransition(
          position: tween,
          child: nextScreen,
        );
      },
    ),
    (router) => false,
  );
}

void slideNavigation(BuildContext context, Widget nextScreen) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        Offset begin = const Offset(1, 0);
        Offset end = Offset.zero;
        Animation<Offset> tween =
            Tween(begin: begin, end: end).animate(animation);
        return SlideTransition(
          position: tween,
          child: nextScreen,
        );
      },
    ),
  );
}

Future<void> removeAllSharedPreference() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();

    for (String key in keys) {
      prefs.remove(key);
    }
  } catch (e) {
    // ignore: avoid_print
    print("removeAllSharedPreference -> $e");
  }
}

// supabase -utils
int getCurrentSeconds() {
  int millisecondsSinceEpoch = currentKoreaDateTime().millisecondsSinceEpoch;
  return (millisecondsSinceEpoch / 1000).round();
}

String secondsToStringDot(int seconds) {
  final milliseconds = seconds * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  final f = DateFormat('yyyy.MM.dd');
  return f.format(dateTime);
}

String secondsToStringLine(int seconds) {
  final milliseconds = seconds * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  final f = DateFormat('yyyy-MM-dd');
  return f.format(dateTime);
}

DateTime secondsToDatetime(int seconds) {
  final milliseconds = seconds * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  return dateTime;
}

String secondsToStringDiaryTimeLine(int seconds) {
  final milliseconds = seconds * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  String diaryHour = dateTime.hour == 24
      ? "오전 0시"
      : dateTime.hour == 12
          ? "오후 12시"
          : dateTime.hour > 12
              ? "오후 ${dateTime.hour - 12}시"
              : "오전 ${dateTime.hour}시";

  String formattedDate =
      '${dateTime.month}/${dateTime.day} $diaryHour ${dateTime.minute}분';
  return formattedDate;
}

String secondsToStringCognitionTimeLine(int seconds) {
  final milliseconds = seconds * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  String diaryHour = dateTime.hour == 24
      ? "오전 0시"
      : dateTime.hour == 12
          ? "오후 12시"
          : dateTime.hour > 12
              ? "오후 ${dateTime.hour - 12}시"
              : "오전 ${dateTime.hour}시";

  String formattedDate =
      '${dateTime.year}/${dateTime.month}/${dateTime.day}  $diaryHour ${dateTime.minute}분';
  return formattedDate;
}

String secondsToStringDateComment(int seconds) {
  final milliseconds = seconds * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  String formattedDate =
      '${dateTime.year.toString().substring(2)}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  return formattedDate;
}

String secondsToStringDecibelTimeLine(int seconds) {
  final milliseconds = seconds * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  String diaryHour = dateTime.hour == 24
      ? "오전 0시"
      : dateTime.hour == 12
          ? "오후 12시"
          : dateTime.hour > 12
              ? "오후 ${dateTime.hour - 12}시"
              : "오전 ${dateTime.hour}시";

  String formattedDate =
      '${dateTime.year.toString().substring(2)}/${dateTime.month}/${dateTime.day} $diaryHour ${dateTime.minute}분';
  return formattedDate;
}

List<dynamic> spreadDiaryImages(List data) {
  // final imageModels = data.map((e) => ImageModel.fromJson(e)).toList();

  // if (imageModels.isNotEmpty &&
  //     !imageModels[0].image.startsWith("https://firebasestorage")) {
  //   // supabase storage
  //   imageModels.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  //   return imageModels.map((e) => e.image).toList();
  // } else {
  //   // firebase storage
  //   return imageModels.map((e) => e.image).toList();
  // }

  final imagelist = data.map((e) => e["image"] as String).toList();

  if (imagelist.isNotEmpty &&
      !imagelist[0].startsWith("https://firebasestorage")) {
    // supabase storage
    imagelist.sort((a, b) {
      List<String> aSegments = a.split('-imageOrder-');
      List<String> bSegments = b.split('-imageOrder-');

      int aValue = int.parse(aSegments.last);
      int bValue = int.parse(bSegments.last);

      return aValue.compareTo(bValue);
    });
    return imagelist;
  } else {
    // firebase storage
    return imagelist;
  }
}

List<dynamic> spreadFriendRpcDiaryImages(List? data) {
  if (data![0] == null) return [];
  // final imagelist = data.map((e) => e["image"] as String).toList();

  if (data.isNotEmpty && !data[0].startsWith("https://firebasestorage")) {
    // supabase storage

    data.sort((a, b) {
      List<String> aSegments = a.split('-imageOrder-');
      List<String> bSegments = b.split('-imageOrder-');

      int aValue = int.parse(aSegments.last);
      int bValue = int.parse(bSegments.last);

      return aValue.compareTo(bValue);
    });
    return data;
  } else {
    // firebase storage
    return data;
  }
}

int convertStartDateStringToSeconds(String startDate) {
  if (startDate.contains('.')) {
    List<String> dateParts = startDate.split('.');
    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);
    final dateTime = DateTime(year, month, day, 0, 0, 0);
    int seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
    return seconds;
  } else {
    return DateTime(2023).millisecondsSinceEpoch ~/ 1000;
  }
}

int convertEndDateStringToSeconds(String endDate) {
  if (endDate.contains('.')) {
    List<String> dateParts = endDate.split('.');
    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);
    final dateTime = DateTime(year, month, day, 23, 59, 59);
    int seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
    return seconds;
  } else {
    return currentKoreaDateTime().millisecondsSinceEpoch ~/ 1000;
  }
}

List<String> getThisWeekDates() {
  DateTime now = currentKoreaDateTime();
  DateTime monday = now.subtract(Duration(days: now.weekday - 1));

  List<String> weekDates = [];
  for (int i = 0; i < 7; i++) {
    DateTime date = monday.add(Duration(days: i));
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    weekDates.add(formattedDate);
  }
  return weekDates;
}

List<String> getLastWeekDates() {
  DateTime now = currentKoreaDateTime();
  DateTime monday = now.subtract(Duration(
      days: now.weekday +
          6)); // Subtracting current weekday + 6 to get last Monday

  List<String> weekDates = [];
  for (int i = 0; i < 7; i++) {
    DateTime date = monday.add(Duration(days: i));
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    weekDates.add(formattedDate);
  }
  return weekDates;
}

int getStartSecondsOfThisMonth() {
  DateTime now = currentKoreaDateTime();
  DateTime firstDayOfMonth = DateTime(now.year, now.month, 1, 0, 0, 0);
  int seconds = firstDayOfMonth.millisecondsSinceEpoch ~/ 1000;
  return seconds;
}

int getEndSecondsOfThisMonth() {
  DateTime now = currentKoreaDateTime();
  DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
  lastDayOfMonth = DateTime(lastDayOfMonth.year, lastDayOfMonth.month,
      lastDayOfMonth.day, 23, 59, 59);
  int seconds = lastDayOfMonth.millisecondsSinceEpoch ~/ 1000;
  return seconds;
}

int getEventLeftDaysFromNow(String eventEnddateString) {
  final endSeconds = eventEnddateString.split('.');
  DateTime endDateTime = DateTime(int.parse(endSeconds[0]),
      int.parse(endSeconds[1]), int.parse(endSeconds[2]));
  DateTime now = DateTime(currentKoreaDateTime().year,
      currentKoreaDateTime().month, currentKoreaDateTime().day);

  Duration difference = endDateTime.difference(now);
  int dayLeft = difference.inDays + 1;
  return dayLeft;
}

String timeOfDayToTimeTz(TimeOfDay timeOfDay) {
  final DateTime now = DateTime.now();
  final DateTime dateTime = DateTime(
    now.year,
    now.month,
    now.day,
    timeOfDay.hour,
    timeOfDay.minute,
  );
  final String formattedTime =
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:00';
  return formattedTime;
}

String convertTimeOfDayToString(TimeOfDay time) {
  String timeString = "";
  if (time.hour >= 12) {
    timeString +=
        "오후 ${(time.hour == 12 ? 12 : time.hour - 12).toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  } else {
    timeString +=
        "오전 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
  return timeString;
}

String convertStringTimeOfDayToString(String time) {
  final parts = time.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  String timeString = "";
  if (hour >= 12) {
    timeString +=
        "오후 ${(hour == 12 ? 12 : hour - 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  } else {
    timeString +=
        "오전 ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }
  return timeString;
}

Future<void> pushCommentNotification(String fcmToken, String diaryDesc,
    String commentWriter, String commentDesc) async {
  try {
    await dotenv.load(fileName: ".env");

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'key=${dotenv.env["CLOUD_MESSAGING_SERVER_KEY"]}'
      },
      body: jsonEncode({
        'token': fcmToken,
        'data': {
          'type': 'comment',
        },
        'notification': {
          'title': diaryDesc.length > 5
              ? '${diaryDesc.substring(0, 5)}... 글에 $commentWriter님이 댓글을 달았습니다.'
              : '$diaryDesc 글에 $commentWriter님이 댓글을 달았습니다.',
          'body': commentDesc.length > 10
              ? '${commentDesc.substring(0, 10)}...'
              : commentDesc,
        },
        'to': fcmToken,
      }),
    );
  } catch (e) {
    // ignore: avoid_print
    print("pushCommentNotification -> $e");
  }
}

Future<void> pushRecommentNotification(String fcmToken, String commentDesc,
    String reCommentWriter, String reCommentDesc) async {
  try {
    await dotenv.load(fileName: ".env");

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'key=${dotenv.env["CLOUD_MESSAGING_SERVER_KEY"]}'
      },
      body: jsonEncode({
        'token': fcmToken,
        'data': {
          'type': 'comment',
        },
        'notification': {
          'title': commentDesc.length > 5
              ? '${commentDesc.substring(0, 5)}... 댓글에 $reCommentWriter님이 답글을 달았습니다.'
              : '$commentDesc 댓글에 $reCommentWriter님이 답글을 달았습니다.',
          'body': reCommentDesc.length > 10
              ? '${reCommentDesc.substring(0, 10)}...'
              : reCommentDesc,
        },
        'to': fcmToken,
      }),
    );
  } catch (e) {
    // ignore: avoid_print
    print("pushCommentNotification -> $e");
  }
}

Future<void> pushMedicationNotification(
    String fcmToken, String medication) async {
  try {
    await dotenv.load(fileName: ".env");
    final eulCheck = checkBottomConsonant(medication);

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'key=${dotenv.env["CLOUD_MESSAGING_SERVER_KEY"]}'
      },
      body: jsonEncode({
        'token': fcmToken,
        'data': {
          'type': 'medication',
        },
        'notification': {
          'title': '인지케어 복용 알림',
          'body': '$medication${eulCheck ? '을' : '를'} 복용할 시간입니다.',
        },
        'to': fcmToken,
      }),
    );
  } catch (e) {
    // ignore: avoid_print
    print("pushMedicationNotification -> $e");
  }
}

bool isBeforeTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
  if (time1.hour < time2.hour) {
    return true;
  } else if (time1.hour == time2.hour) {
    return time1.minute < time2.minute;
  }
  return false;
}

List<String> interatePreviousDays(int days) {
  List<String> dates = [];
  DateTime currentDate = DateTime.now();
  for (int i = 0; i < days; i++) {
    DateTime previousDate = currentDate.subtract(Duration(days: i));
    String formattedDate = DateFormat('yyyy-MM-dd').format(previousDate);
    dates.add(formattedDate);
  }
  return dates.reversed.toList();
}

bool checkBottomConsonant(String input) {
  return (input.runes.last - 0xAC00) % 28 != 0;
}

Future<void> initializeSupabase() async {
  try {
    final SupabaseClient initializeSupabase = Supabase.instance.client;
  } catch (e) {
    await Supabase.initialize(
      url: dotenv.env["SUPABASE_URL"]!,
      anonKey: dotenv.env["SUPABASE_ANONKEY"]!,
    );
  }
}
