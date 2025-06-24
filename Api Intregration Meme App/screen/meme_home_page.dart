import 'package:flutter/material.dart';
import 'package:meme_app/widgets/meme_card.dart';
import 'package:meme_app/models/meme_models.dart';
import 'package:meme_app/services/meme_services.dart';

class MemeHomePage extends StatefulWidget {
  const MemeHomePage({super.key});

  @override
  State<MemeHomePage> createState() => _MemeHomePageState();
}

class _MemeHomePageState extends State<MemeHomePage> {
  final List<Meme> _memes = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasError = false;
  final ScrollController _scrollController = ScrollController();
  final MemeServices _memeService = MemeServices();

  @override
  void initState() {
    super.initState();
    _loadInitialMemes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialMemes() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final memesList = await _memeService.fetchMemesFromSubreddit(context, '');
      setState(() {
        _memes.clear();
        if (memesList != null) {
          _memes.addAll(memesList);
        }
        _hasError = memesList == null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreMemes() async {
    if (_isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    try {
      final memesList = await _memeService.fetchMemesFromSubreddit(context, '');
      setState(() {
        if (memesList != null) {
          _memes.addAll(memesList);
        }
      });
    } finally {
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore &&
        !_isLoading) {
      _loadMoreMemes();
    }
  }

  Widget _buildMemeList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _memes.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _memes.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final meme = _memes[index];
        return MemeCard(
          title: meme.title,
          imageUrl: meme.url,
          ups: meme.ups,
          postLink: meme.postlink,
          subreddit: meme.subreddit,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _hasError ? Icons.error_outline : Icons.sentiment_dissatisfied,
            size: 48,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            _hasError ? 'Failed to load memes' : 'No memes available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: _loadInitialMemes,
            child: Text(
              'Try Again',
              style: TextStyle(color: Colors.lightBlue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MemeIt',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialMemes,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue, Color.fromARGB(255, 43, 97, 190)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadInitialMemes,
          color: Colors.lightBlue,
          backgroundColor: Colors.white,
          child: Stack(
            children: [
              if (_isLoading && _memes.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (_memes.isEmpty)
                _buildEmptyState()
              else
                _buildMemeList(),
              if (!_isLoading && _memes.isNotEmpty)
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: FloatingActionButton(
                    backgroundColor: Colors.lightBlue,
                    elevation: 8,
                    onPressed: _loadMoreMemes,
                    child: const Icon(Icons.arrow_downward, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}