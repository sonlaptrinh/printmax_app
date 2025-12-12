import 'package:dio/dio.dart';
import 'package:printmax_app/core/api_client.dart';

class AuthRepository {
  Future<String> login({required String username, required String password}) async {
    // Adjust endpoint/body to match your VPS API
    final Response res = await ApiClient.instance.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    final data = res.data;
    if (data is Map && data['token'] is String) {
      return data['token'] as String;
    }
    throw Exception('Đăng nhập thất bại: thiếu token');
  }
}

