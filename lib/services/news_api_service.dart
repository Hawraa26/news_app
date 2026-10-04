import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/article_model.dart';

class NewsApiService {
  static final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

  static const String _baseUrl = 'https://newsapi.org/v2';

  // جلب الأخبار حسب التصنيف
  Future<List<Article>> fetchNews({
    String category = 'general',
    int page = 1,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/top-headlines'
          '?country=us'
          '&category=$category'
          '&page=$page'
          '&pageSize=20'
          '&apiKey=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Status: ${response.statusCode}\n'
            'Body: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    final articlesJson = data['articles'] as List;

    return articlesJson
        .map((item) => Article.fromJson(item))
        .toList();
  }

  // البحث عن الأخبار
  Future<List<Article>> searchNews({
    required String query,
    int page = 1,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/everything'
          '?q=${Uri.encodeComponent(query)}'
          '&language=ar'
          '&page=$page'
          '&pageSize=20'
          '&apiKey=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Status: ${response.statusCode}\n'
            'Body: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    final articlesJson = data['articles'] as List;

    return articlesJson
        .map((item) => Article.fromJson(item))
        .toList();
  }
  Future<Article?> fetchLatestNews() async {
    final articles = await fetchNews(
      category: 'general',
      page: 1,
    );

    if (articles.isEmpty) {
      return null;
    }

    return articles.first;
  }
}