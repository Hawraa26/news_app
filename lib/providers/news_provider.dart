import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../services/news_api_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsApiService _apiService = NewsApiService();

  static const Map<String, String> categories = {
    'general': 'عام',
    'business': 'أعمال',
    'entertainment': 'ترفيه',
    'health': 'صحة',
    'science': 'علوم',
    'sports': 'رياضة',
    'technology': 'تقنية',
  };

  List<Article> _articles = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  String _selectedCategory = 'general';
  String _searchQuery = '';
  bool _hasMore = true;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  bool get hasMore => _hasMore;

  Future<void> fetchInitialNews() async {
    _isLoading = true;
    _hasError = false;
    _hasMore = true;
    _currentPage = 1;
    notifyListeners();

    try {
      _articles = await _apiService.fetchNews(
        category: _selectedCategory,
        page: _currentPage,
      );
    } catch (e) {
      _hasError = true;
      _errorMessage = 'حدث خطأ:\n$e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreNews() async {
    if (!_hasMore || _isLoading) return;

    _currentPage++;
    try {
      final newArticles = await _apiService.fetchNews(
        category: _selectedCategory,
        page: _currentPage,
      );
      if (newArticles.isEmpty) {
        _hasMore = false;
      } else {
        _articles.addAll(newArticles);
      }
      notifyListeners();
    } catch (e) {
      _currentPage--;
      _hasMore = false;
      notifyListeners();
    }
  }

  void changeCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchInitialNews();
  }
  Future<void> searchNews(String query) async {
    if (query.trim().isEmpty) {
      await fetchInitialNews();
      return;
    }

    _searchQuery = query.trim();

    _isLoading = true;
    _hasError = false;
    _articles = [];

    notifyListeners();

    try {
      _articles = await _apiService.searchNews(
        query: _searchQuery,
        page: 1,
      );
    } catch (e) {
      _hasError = true;
      _errorMessage = 'تعذر البحث عن الأخبار، تحقق من الاتصال بالإنترنت';
    }

    _isLoading = false;
    notifyListeners();
  }
}