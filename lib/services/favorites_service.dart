import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/article_model.dart';

class FavoritesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // الحصول على معرّف المستخدم الحالي
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // مرجع مجموعة المفضلة الخاصة بالمستخدم الحالي
  CollectionReference<Map<String, dynamic>>? get _favoritesCollection {
    final userId = _userId;
    if (userId == null) return null;
    return _db.collection('users').doc(userId).collection('favorites');
  }

  // إضافة مقال للمفضلة
  Future<void> addFavorite(Article article) async {
    final collection = _favoritesCollection;
    if (collection == null) return;

    await collection.doc(article.id).set({
      'title': article.title,
      'description': article.description,
      'imageUrl': article.imageUrl,
      'url': article.url,
      'source': article.source,
      'publishedAt': article.publishedAt.toIso8601String(),
    });
  }

  // حذف مقال من المفضلة
  Future<void> removeFavorite(String articleId) async {
    final collection = _favoritesCollection;
    if (collection == null) return;

    await collection.doc(articleId).delete();
  }

  // بث مستمر بكل المفضلة الحالية (يتحدث تلقائيًا)
  Stream<List<Article>> get favoritesStream {
    final collection = _favoritesCollection;
    if (collection == null) return const Stream.empty();

    return collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Article(
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          url: data['url'] ?? '',
          source: data['source'] ?? '',
          publishedAt: DateTime.tryParse(data['publishedAt'] ?? '') ?? DateTime.now(),
        );
      }).toList();
    });
  }

  // التحقق هل مقال معين مفضّل أو لا (مرة وحدة، بدون بث مستمر)
  Future<bool> isFavorite(String articleId) async {
    final collection = _favoritesCollection;
    if (collection == null) return false;

    final doc = await collection.doc(articleId).get();
    return doc.exists;
  }
}