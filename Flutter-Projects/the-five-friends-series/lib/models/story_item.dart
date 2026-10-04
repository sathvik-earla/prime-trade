class Chapter {
  final String id;
  final int pageNumber;
  final String title;
  final String content;
  final String? illustrationUrl;
  final String? audioNarration;

  const Chapter({
    required this.id,
    required this.pageNumber,
    required this.title,
    required this.content,
    this.illustrationUrl,
    this.audioNarration,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'pageNumber': pageNumber,
        'title': title,
        'content': content,
        'illustrationUrl': illustrationUrl,
        'audioNarration': audioNarration,
      };

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json['id'] as String? ?? '',
        pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        illustrationUrl: json['illustrationUrl'] as String?,
        audioNarration: json['audioNarration'] as String?,
      );
}

class DocumentAttachment {
  final String fileName;
  final int fileSize;
  final String fileType;
  final String formatType;
  final String? fileData;

  const DocumentAttachment({
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.formatType,
    this.fileData,
  });

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'fileSize': fileSize,
        'fileType': fileType,
        'formatType': formatType,
        'fileData': fileData,
      };

  factory DocumentAttachment.fromJson(Map<String, dynamic> json) => DocumentAttachment(
        fileName: json['fileName'] as String? ?? '',
        fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
        fileType: json['fileType'] as String? ?? '',
        formatType: json['formatType'] as String? ?? 'pdf',
        fileData: json['fileData'] as String?,
      );
}

class StoryStats {
  final int reads;
  final int likes;
  final int bookmarks;
  final int purchases;
  final double rating;

  const StoryStats({
    this.reads = 0,
    this.likes = 0,
    this.bookmarks = 0,
    this.purchases = 0,
    this.rating = 5.0,
  });

  Map<String, dynamic> toJson() => {
        'reads': reads,
        'likes': likes,
        'bookmarks': bookmarks,
        'purchases': purchases,
        'rating': rating,
      };

  factory StoryStats.fromJson(Map<String, dynamic> json) => StoryStats(
        reads: (json['reads'] as num?)?.toInt() ?? 0,
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        bookmarks: (json['bookmarks'] as num?)?.toInt() ?? 0,
        purchases: (json['purchases'] as num?)?.toInt() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      );
}

class StoryItem {
  final String id;
  final String title;
  final String subtitle;
  final String synopsis;
  final String authorName;
  final String authorEmail;
  final String type; // 'storybook' | 'novel' | 'story' | 'comic' | 'audiobook'
  final String genre;
  final String ageRange;
  final String coverImage;
  final double price; // In INR (₹)
  final int freeSamplePages;
  final int readingTimeMinutes;
  final String status;
  final bool featured;
  final List<Chapter> chapters;
  final StoryStats stats;
  final DocumentAttachment? documentFile;

  const StoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.synopsis,
    required this.authorName,
    required this.authorEmail,
    required this.type,
    required this.genre,
    required this.ageRange,
    required this.coverImage,
    required this.price,
    this.freeSamplePages = 1,
    this.readingTimeMinutes = 5,
    this.status = 'published',
    this.featured = false,
    required this.chapters,
    this.stats = const StoryStats(),
    this.documentFile,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'synopsis': synopsis,
        'authorName': authorName,
        'authorEmail': authorEmail,
        'type': type,
        'genre': genre,
        'ageRange': ageRange,
        'coverImage': coverImage,
        'price': price,
        'freeSamplePages': freeSamplePages,
        'readingTimeMinutes': readingTimeMinutes,
        'status': status,
        'featured': featured,
        'chapters': chapters.map((c) => c.toJson()).toList(),
        'stats': stats.toJson(),
        'documentFile': documentFile?.toJson(),
      };

  factory StoryItem.fromJson(Map<String, dynamic> json) => StoryItem(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        synopsis: json['synopsis'] as String? ?? '',
        authorName: json['authorName'] as String? ?? '',
        authorEmail: json['authorEmail'] as String? ?? '',
        type: json['type'] as String? ?? 'storybook',
        genre: json['genre'] as String? ?? 'Adventure',
        ageRange: json['ageRange'] as String? ?? 'All Ages',
        coverImage: json['coverImage'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        freeSamplePages: (json['freeSamplePages'] as num?)?.toInt() ?? 1,
        readingTimeMinutes: (json['readingTimeMinutes'] as num?)?.toInt() ?? 5,
        status: json['status'] as String? ?? 'published',
        featured: json['featured'] as bool? ?? false,
        chapters: (json['chapters'] as List<dynamic>?)
                ?.map((c) => Chapter.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [],
        stats: json['stats'] != null
            ? StoryStats.fromJson(json['stats'] as Map<String, dynamic>)
            : const StoryStats(),
        documentFile: json['documentFile'] != null
            ? DocumentAttachment.fromJson(json['documentFile'] as Map<String, dynamic>)
            : null,
      );
}
