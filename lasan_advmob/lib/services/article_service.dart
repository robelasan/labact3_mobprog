import '../constants.dart';
import 'dart:convert';
import 'package:http/http.dart';

class ArticleService {
  List<dynamic> listData = [];
  Map<String, dynamic> mapData = {};

  Future<List> getAllArticle() async {
    Response response = await get(Uri.parse('$host/api/articles'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // Backend returns an object with an `articles` array
      if (decoded is Map && decoded['articles'] is List) {
        listData = List<dynamic>.from(decoded['articles'] as List);
      } else if (decoded is List) {
        listData = List<dynamic>.from(decoded);
      } else {
        listData = [];
      }
      return listData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map> createArticle(dynamic article) async {
    final response = await post(
      Uri.parse('$host/api/articles'),
      headers:  {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(article),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      mapData = jsonDecode(response.body);
      return mapData;
    } else {
      throw Exception(
        'Failed to create article: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<Map> updateArticle(String id, dynamic article) async {
    final response = await put(
      Uri.parse('$host/api/articles/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(article),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      mapData = jsonDecode(response.body);
      return mapData;
    } else {
      throw Exception(
        'Failed to update article: ${response.statusCode} ${response.body}',
      );
    }
  }
}
