import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RecipeListPage(),
    );
  }
}

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

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});
  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  late Future<List<Recipe>> futureRecipes;

  @override
  void initState() {
    super.initState();
    futureRecipes = fetchRecipes();
  }

  Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/recipes'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> recipesJson = jsonData['recipes'];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipes')),
      body: FutureBuilder<List<Recipe>>(
        future: futureRecipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Lädt…'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Rezepte gefunden.'));
          } else {
            final recipes = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailPage(recipe: recipe),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recipe.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Image.network(recipe.image, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 8),
                          Text('Zutaten: ${recipe.ingredients.length}'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(recipe.rating.floor(), (_) => const Icon(Icons.star, color: Colors.amber, size: 16)),
                              if ((recipe.rating - recipe.rating.floor()) >= 0.5)
                                const Icon(Icons.star_half, color: Colors.amber, size: 16),
                              ...List.generate(
                                  5 - recipe.rating.ceil(), (_) => const Icon(Icons.star_border, color: Colors.amber, size: 16)),
                              const SizedBox(width: 8),
                              Text('(${recipe.reviewCount})', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    int fullStars = recipe.rating.floor();
    bool halfStar = (recipe.rating - fullStars) >= 0.5;

    return Scaffold(
      appBar: AppBar(title: Text(recipe.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Image.network(recipe.image, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text('Name: ${recipe.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          // Sterneanzeige
          Row(
            children: [
              ...List.generate(fullStars, (_) => const Icon(Icons.star, color: Colors.amber)),
              if (halfStar) const Icon(Icons.star_half, color: Colors.amber),
              ...List.generate(5 - fullStars - (halfStar ? 1 : 0), (_) => const Icon(Icons.star_border, color: Colors.amber)),
              const SizedBox(width: 8),
              Text('(${recipe.reviewCount} Bewertungen)'),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Zutaten:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          for (var ing in recipe.ingredients) Text('• $ing'),
          const SizedBox(height: 12),
          const Text('Anweisungen:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          for (int i = 0; i < recipe.instructions.length; i++)
            Text('${i + 1}. ${recipe.instructions[i]}'),
        ]),
      ),
    );
  }
}
