import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RecipesRatingPage extends StatefulWidget {
  final int recipesId;
  final String name;
  final String imageUrl;

  const RecipesRatingPage({
    super.key,
    required this.recipesId,
    required this.name,
    required this.imageUrl,
  });

  @override
  _RecipesRatingPageState createState() => _RecipesRatingPageState();
}

class _RecipesRatingPageState extends State<RecipesRatingPage> {
  int tasteRating = 0;
  int difficultyRating = 0;
  int presentationRating = 0;
  final TextEditingController commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadExistingRating();
  }

  Future<void> _loadExistingRating() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return; // ถ้ายังไม่ได้ล็อกอิน, ไม่ต้องดึงข้อมูล
    }

    // ดึงข้อมูลการให้คะแนนจาก recipeRating
    final recipeRatingDoc = await _firestore
        .collection('recipeRating')
        .where('recipes_id', isEqualTo: widget.recipesId)
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (recipeRatingDoc.docs.isNotEmpty) {
      // มีการให้คะแนนแล้ว
      final recipeRating = recipeRatingDoc.docs.first;
      final askRatingId = recipeRating['askRating_id'];

      // ดึงข้อมูลจาก askRating
      final askRatingDoc =
          await _firestore.collection('askRating').doc(askRatingId).get();

      if (askRatingDoc.exists) {
        final askRating = askRatingDoc.data();
        setState(() {
          tasteRating = askRating?['taste_rating'] ?? 0;
          difficultyRating = askRating?['difficult_rating'] ?? 0;
          presentationRating = askRating?['present_rating'] ?? 0;
          commentController.text = askRating?['comment'] ?? '';
        });
      }
    }
  }

  Future<void> submitRating() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to submit a rating.")),
      );
      return;
    }

    DateTime now = DateTime.now();
    final String formattedDate =
        '${DateFormat('dd-MM').format(now)}-${(now.year + 543)}';
    final String formattedTime = DateFormat('HH:mm:ss').format(now);

    try {
      // ตรวจสอบว่ามีการให้คะแนนอยู่แล้วใน askRating
      final askRatingQuery = await _firestore
          .collection('askRating')
          .where('user_id', isEqualTo: userId)
          .where('recipes_id', isEqualTo: widget.recipesId)
          .limit(1)
          .get();

      String askRatingId;
      if (askRatingQuery.docs.isNotEmpty) {
        // มีข้อมูลอยู่แล้ว, อัปเดต
        askRatingId = askRatingQuery.docs.first.id;
        await _firestore.collection('askRating').doc(askRatingId).update({
          'qTaste_rating': "รสชาติอาหาร",
          'qDifficult_rating': "ความง่ายในการทำ",
          'qPresent_rating': "การนำเสนอ",
          'taste_rating': tasteRating,
          'difficult_rating': difficultyRating,
          'present_rating': presentationRating,
          'avgScore': (tasteRating + difficultyRating + presentationRating) / 3,
          'comment': commentController.text,
        });
      } else {
        // ไม่มีข้อมูล, สร้างใหม่
        final askRatingRef = await _firestore.collection('askRating').add({
          'user_id': userId,
          'recipes_id': widget.recipesId,
          'qTaste_rating': "รสชาติอาหาร",
          'qDifficult_rating': "ความง่ายในการทำ",
          'qPresent_rating': "การนำเสนอ",
          'taste_rating': tasteRating,
          'difficult_rating': difficultyRating,
          'present_rating': presentationRating,
          'avgScore': (tasteRating + difficultyRating + presentationRating) / 3,
          'comment': commentController.text,
        });
        askRatingId = askRatingRef.id;
      }

      // ตรวจสอบว่ามีการให้คะแนนอยู่แล้วใน recipeRating หรือไม่
      final recipeRatingDoc = await _firestore
          .collection('recipeRating')
          .where('recipes_id', isEqualTo: widget.recipesId)
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (recipeRatingDoc.docs.isEmpty) {
        // ไม่มีการให้คะแนนเลย, สร้างใหม่
        await _firestore.collection('recipeRating').add({
          'recipes_id': widget.recipesId,
          'user_id': userId,
          'date': formattedDate,
          'time': formattedTime,
          'askRating_id': askRatingId,
        });
      } else {
        // ถ้ามีการให้คะแนนอยู่แล้ว, อัปเดต
        await _firestore
            .collection('recipeRating')
            .doc(recipeRatingDoc.docs.first.id)
            .update({
          'date': formattedDate,
          'time': formattedTime,
          'askRating_id': askRatingId,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("การให้คะแนนสูตรอาหารสำเร็จแล้ว!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  widget.imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      widget.name,
                      style: GoogleFonts.itim(
                        textStyle: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            buildRatingSection("รสชาติอาหาร", "ไม่อร่อย", "อร่อยมาก",
                (rating) => setState(() => tasteRating = rating)),
            buildRatingSection("ความยากในการทำ", "ยากมาก", "ง่ายมาก",
                (rating) => setState(() => difficultyRating = rating)),
            buildRatingSection("การนำเสนออาหาร", "นำเสนอแย่", "นำเสนอดีมาก",
                (rating) => setState(() => presentationRating = rating)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: "แสดงความคิดเห็น",
                  labelStyle: GoogleFonts.itim(),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: submitRating,
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(350, 50)),
                  backgroundColor: WidgetStateProperty.all(Colors.green),
                ),
                child: Text(
                  'ให้คะแนน',
                  style: GoogleFonts.itim(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget buildRatingSection(String title, String minLabel, String maxLabel,
      void Function(int) onRatingSelected) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.itim(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel,
                  style: GoogleFonts.itim(),
                ),
                Text(
                  maxLabel,
                  style: GoogleFonts.itim(),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color: (index < getRatingValue(title))
                          ? Colors.yellow
                          : Colors.grey,
                      size: 58,
                    ),
                    onPressed: () {
                      onRatingSelected(index + 1);
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int getRatingValue(String title) {
    switch (title) {
      case "รสชาติอาหาร":
        return tasteRating;
      case "ความยากในการทำ":
        return difficultyRating;
      case "การนำเสนออาหาร":
        return presentationRating;
      default:
        return 0;
    }
  }
}
