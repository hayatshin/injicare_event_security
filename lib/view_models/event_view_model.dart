import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injicare_event/models/contract_region_model.dart';
import 'package:injicare_event/models/event_model.dart';
import 'package:injicare_event/models/quiz_answer_model.dart';
import 'package:injicare_event/models/user_profile.dart';
import 'package:injicare_event/repos/authentication_repo.dart';
import 'package:injicare_event/repos/event_repo.dart';
import 'package:injicare_event/repos/region_repo.dart';
import 'package:injicare_event/utils.dart';

class EventViewModel extends AsyncNotifier<void> {
  late EventRepository _eventRepo;
  late AuthenticationRepository _authRepo;

  @override
  FutureOr<void> build() async {
    _authRepo = ref.read(authRepo);
    _eventRepo = ref.read(eventRepo);
  }

  Future<EventModel> updateUserScore(
      EventModel eventModel, String userId) async {
    try {
      List<Map<String, dynamic>> dbMyParticipation = await ref
          .read(eventRepo)
          .checkMyParticiapationEvent(eventModel.eventId, userId);

      final participatingAt =
          dbMyParticipation.isNotEmpty ? dbMyParticipation[0]["createdAt"] : 0;

      int startSeconds = convertStartDateStringToSeconds(eventModel.startDate);
      int userStartSeconds =
          participatingAt > startSeconds ? participatingAt : startSeconds;
      int endSeconds = convertEndDateStringToSeconds(eventModel.endDate);
      int participantsNumber =
          await _eventRepo.fetchAllParticipantsCount(eventModel.eventId);

      if (dbMyParticipation.isEmpty) {
        return eventModel.copyWith(
          participantsNumber: participantsNumber,
        );
      }

      if (eventModel.eventType == "targetScore") {
        final data = await _eventRepo.getEventUserTargetScore(
          userStartSeconds,
          endSeconds,
          eventModel.stepPoint,
          eventModel.invitationPoint,
          eventModel.diaryPoint,
          eventModel.commentPoint,
          eventModel.likePoint,
          eventModel.quizPoint,
          eventModel.targetScore,
          eventModel.maxStepCount ?? 10000,
          userId,
        );

        final scorePointModel = eventModel.copyWith(
          userStepPoint: data["userStepPoint"],
          userInvitationPoint: data["userInvitationPoint"],
          userDiaryPoint: data["userDiaryPoint"],
          userCommentPoint: data["userCommentPoint"],
          userLikePoint: data["userLikePoint"],
          userQuizPoint: data["userQuizPoint"],
          userTotalPoint: data["userTotalPoint"],
          userAchieveOrNot: data["userAchieveOrNot"],
          participantsNumber: participantsNumber,
        );
        return scorePointModel;
      } else if (eventModel.eventType == "multipleScores") {
        final data = await _eventRepo.getEventUserMultipleScores(
          userStartSeconds,
          endSeconds,
          eventModel.stepPoint,
          eventModel.invitationPoint,
          eventModel.diaryPoint,
          eventModel.commentPoint,
          eventModel.likePoint,
          eventModel.quizPoint,
          eventModel.targetScore,
          eventModel.maxStepCount ?? 10000,
          eventModel.maxCommentCount ?? 0,
          eventModel.maxLikeCount ?? 0,
          eventModel.maxInvitationCount ?? 0,
          userId,
        );

        final scorePointModel = eventModel.copyWith(
          userStepPoint: data["userStepPoint"],
          userInvitationPoint: data["userInvitationPoint"],
          userDiaryPoint: data["userDiaryPoint"],
          userCommentPoint: data["userCommentPoint"],
          userLikePoint: data["userLikePoint"],
          userQuizPoint: data["userQuizPoint"],
          userTotalPoint: data["userTotalPoint"],
          userAchieveOrNot: data["userAchieveOrNot"],
          participantsNumber: participantsNumber,
        );
        return scorePointModel;
      } else if (eventModel.eventType == "count") {
        final data = await _eventRepo.getEventUserCount(
          userStartSeconds,
          endSeconds,
          eventModel.invitationCount,
          eventModel.diaryCount,
          eventModel.commentCount,
          eventModel.likeCount,
          eventModel.quizCount,
          userId,
        );

        final scorePointModel = eventModel.copyWith(
          userInvitationCount: data["userInvitationCount"],
          userDiaryCount: data["userDiaryCount"],
          userCommentCount: data["userCommentCount"],
          userLikeCount: data["userLikeCount"],
          userQuizCount: data["userQuizCount"],
          userAchieveOrNot: data["userAchieveOrNot"],
          participantsNumber: participantsNumber,
        );
        return scorePointModel;
      }
    } catch (e) {
      // ignore: avoid_print
      print("updateUserScore -> $e");
    }
    return eventModel;
  }

