
class EducationModel {
  final String id;
  final String title;
  final String category;
  final String content;
  final String imageUrl;

  EducationModel({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.imageUrl,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'content': content,
      'imageUrl': imageUrl,
    };
  }
}
