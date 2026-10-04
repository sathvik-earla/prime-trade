import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story_item.dart';
import '../models/user_models.dart';

class StorageService extends ChangeNotifier {
  List<StoryItem> _stories = [];
  Set<String> _bookmarks = {};
  Set<String> _likes = {};
  Set<String> _purchasedStoryIds = {};
  List<PurchaseRecord> _purchaseRecords = [];
  Map<String, int> _readingProgress = {}; // storyId -> pageNumber

  List<StoryItem> get stories => _stories;
  Set<String> get bookmarks => _bookmarks;
  Set<String> get likes => _likes;
  Set<String> get purchasedStoryIds => _purchasedStoryIds;
  List<PurchaseRecord> get purchaseRecords => _purchaseRecords;
  Map<String, int> get readingProgress => _readingProgress;

  StorageService() {
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final storiesJson = prefs.getString('fivefriends_stories');
    if (storiesJson != null) {
      try {
        final list = jsonDecode(storiesJson) as List<dynamic>;
        _stories = list.map((item) => StoryItem.fromJson(item as Map<String, dynamic>)).toList();
      } catch (_) {
        _stories = _getInitialSampleStories();
      }
    } else {
      _stories = _getInitialSampleStories();
    }

    _bookmarks = (prefs.getStringList('fivefriends_bookmarks') ?? []).toSet();
    _likes = (prefs.getStringList('fivefriends_likes') ?? []).toSet();
    _purchasedStoryIds = (prefs.getStringList('fivefriends_purchases') ?? []).toSet();

    final recordsJson = prefs.getString('fivefriends_purchase_records');
    if (recordsJson != null) {
      try {
        final list = jsonDecode(recordsJson) as List<dynamic>;
        _purchaseRecords = list
            .map((item) => PurchaseRecord.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    final progressJson = prefs.getString('fivefriends_reading_progress');
    if (progressJson != null) {
      try {
        final map = jsonDecode(progressJson) as Map<String, dynamic>;
        _readingProgress = map.map((key, value) => MapEntry(key, value as int));
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> toggleBookmark(String storyId) async {
    if (_bookmarks.contains(storyId)) {
      _bookmarks.remove(storyId);
    } else {
      _bookmarks.add(storyId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('fivefriends_bookmarks', _bookmarks.toList());
    notifyListeners();
  }

  Future<void> toggleLike(String storyId) async {
    if (_likes.contains(storyId)) {
      _likes.remove(storyId);
    } else {
      _likes.add(storyId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('fivefriends_likes', _likes.toList());
    notifyListeners();
  }

  Future<void> addPurchaseRecord(PurchaseRecord record) async {
    _purchaseRecords.insert(0, record);
    _purchasedStoryIds.add(record.storyId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('fivefriends_purchases', _purchasedStoryIds.toList());
    await prefs.setString(
      'fivefriends_purchase_records',
      jsonEncode(_purchaseRecords.map((r) => r.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> saveStory(StoryItem story) async {
    final index = _stories.indexWhere((s) => s.id == story.id);
    if (index >= 0) {
      _stories[index] = story;
    } else {
      _stories.insert(0, story);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'fivefriends_stories',
      jsonEncode(_stories.map((s) => s.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> deleteStory(String storyId) async {
    _stories.removeWhere((s) => s.id == storyId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'fivefriends_stories',
      jsonEncode(_stories.map((s) => s.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> updateProgress(String storyId, int pageNumber) async {
    _readingProgress[storyId] = pageNumber;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fivefriends_reading_progress', jsonEncode(_readingProgress));
    notifyListeners();
  }

  List<StoryItem> _getInitialSampleStories() {
    return [
      const StoryItem(
        id: 'the-five-friends-vol-1',
        title: 'The Five Friends: Secret of the Golden Compass',
        subtitle: 'The debut tale of friendship, courage, and discovery',
        synopsis:
            'Join five adventurous young friends as they stumble upon a luminous compass beneath the ancient whisper tree. Together they embark on a journey that tests their loyalty and reveals the true magic of brotherhood.',
        authorName: 'Earlasathvik R.S.',
        authorEmail: 'earlasathvik.rs@gmail.com',
        type: 'storybook',
        genre: 'Adventure',
        ageRange: 'All Ages',
        coverImage: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&q=80&w=800',
        price: 199.0,
        freeSamplePages: 2,
        readingTimeMinutes: 12,
        featured: true,
        chapters: [
          Chapter(
            id: 'c1',
            pageNumber: 1,
            title: 'Under the Ancient Tree',
            content:
                'On a bright golden morning where the sun danced between emerald leaves, the five friends gathered at their secret hill. Leo, the curious explorer, noticed something glistening in the soft earth. "Come quick!" he called out to the group.',
            illustrationUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&q=80&w=800',
          ),
          Chapter(
            id: 'c2',
            pageNumber: 2,
            title: 'The Compass Awakens',
            content:
                'With eager hands, they wiped away the damp soil. It was an ornate brass compass, its needle glowing with a warm starlight hue. It didn\'t point North—it pointed straight toward the Whispering Woods.',
            illustrationUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&q=80&w=800',
          ),
          Chapter(
            id: 'c3',
            pageNumber: 3,
            title: 'The First Pledge',
            content:
                'Looking at each other, the five boys put their hands together in the center. "No matter what riddles lie ahead, we stick together," they promised. And with that, their greatest adventure began.',
          ),
        ],
      ),
    ];
  }
}
