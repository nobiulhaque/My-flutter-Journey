class Meme {
  final String postlink;
  final String subreddit;
  final String title;
  final String url;
  final bool nsfw;
  final bool spoiler;
  final String author;
  final int ups;
  final List<String> preview;
  final DateTime? createdUtc;
  final int numComments;

  Meme({
    required this.postlink,
    required this.subreddit,
    required this.title,
    required this.url,
    required this.nsfw,
    required this.spoiler,
    required this.author,
    required this.ups,
    required this.preview,
    this.createdUtc,
    this.numComments = 0,
  });

  factory Meme.fromJson(Map<String, dynamic> json) {
    return Meme(
      postlink: json['postlink'] ?? '',
      subreddit: json['subreddit'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      nsfw: json['over_18'] ?? false,
      spoiler: json['spoiler'] ?? false,
      author: json['author'] ?? '',
      ups: json['ups'] ?? 0,
      createdUtc: json['created_utc'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['created_utc'] * 1000)
          : null,
      numComments: json['num_comments'] ?? 0,
      preview: json['preview'] != null && json['preview'] is List
          ? (json['preview'] as List).map((e) => e['url'].toString()).toList()
          : [], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postlink': postlink,
      'subreddit': subreddit,
      'title': title,
      'url': url,
      'over_18': nsfw,
      'spoiler': spoiler,
      'author': author,
      'ups': ups,
      'preview': preview,
    };
  }
}
