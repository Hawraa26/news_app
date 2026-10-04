import 'dart:convert';
class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String url;
  final String source;
  final DateTime publishedAt;

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.source,
    required this.publishedAt,
  });


// معرّف فريد وآمن للمقال (مشفّر Base64 عشان نتجنب رموز ممنوعة بمسارات Firestore)
  String get id => base64Url.encode(utf8.encode(url));
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'بدون عنوان',
      description: json['description'] ?? 'لا يوجد وصف',
      imageUrl: json['urlToImage'] ?? '',
      url: json['url'] ?? '',
      source: json['source']?['name'] ?? 'مصدر غير معروف',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }
}