class Meme {
  final String? title;
  String? postLink;
  String? subreddit;
  String? url;
  bool? nsfw;
  bool? spoiler;
  String? author;
  int? ups;
  List<String>? preview;

  Meme({
    this.title,
    this.postLink,
    this.subreddit,
    this.url,
    this.nsfw,
    this.spoiler,
    this.author,
    this.ups,
    this.preview,
  });

  factory Meme.fromJson(Map<String, dynamic> json) {
    return Meme(
      title: json['title'] as String?,
      postLink: json['postLink'] as String?,
      subreddit: json['subreddit'] as String?,
      url: json['url'] as String?,
      nsfw: json['nsfw'] as bool?,
      spoiler: json['spoiler'] as bool?,
      author: json['author'] as String?,
      ups: json['ups'] as int?,
      preview: (json['preview'] as List?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postLink'] = postLink;
    data['subreddit'] = subreddit;
    data['title'] = title;
    data['url'] = url;
    data['nsfw'] = nsfw;
    data['spoiler'] = spoiler;
    data['author'] = author;
    data['ups'] = ups;
    data['preview'] = preview;
    return data;
  }
}
