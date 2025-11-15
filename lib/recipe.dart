// recipe.dart
class Recipe {
  final int id;
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final String image;
  final double rating;
  final int reviewCount;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.image,
    required this.rating,
    required this.reviewCount,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      ingredients: List<String>.from(json['ingredients']),
      instructions: List<String>.from(json['instructions']),
      image: json['image'],
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'],
    );
  }
}
