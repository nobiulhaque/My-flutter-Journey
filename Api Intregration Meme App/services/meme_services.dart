import 'package:flutter/material.dart';
import 'package:meme_app/models/meme_models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async'; // For TimeoutException

class MemeServices {
  // List of subreddits for more variety
  static final List<String> _subreddits = [
    'dankmemes',
    'memes',
    'wholesomememes',
    'funny',
    'me_irl',
    'comedyheaven',
    'PrequelMemes',
    'terriblefacebookmemes',
    'historymemes',
    'Animemes',
    'AdviceAnimals',
    'MemeEconomy',
    '2meirl4meirl',
    'teenagers',
    'funnyandsad',
    'okbuddyretard',
    'surrealmemes',
    'PewdiepieSubmissions',
    'boottoobig',
    'bonehurtingjuice',
    'starterpacks',
    'antimeme',
    'deepfriedmemes',
    'lotrmemes',
    'OTMemes',
    'raimimemes',
    'holup',
    'comedynecromancy',
    'memesITA',
    'IndianDankMemes',
    'DankMemesFromSite19',
  ];

  // Rate limiting and caching
  static DateTime? _lastFetchTime;
  static const Duration _minimumFetchInterval = Duration(seconds: 2);
  static Map<String, List<Meme>> _subredditCache = {};
  static const Duration _cacheDuration = Duration(minutes: 10);
  static DateTime? _lastCacheClearTime;

  // Picks a random subreddit for each fetch
  String _getRandomSubreddit() {
    final random = Random();
    return _subreddits[random.nextInt(_subreddits.length)];
  }

  // Clear old cache entries periodically
  void _clearOldCache() {
    final now = DateTime.now();
    if (_lastCacheClearTime == null || 
        now.difference(_lastCacheClearTime!) > _cacheDuration) {
      _subredditCache.clear();
      _lastCacheClearTime = now;
    }
  }

  // Check network connectivity
  Future<bool> _checkNetworkConnection(BuildContext context) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showError(context, 'No internet connection');
      return false;
    }
    return true;
  }

  // Show error message
  void _showError(BuildContext context, String message, {bool isWarning = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isWarning ? Colors.orange : Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => fetchMemes(context),
          ),
        ),
      );
    });
  }

  Future<List<Meme>?> fetchMemes(BuildContext context) async {
    // Check network first
    if (!await _checkNetworkConnection(context)) return null;

    // Check rate limiting
    if (_lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _minimumFetchInterval) {
      _showError(context, 'Please wait before fetching more memes', isWarning: true);
      return null;
    }

    _lastFetchTime = DateTime.now();
    _clearOldCache();

    const url = 'https://meme-api.com/gimme/100';
    final cacheKey = 'random_100';

    // Check cache first
    if (_subredditCache.containsKey(cacheKey)) {
      return _subredditCache[cacheKey];
    }

    try {
      final response = await http.get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Validate response structure
        if (data['memes'] == null || data['memes'] is! List) {
          throw Exception('Invalid API response format');
        }

        final memes = (data['memes'] as List)
            .map((memeData) => Meme.fromJson(memeData))
            .where((meme) => meme.url.isNotEmpty) // Filter out invalid memes
            .toList();

        if (memes.isEmpty) {
          throw Exception('No valid memes found in response');
        }

        // Cache the result
        _subredditCache[cacheKey] = memes;
        return memes;
      } else {
        throw Exception('API request failed with status: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      _showError(context, 'Network error: ${e.message}');
      return null;
    } on TimeoutException {
      _showError(context, 'Request timed out');
      return null;
    } on FormatException {
      _showError(context, 'Invalid response format');
      return null;
    } catch (e) {
      _showError(context, 'Failed to load memes: ${e.toString()}');
      return null;
    }
  }

  Future<List<Meme>?> fetchMemesFromSubreddit(
    BuildContext context,
    String subreddit,
  ) async {
    // Check network first
    if (!await _checkNetworkConnection(context)) return null;

    // Check rate limiting
    if (_lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _minimumFetchInterval) {
      _showError(context, 'Please wait before fetching more memes', isWarning: true);
      return null;
    }

    _lastFetchTime = DateTime.now();
    _clearOldCache();

    // If subreddit is empty, use a random one for more variety
    final sub = subreddit.isEmpty ? _getRandomSubreddit() : subreddit;
    final url = 'https://meme-api.com/gimme/$sub/50';
    final cacheKey = sub.toLowerCase();

    // Check cache first
    if (_subredditCache.containsKey(cacheKey)) {
      return _subredditCache[cacheKey];
    }

    try {
      final response = await http.get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Validate response structure
        if (data['memes'] == null || data['memes'] is! List) {
          throw Exception('Invalid API response format');
        }

        final memes = (data['memes'] as List)
            .map((memeData) => Meme.fromJson(memeData))
            .where((meme) => meme.url.isNotEmpty) // Filter out invalid memes
            .toList();

        if (memes.isEmpty) {
          throw Exception('No memes found in subreddit r/$sub');
        }

        // Cache the result
        _subredditCache[cacheKey] = memes;
        return memes;
      } else {
        throw Exception('API request failed with status: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      _showError(context, 'Network error: ${e.message}');
      return null;
    } on TimeoutException {
      _showError(context, 'Request timed out');
      return null;
    } on FormatException {
      _showError(context, 'Invalid response format');
      return null;
    } catch (e) {
      _showError(context, 'Failed to load memes from r/$sub: ${e.toString()}');
      return null;
    }
  }
}