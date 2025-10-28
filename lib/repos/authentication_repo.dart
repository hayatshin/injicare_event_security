import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injicare_event_security/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class AuthenticationRepository {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> fetchLoggedUserInfoDB(String userId) async {
    try {
      final userData = await _supabase
          .from("users")
          .select('*, subdistricts(*), contract_communities(*)')
          .eq("userId", userId)
          .single();
      return userData;
    } catch (e) {
      // ignore: avoid_print
      print("fetchLoggedUserInfoDB -> $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchCertinUserProfile(String userId) async {
    try {
      final userData = await _supabase
          .from("users")
          .select('*, subdistricts(*), contract_communities(*)')
          .eq("userId", userId)
          .single();
      return userData;
    } catch (e) {
      // ignore: avoid_print
      print("fetchLoggedUserInfoDB -> $e");
    }
    return null;
  }

  Future<bool> checkUserExists(String certainUid) async {
    try {
      final userData = await _supabase
          .from("users")
          .select('*')
          .eq('userId', certainUid)
          .count(CountOption.exact);

      return userData.count != 0;
    } catch (e) {
      return false;
    }
  }

  Future<String> uploadAvatarToStorage(XFile avatar, String userId) async {
    try {
      final profilePath = userId;
      final objects =
          await _supabase.storage.from("avatars").list(path: profilePath);

      if (objects.isNotEmpty) {
        final fileList = objects.map((e) => "$profilePath/${e.name}").toList();
        await _supabase.storage.from("avatars").remove(fileList);
      }

      final avatarBytes = await avatar.readAsBytes();
      final milliseconds = currentKoreaDateTime().millisecondsSinceEpoch;
      final fileStoragePath = '$userId/$milliseconds';
      await _supabase.storage
          .from("avatars")
          .uploadBinary(fileStoragePath, avatarBytes,
              fileOptions: const FileOptions(
                upsert: true,
              ));

      final fileUrl =
          _supabase.storage.from("avatars").getPublicUrl(fileStoragePath);

      return fileUrl;
    } catch (e) {
      // ignore: avoid_print
      print("uploadAvatarToStorage -> $e");
    }
    return "";
  }

  Future<void> createProfileDB(
      Map<String, dynamic> userData, String userId) async {
    try {
      await _supabase.from("users").upsert(userData).select();
    } catch (e) {
      // ignore: avoid_print
      print("createProfileDB -> $e");
    }
  }
}

final authRepo = Provider((ref) => AuthenticationRepository());
