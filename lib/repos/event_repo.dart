import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:injicare_event_security/constants/http.dart';
import 'package:injicare_event_security/models/photo_image_model.dart';
import 'package:injicare_event_security/models/quiz_answer_model.dart';
import 'package:injicare_event_security/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class EventRepository {
  final _supabase = Supabase.instance.client;
  // static final pointEventFunctions = Uri.parse(
  //     "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/point-event-functions");
  // static final eventUserPointFunctions = Uri.parse(
  //     "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/event-user-point-functions-2");

  static final eventUserTargetScoreFunctions = Uri.parse(
      "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/event-user-targetscore-functions-5");
  static final eventUserMultipleScoresFunctions = Uri.parse(
      "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/event-user-multiplescores-functions-5");
  static final eventUserCountFunctions = Uri.parse(
      "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/event-user-count-functions-4");

  Future<Map<String, dynamic>> getEventUserTargetScore(
    int startSeconds,
    int endSeconds,
    int stepPoint,
    int invitationPoint,
    int diaryPoint,
    int commentPoint,
    int likePoint,
    int quizPoint,
    int targetScore,
    int maxStepCount,
    int maxCommentCount,
    int maxLikeCount,
    int maxInvitationCount,
    String userId,
    String invitationType,
  ) async {
    Map<String, dynamic> requestBody = {
      'userId': userId,
      'startSeconds': startSeconds,
      'endSeconds': endSeconds,
      'stepPoint': stepPoint,
      'invitationPoint': invitationPoint,
      'diaryPoint': diaryPoint,
      'commentPoint': commentPoint,
      'likePoint': likePoint,
      "quizPoint": quizPoint,
      'targetScore': targetScore,
      'maxStepCount': maxStepCount,
      'maxCommentCount': maxCommentCount,
      'maxLikeCount': maxLikeCount,
      'maxInvitationCount': maxInvitationCount,
      'invitationType': invitationType,
    };
    String requestBodyJson = jsonEncode(requestBody);
    final headers = await tokenHeaders();

    final response = await http.post(
      eventUserTargetScoreFunctions,
      body: requestBodyJson,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      return data["data"];
    }

    return {};
  }

  Future<Map<String, dynamic>> getEventUserMultipleScores(
    int startSeconds,
    int endSeconds,
    int stepPoint,
    int invitationPoint,
    int diaryPoint,
    int commentPoint,
    int likePoint,
    int quizPoint,
    int targetScore,
    int maxStepCount,
    int maxCommentCount,
    int maxLikeCount,
    int maxInvitationCount,
    String userId,
    String invitationType,
  ) async {
    Map<String, dynamic> requestBody = {
      'userId': userId,
      'startSeconds': startSeconds,
      'endSeconds': endSeconds,
      'stepPoint': stepPoint,
      'invitationPoint': invitationPoint,
      'diaryPoint': diaryPoint,
      'commentPoint': commentPoint,
      'likePoint': likePoint,
      "quizPoint": quizPoint,
      'targetScore': targetScore,
      'maxStepCount': maxStepCount,
      'maxCommentCount': maxCommentCount,
      'maxLikeCount': maxLikeCount,
      'maxInvitationCount': maxInvitationCount,
      'invitationType': invitationType,
    };
    String requestBodyJson = jsonEncode(requestBody);
    final headers = await tokenHeaders();

    final response = await http.post(
      eventUserMultipleScoresFunctions,
      body: requestBodyJson,
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data["data"];
    }

    return {};
  }

  Future<Map<String, dynamic>> getEventUserCount(
    int startSeconds,
    int endSeconds,
    int invitationCount,
    int diaryCount,
    int commentCount,
    int likeCount,
    int quizCount,
    int maxCommentCount,
    int maxLikeCount,
    int maxInvitationCount,
    String userId,
    String invitationType,
  ) async {
    Map<String, dynamic> requestBody = {
      'userId': userId,
      'startSeconds': startSeconds,
      'endSeconds': endSeconds,
      'invitationCount': invitationCount,
      'diaryCount': diaryCount,
      'commentCount': commentCount,
      'likeCount': likeCount,
      'quizCount': quizCount,
      'maxCommentCount': maxCommentCount,
      'maxLikeCount': maxLikeCount,
      'maxInvitationCount': maxInvitationCount,
      'invitationType': invitationType,
    };
    String requestBodyJson = jsonEncode(requestBody);
    final headers = await tokenHeaders();

    final response = await http.post(
      eventUserCountFunctions,
      body: requestBodyJson,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      return data["data"];
    }

    return {};
  }

  Future<List<String>> fetchContractRegionAdminUserIds(
      String contractRegionId) async {
    final data = await _supabase
        .from("contract_regions_admins")
        .select('userId')
        .eq('contractRegionId', contractRegionId);
    return data.map((e) => e["userId"]).cast<String>().toList();
  }

  Future<List<String>> fetchCommunityAdminUserIds(
      String contractRegionId) async {
    final data = await _supabase
        .from("contract_communities_admins")
        .select('userId')
        .eq('contractRegionId', contractRegionId);
    return data.map((e) => e["userId"]).cast<String>().toList();
  }

  Future<List<Map<String, dynamic>>> fetchUserRegionEventsDB(
      String userContractRegionId) async {
    final contractData = await _supabase
        .from("events")
        .select('*, contract_regions!inner(*)')
        .eq('contractRegionId', userContractRegionId)
        .eq('allUsers', false)
        .order('createdAt', ascending: true);
    return contractData;
  }

  Future<List<Map<String, dynamic>>> fetchUserVideosDB(
      String userContractRegionId) async {
    final contractData = await _supabase
        .from("videos")
        .select('*, contract_regions!inner(*)')
        .eq('contractRegionId', userContractRegionId)
        .eq('allUsers', false)
        .order('createdAt', ascending: true);
    return contractData;
  }

  Future<List<Map<String, dynamic>>> fetchAllUsersEventsDB() async {
    final allUserEvents = await _supabase
        .from("events")
        .select('*, contract_regions(*)')
        .eq('allUsers', true)
        .order('createdAt', ascending: true);
    return allUserEvents;
  }

  Future<Map<String, dynamic>> fetchCertainEvent(String eventId) async {
    final data = await _supabase
        .from("events")
        .select("*, quiz_event_db(*)")
        .eq("eventId", eventId)
        .single();
    return data;
  }

  Future<List<Map<String, dynamic>>> fetchAllUsersVideosDB() async {
    final data = await _supabase
        .from("videos")
        .select('*, contract_regions(*)')
        .eq('allUsers', true)
        .order('createdAt', ascending: true);
    return data;
  }

  Future<int> fetchAllParticipantsCount(String eventId) async {
    try {
      final data = await _supabase
          .from("event_participants")
          .select('*')
          .eq('eventId', eventId);

      return data.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> checkMyParticiapationEvent(
      String eventId, String userId) async {
    try {
      final data = await _supabase
          .from("event_participants")
          .select('*')
          .eq('eventId', eventId)
          .eq('userId', userId);

      return data;
    } catch (e) {
      return [];
    }
  }

  Future<void> deletePariticipant() async {
    await _supabase
        .from("event_participants")
        .delete()
        .match({"eventId": "fae6c5b5-a0de-4472-add7-3851579dfc88"});
  }

  Future<int> checkParticipantsCount(String eventId) async {
    try {
      final res = await _supabase
          .from("event_participants")
          .select('userId')
          .count(CountOption.exact);
      return res.count;
    } catch (e) {
      return 0;
    }
  }

  Future<void> pariticipateEvent(String userId, String eventId) async {
    final existing = await _supabase
        .from("event_participants")
        .select('eventId')
        .eq("eventId", eventId)
        .eq("userId", userId);

    if (existing.isEmpty) {
      final participation = {
        "eventId": eventId,
        "userId": userId,
        "createdAt": getCurrentSeconds(),
      };
      await _supabase.from("event_participants").upsert(
            participation,
            onConflict: 'eventId,userId',
            ignoreDuplicates: true,
          );
    }
  }

  // Future<List<dynamic>> getEventUserScore(
  //   int startSeconds,
  //   int endSeconds,
  //   int stepPoint,
  //   int diaryPoint,
  //   int commentPoint,
  //   int likePoint,
  //   String userId,
  // ) async {
  //   Map<String, dynamic> requestBody = {
  //     'userId': userId,
  //     'startSeconds': startSeconds,
  //     'endSeconds': endSeconds,
  //     'stepPoint': stepPoint,
  //     'diaryPoint': diaryPoint,
  //     'commentPoint': commentPoint,
  //     'likePoint': likePoint,
  //   };
  //   String requestBodyJson = jsonEncode(requestBody);

  //   final response = await http.post(
  //     pointEventFunctions,
  //     body: requestBodyJson,
  //     headers: headers,
  //   );

  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
  //     return data["data"];
  //   }

  //   return [];
  // }

  Future<String> convertContractRegionIdToName(String contractRegionId) async {
    if (contractRegionId != "") {
      final data = await _supabase
          .from('contract_regions')
          .select('*, subdistricts(*)')
          .eq('contractRegionId', contractRegionId)
          .single();

      return data["subdistricts"]["subdistrict"];
    }
    return "-";
  }

  Future<int> userInvitationCount(
      int startSeconds, int endSeconds, String userId) async {
    final data = await _supabase
        .from("invitation")
        .select('*')
        .eq('userId', userId)
        .gte('createdAt', startSeconds)
        .lte('createdAt', endSeconds);
    return data.length;
  }

  Future<int> userDiaryCount(
      int startSeconds, int endSeconds, String userId) async {
    final data = await _supabase
        .from("diaries")
        .select('*')
        .eq('userId', userId)
        .gte('createdAt', startSeconds)
        .lte('createdAt', endSeconds);
    return data.length;
  }

  Future<int> userCommnetCount(
      int startSeconds, int endSeconds, String userId) async {
    final data = await _supabase
        .from("comments")
        .select('*')
        .eq('userId', userId)
        .gte('createdAt', startSeconds)
        .lte('createdAt', endSeconds);
    return data.length;
  }

  Future<int> userLikeCount(
      int startSeconds, int endSeconds, String userId) async {
    final data = await _supabase
        .from("likes")
        .select('*')
        .eq('userId', userId)
        .gte('createdAt', startSeconds)
        .lte('createdAt', endSeconds);
    return data.length;
  }

  //  final res = await _supabase
  //       .from("contract_regions")
  //       .select('*')
  //       .eq('subdistrictId', userSubdistrictId)
  //       .count(CountOption.exact);

  //   return res.count != 0;

  Future<bool> userSubmitEventGiftOrNot(String userId, String eventId) async {
    final data = await _supabase
        .from("event_participants")
        .select('*')
        .eq('userId', userId)
        .eq('eventId', eventId)
        .eq('gift', true)
        .count(CountOption.exact);
    return data.count != 0;
  }

  Future<int> getEventUserNumbers(String eventId) async {
    final data = await _supabase
        .from("event_participants")
        .select('*')
        .eq('eventId', eventId)
        .eq('gift', true)
        .count(CountOption.exact);
    return data.count;
  }

  Future<void> submitEventGift(String userId, String eventId) async {
    try {
      await _supabase
          .from("event_participants")
          .update({"gift": true}).match({"userId": userId, "eventId": eventId});
    } catch (e) {
      // ignore: avoid_print
      print("submitEventGift -> $e");
    }
  }

  // quiz-event
  Future<List<Map<String, dynamic>>> checkMyParticiapationQuizEvent(
      String eventId, String userId) async {
    try {
      final data = await _supabase
          .from("quiz_event_answers")
          .select('*')
          .eq('eventId', eventId)
          .eq('userId', userId);

      return data;
    } catch (e) {
      // ignore: avoid_print
      print("checkMyParticiapationQuizEvent -> $e");
    }
    return [];
  }

  Future<void> saveQuizEventAnswer(QuizAnswerModel model) async {
    try {
      await _supabase.from("quiz_event_answers").insert(model.toJson());
    } catch (e) {
      // ignore: avoid_print
      print("saveQuizEventAnswer -> $e");
    }
  }

  Future<int> checkParticipantsQuizCount(String eventId) async {
    try {
      final res = await _supabase
          .from("quiz_event_answers")
          .select('userId')
          .count(CountOption.exact);
      return res.count;
    } catch (e) {
      return 0;
    }
  }

  Future<int> fetchAllParticipantsQuizCount(String eventId) async {
    try {
      final data = await _supabase
          .from("quiz_event_answers")
          .select('*')
          .eq('eventId', eventId);
      return data.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<dynamic>> fetchCertainQuizEventAnswers(String eventId) async {
    final data = await _supabase
        .from("quiz_event_answers")
        .select('*, users(name)')
        .eq("eventId", eventId)
        .order("createdAt", ascending: true);
    return data;
  }

  // photo-event
  Future<String> uploadPhotoImageToStorage(
      XFile photoImage, String eventId, String userId) async {
    try {
      final uuid = const Uuid().v4();
      final avatarBytes = await photoImage.readAsBytes();
      final fileStoragePath = '$eventId/$userId/$uuid';
      await _supabase.storage
          .from("photo_events")
          .uploadBinary(fileStoragePath, avatarBytes,
              fileOptions: const FileOptions(
                upsert: true,
              ));

      final fileUrl =
          _supabase.storage.from("photo_events").getPublicUrl(fileStoragePath);

      if (fileUrl.isEmpty) {
// Common causes: bucket not public, wrong path, RLS/policy blocks, etc.
        throw Exception('Public URL is empty. Check bucket policy & path.');
      }

      return fileUrl;
    } catch (e) {
      // ignore: avoid_print
      print("uploadPhotoImageToStorage -> $e");
    }
    return "";
  }

  Future<List<Map<String, dynamic>>> checkMyParticiapationPhotoEvent(
      String eventId, String userId) async {
    try {
      final data = await _supabase
          .from("photo_event_images")
          .select('*')
          .eq('eventId', eventId)
          .eq('userId', userId);

      return data;
    } catch (e) {
      // ignore: avoid_print
      print("checkMyParticiapationPhotoEvent -> $e");
    }
    return [];
  }

  Future<void> savePhotoEventAnswer(PhotoImageModel model) async {
    try {
      await _supabase.from("photo_event_images").insert(model.toJson());
    } catch (e) {
      // ignore: avoid_print
      print("savePhotoEventAnswer -> $e");
    }
  }

  Future<int> checkParticipantsPhotoEventCount(String eventId) async {
    try {
      final res = await _supabase
          .from("photo_event_images")
          .select('userId')
          .count(CountOption.exact);
      return res.count;
    } catch (e) {
      return 0;
    }
  }

  Future<int> fetchAllParticipantsPhotoEventCount(String eventId) async {
    try {
      final data = await _supabase
          .from("photo_event_images")
          .select('*')
          .eq('eventId', eventId);
      return data.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<dynamic>> fetchCertainPhotoEventImages(String eventId) async {
    final data = await _supabase
        .from("photo_event_images")
        .select('*, users(name)')
        .eq("eventId", eventId)
        .order("createdAt", ascending: true);
    return data;
  }
}

final eventRepo = Provider((ref) => EventRepository());
