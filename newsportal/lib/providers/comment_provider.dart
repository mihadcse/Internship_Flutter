import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://hacker-news.firebaseio.com/v0/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

final singleCommentProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('item/$id.json');
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    } else {
      throw Exception('Failed to load comment $id');
    }
  } on DioException catch (e) {
    throw Exception('Dio error: ${e.message}');
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
});
