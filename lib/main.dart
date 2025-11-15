import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'recipe.dart';
import 'RecipeDetailPage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RecipeListPage(),
    );
  }
}

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  late Future<List<Recipe>> recipes;

  @override
  void initState() {
    super.initState();
    recipes = fetchRecipes();
  }

  Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse("https://dummyjson.com/recipes"));
    final data = jsonDecode(response.body);

    List list = data["recipes"];
    List<Recipe> result = [];

    for (int i = 0; i < list.length; i++) {
      result.add(Recipe.fromJson(list[i]));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rezepte")),
      body: FutureBuilder(
        future: recipes,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Recipe> list = snapshot.data!;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final recipe = list[i];

              return ListTile(
                title: Text(recipe.name),
                leading: Image.network(
                  recipe.image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                subtitle: Text("Rating: ${recipe.rating}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailPage(recipe: recipe),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


