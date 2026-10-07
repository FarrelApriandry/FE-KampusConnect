import 'dart:convert';
import 'package:http/http.dart' as http;

class DramaRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  DramaRemoteDataSource({required this.baseUrl, required this.client});

  Future<Map<String, dynamic>> getDramasRaw() async {
    final response = await client.get(Uri.parse('$baseUrl/api/dramas'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('HTTP Error Status: ${response.statusCode}');
    }
  }
}
