import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegionRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchRegionData() async {
    final regionList = await _supabase.from("districts").select('*');
    return regionList;
  }

  Future<List<Map<String, dynamic>>> fetchSmallRegionData(
      String districtId) async {
    try {
      final smallRegionList = await _supabase
          .from("subdistricts")
          .select('*')
          .eq('districtId', districtId);

      return smallRegionList;
    } catch (e) {
      // ignore: avoid_print
      print("fetchSmallRegionData: error -> $e");
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchCommunityData(
      String userSubdistrictId) async {
    final communityList = await _supabase
        .from("contract_communities")
        .select('*')
        .eq('subdistrictId', userSubdistrictId);
    return communityList;
  }

  Future<List<Map<String, dynamic>>> fetchContractRegionData(
      String userSubdistrictId) async {
    final data = await _supabase
        .from("contract_regions")
        .select('*, subdistricts(*)')
        .eq('subdistrictId', userSubdistrictId);

    return data;
  }
}

final regionRepo = Provider((ref) => RegionRepository());
