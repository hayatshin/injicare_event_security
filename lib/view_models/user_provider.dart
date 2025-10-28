import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injicare_event_security/models/user_profile.dart';
import 'package:injicare_event_security/repos/authentication_repo.dart';

class UserProvider extends AsyncNotifier<void> {
  late final AuthenticationRepository _authRepo;

  @override
  FutureOr<void> build() {
    _authRepo = ref.read(authRepo);
  }

  Future<UserProfile> fetchLoggedUserInfo(String userId) async {
    final userData = await _authRepo.fetchLoggedUserInfoDB(userId);
    if (userData != null) {
      state = AsyncData(UserProfile.fromJson(userData));
      return UserProfile.fromJson(userData);
    } else {
      return UserProfile.empty();
    }
  }

  Future<UserProfile> fetchCertainUserProfile(String userId) async {
    final userData = await _authRepo.fetchCertinUserProfile(userId);
    if (userData != null) {
      state = AsyncData(UserProfile.fromJson(userData));
      return UserProfile.fromJson(userData);
    } else {
      return UserProfile.empty();
    }
  }

  Future<void> addUserProfile(
      Map<String, dynamic> userJson, String userId) async {
    await _authRepo.createProfileDB(userJson, userId);
  }

  Future<UserProfile> updateProfileUI(UserProfile userProfile) async {
    if (userProfile.userId != "") {
      await _authRepo.createProfileDB(userProfile.toJson(), userProfile.userId);
    }
    state = AsyncData(userProfile);
    return userProfile;
  }
}

final userProvider = AsyncNotifierProvider<UserProvider, void>(
  () => UserProvider(),
);