  Future<List<EventModel>> fetchUserEvents(UserProfile userProfile) async {
    final allUsersEvents = await _eventRepo.fetchAllUsersEventsDB();
    final allUsersModels =
        allUsersEvents.map((e) => EventModel.fromJson(e)).toList();
    if (userProfile.subdistrictId != null) {
      final contractRegion = await ref
          .read(regionRepo)
          .fetchContractRegionData(userProfile.subdistrictId!);

      if (contractRegion.isNotEmpty) {
        // 계약한 경우
        ContractRegionModel contractRegionModel =
            ContractRegionModel.fromJson(contractRegion[0]);
        final contractRegionEvents = await _eventRepo
            .fetchUserRegionEventsDB(contractRegionModel.contractRegionId);
        final contractRegionModels =
            contractRegionEvents.map((e) => EventModel.fromJson(e)).toList();

        List<EventModel> filterModels = [];

        await Future.forEach(contractRegionModels, (event) async {
          if (event.adminSecret) {
            if (event.contractCommunityId == "") {
              // 지역 이벤트
              final adminUserIds = await _eventRepo
                  .fetchContractRegionAdminUserIds(event.contractRegionId!);
              if (adminUserIds.contains(userProfile.userId)) {
                filterModels.add(event);
              }
            } else {
              final adminUserIds = await _eventRepo
                  .fetchCommunityAdminUserIds(event.contractCommunityId!);
              if (adminUserIds.contains(userProfile.userId)) {
                filterModels.add(event);
              }
            }
          } else {
            if (event.contractCommunityId == "" ||
                event.contractCommunityId == userProfile.contractCommunityId) {
              filterModels.add(event);
            }
          }
        });

        // final filterRegionModels = contractRegionModels.where((e) {
        //   return e.contractCommunityId == "" ||
        //       e.contractCommunityId == userProfile.contractCommunityId;
        // }).toList();

        final totalEvents = [...allUsersModels, ...filterModels];
        totalEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return totalEvents;
      }
    }
    return allUsersEvents.map((e) => EventModel.fromJson(e)).toList();
  }

  Future<EventModel> fetchCertainEvent(String eventId) async {
    final data = await ref.read(eventRepo).fetchCertainEvent(eventId);
    return EventModel.fromJson(data);
  }

  Future<EventModel> updateUserQuizState(EventModel eventModel) async {
    int participantsNumber =
        await _eventRepo.fetchAllParticipantsQuizCount(eventModel.eventId);

    final updateEventModel = eventModel.copyWith(
      participantsNumber: participantsNumber,
    );

    return updateEventModel;
  }

  Future<List<QuizAnswerModel>> fetchCertainQuizEventAnswers(
      String eventId) async {
    try {
      final data =
          await ref.read(eventRepo).fetchCertainQuizEventAnswers(eventId);
      return data.map((e) => QuizAnswerModel.fromJson(e)).toList();
    } catch (e) {
      // ignore: avoid_print
      print("fetchCertainQuizEventAnswers -> $e");
    }
    return [];
  }
}

final eventProvider = AsyncNotifierProvider<EventViewModel, void>(
  () => EventViewModel(),
);
