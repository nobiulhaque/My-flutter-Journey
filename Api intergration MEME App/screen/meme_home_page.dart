import 'package:flutter/material.dart';
import 'package:meme_app/models/meme_models.dart';
import 'package:meme_app/widgets/meme_card.dart';
import 'package:meme_app/services/meme_services.dart';

class MemeHomePage extends StatefulWidget {
  const MemeHomePage({super.key});

  @override
  State<MemeHomePage> createState() => _MemeHomePageState();
}

class _MemeHomePageState extends State<MemeHomePage> {
  List<Meme> memes = [];
  bool isLoading = true;
  bool isFetchingMore = false;
  Color backgroundColor = Colors.white;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchMemes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchMemes({bool append = false}) async {
    final fetchMemes = await MemeServices().fetchMemes(context);
    print(fetchMemes);
    setState(() {
      if (fetchMemes != null) {
        if (append) {
          memes.addAll(fetchMemes);
        } else {
          memes = fetchMemes;
        }
      }
      isLoading = false;
      isFetchingMore = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isFetchingMore &&
        !isLoading) {
      setState(() {
        isFetchingMore = true;
      });
      fetchMemes(append: true);
    }
  }

  void updateBackgroundColor(Color color) {
    setState(() {
      backgroundColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MemeLT',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white, // Set loading spinner color to white
                ),
              )
            : memes.isEmpty
            ? Center(child: Text('No memes available'))
            : Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: memes.length,
                    itemBuilder: (context, index) {
                      final meme = memes[index];
                      return MemeCard(
                        title: meme.title ?? "No Title",
                        imageUrl: meme.url ?? "",
                        ups: meme.ups ?? 0,
                        postLink: meme.postLink ?? "",
                        oneColorExtracted: updateBackgroundColor,
                      );
                    },
                  ),
                  if (isFetchingMore)
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors
                              .white, // Set infinite scroll spinner to white
                        ),
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () {
          setState(() {
            isLoading = true;
          });
          fetchMemes();
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.refresh, color: Colors.white),
        tooltip: 'Refresh Memes',
      ),
    );
  }
}
