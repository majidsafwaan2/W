import 'dart:convert';
import 'package:dependencies/dio/dio.dart';
import 'package:quran/data/models/detail_surah_dto.dart';
import 'package:quran/data/models/juz_dto.dart';
import 'package:quran/data/models/surah_dto.dart';
import 'package:resources/constant/api_constant.dart';

abstract class QuranRemoteDataSource {
  Future<List<SurahDTO>> getAllSurah();
  Future<DetailSurahDTO> getDetailSurah(int id);
  Future<JuzDTO> getJuz(int id);
}

class QuranRemoteDataSourceImpl extends QuranRemoteDataSource {
  final Dio dio;

  QuranRemoteDataSourceImpl({required this.dio});

  Map<String, dynamic> _parseResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is String) {
      return json.decode(data) as Map<String, dynamic>;
    } else {
      throw Exception('Unexpected response type: ${data.runtimeType}');
    }
  }

  @override
  Future<List<SurahDTO>> getAllSurah() async {
    try {
      final response = await dio.get('${ApiConstant.baseUrl}surah');
      final data = _parseResponse(response.data);
      return SurahResponseDTO.fromJson(data).data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DetailSurahDTO> getDetailSurah(int id) async {
    try {
      final response = await dio.get('${ApiConstant.baseUrl}surah/$id');
      final data = _parseResponse(response.data);
      return DetailSurahResponseDTO.fromJson(data).data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<JuzDTO> getJuz(int id) async {
    try {
      final response = await dio.get('${ApiConstant.baseUrl}juz/$id');
      final data = _parseResponse(response.data);
      return JuzResponseDTO.fromJson(data).data;
    } catch (e) {
      rethrow;
    }
  }
}
