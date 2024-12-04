import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'RecipesDetailPage.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> recipesWithScores = [];
  int amountRecipes = 0;

  @override
  void initState() {
    super.initState();
    _loadFavoritesWithScores();
  }

  Future<void> _loadFavoritesWithScores() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final favoriteCollection = _firestore.collection('favorite');
      final favoriteSnapshot =
          await favoriteCollection.where('user_id', isEqualTo: user.uid).get();

      List<Future<Map<String, dynamic>?>> recipeFutures =
          favoriteSnapshot.docs.map((favoriteDoc) async {
        final favoriteData = favoriteDoc.data();
        final recipeId = favoriteData['recipes_id'];

        final recipeSnapshot = await _firestore
            .collection('recipes')
            .where('recipes_id', isEqualTo: recipeId)
            .get();

        if (recipeSnapshot.docs.isEmpty) return null;

        final recipeData = recipeSnapshot.docs.first.data();

        final recipeRatingSnapshot = await _firestore
            .collection('recipeRating')
            .where('recipes_id', isEqualTo: recipeId)
            .get();

        double totalScore = 0;
        int ratingCount = 0;

        for (var ratingDoc in recipeRatingSnapshot.docs) {
          final askRatingId = ratingDoc['askRating_id'];
          final askRatingSnapshot =
              await _firestore.collection('askRating').doc(askRatingId).get();

          if (askRatingSnapshot.exists) {
            final avgScore = askRatingSnapshot.data()?['avgScore'] ?? 0.0;
            totalScore += avgScore;
            ratingCount++;
          }
        }

        final averageScore = ratingCount > 0 ? totalScore / ratingCount : 0.0;

        return {
          'recipes_id': recipeId,
          'name': recipeData['name'] ?? 'ไม่พบชื่อ',
          'image': recipeData['image'] ??
              "https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=",
          'avgScore': averageScore,
        };
      }).toList();

      final results = await Future.wait(recipeFutures);

      setState(() {
        recipesWithScores = results.whereType<Map<String, dynamic>>().toList();
        amountRecipes = recipesWithScores.length;
      });
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Widget _buildRecipeTile(Map<String, dynamic> item, int index) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: item['image'] != null && item['image'].isNotEmpty
              ? Image.network(
                  item['image'],
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=',
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                    );
                  },
                )
              : Image.network(
                  'https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=',
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                ),
          title: Text(item['name'], style: GoogleFonts.itim(fontSize: 23)),
          subtitle: Row(
            children: [
              const Icon(Icons.star, color: Colors.yellow, size: 24),
              Text(
                item['avgScore'].toStringAsFixed(1),
                style: GoogleFonts.itim(fontSize: 20),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, size: 30),
            color: Colors.red,
            onPressed: () {
              setState(() {
                recipesWithScores.removeAt(index);
                amountRecipes -= 1;
              });
              _removeFromFavorites(item['recipes_id']);
            },
          ),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipesDetailPage(
                  recipesId: item['recipes_id'],
                  name: item['name'],
                  imageUrl: item['image'] ??
                      "https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=",
                ),
              ),
            );
            if (result == true) {
              await _loadFavoritesWithScores();
            }
          },
        ),
      ),
    );
  }

  Future<void> _removeFromFavorites(int recipeId) async {
    final snapshot = await _firestore
        .collection('favorite')
        .where('recipes_id', isEqualTo: recipeId)
        .get();

    for (var doc in snapshot.docs) {
      await _firestore.collection('favorite').doc(doc.id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'รายการโปรด ($amountRecipes)',
            style: GoogleFonts.itim(
              textStyle: const TextStyle(color: Colors.white, fontSize: 26),
            ),
          ),
        ),
        backgroundColor: Colors.green,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.favorite, color: Colors.white),
          ),
        ],
      ),
      body: recipesWithScores.isEmpty
          ? const Center(child: Text('ไม่มีรายการโปรด'))
          : ListView.builder(
              itemCount: recipesWithScores.length,
              itemBuilder: (context, index) {
                final item = recipesWithScores[index];
                return _buildRecipeTile(item, index);
              },
            ),
    );
  }
}
