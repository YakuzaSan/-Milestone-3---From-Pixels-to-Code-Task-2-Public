// -----------------------------------------------------
// DETAIL PAGE
// -----------------------------------------------------
import 'package:flutter/material.dart';
import 'recipe.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    int full = recipe.rating.floor();
    bool half = (recipe.rating - full) >= 0.5;
    int empty = 5 - full - (half ? 1 : 0);

    return Scaffold(
      appBar: AppBar(title: Text(recipe.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe.image,
                width: 200, height: 200, fit: BoxFit.cover),

            const SizedBox(height: 16),

            // Sterne ganz einfach
            Row(
              children: [
                for (int i = 0; i < full; i++)
                  const Icon(Icons.star, color: Colors.amber),
                if (half) const Icon(Icons.star_half, color: Colors.amber),
                for (int i = 0; i < empty; i++)
                  const Icon(Icons.star_border, color: Colors.amber),
              ],
            ),

            const SizedBox(height: 20),

            // Zutaten
            const Text("Zutaten:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            for (int i = 0; i < recipe.ingredients.length; i++)
              Text("• ${recipe.ingredients[i]}"),

            const SizedBox(height: 20),

            // Anweisungen
            const Text("Anweisungen:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            for (int i = 0; i < recipe.instructions.length; i++)
              Text("${i + 1}. ${recipe.instructions[i]}"),
          ],
        ),
      ),
    );
  }
}