import 'package:flutter/material.dart';
import 'package:meme_app/models/meme_models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemeServices {
  Future<List<Meme>?> fetchMemes(BuildContext context) async {
    // List of meme subreddits for variety
    final subreddits = [
      'memes',
      'dankmemes',
      'wholesomememes',
      'funny',
      'me_irl',
      'AdviceAnimals',
      'MemeEconomy',
      'ComedyCemetery',
      'PrequelMemes',
      'terriblefacebookmemes',
    ];

    List<Meme> allMemes = [];

    try {
      for (final subreddit in subreddits) {
        final Uri url = Uri.parse('https://meme-api.com/gimme/$subreddit/10');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print(data); // <-- Add this line to see the actual response
          final memes = (data['memes'] as List)
              .map((meme) => Meme.fromJson(meme))
              .toList();
          allMemes.addAll(memes);
        }
      }
      allMemes.shuffle(); // Shuffle for randomness
      return allMemes;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching memes: $e')));
      return null;
    }
  }
}
