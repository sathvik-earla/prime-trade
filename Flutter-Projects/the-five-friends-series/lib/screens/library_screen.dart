import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story_item.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../widgets/publishing_banner.dart';
import 'reader_screen.dart';
import 'checkout_screen.dart';
import 'owner_portal_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _searchQuery = '';
  String _selectedFormat = 'All';
  String _selectedGenre = 'All';

  final List<String> _formats = [
    'All',
    'storybook',
    'novel',
    'story',
    'comic',
    'audiobook',
    'poetry',
    'script',
  ];

  final List<String> _genres = [
    'All',
    'Adventure',
    'Bedtime',
    'Fantasy',
    'Mythology',
    'Sci-Fi',
  ];

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final auth = context.watch<AuthService>();

    final filteredStories = storage.stories.where((s) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = s.title.toLowerCase().contains(q) ||
            s.authorName.toLowerCase().contains(q) ||
            s.synopsis.toLowerCase().contains(q);
        if (!matches) return false;
      }
      if (_selectedFormat != 'All' && s.type != _selectedFormat) return false;
      if (_selectedGenre != 'All' && s.genre != _selectedGenre) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.auto_stories, color: Color(0xFFF59E0B), size: 24),
            SizedBox(width: 8),
            Text(
              'THE FIVE FRIENDS',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2),
            ),
          ],
        ),
        actions: [
          if (auth.currentOwner != null)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OwnerPortalScreen()),
                );
              },
              icon: const Icon(Icons.shield, color: Color(0xFF34D399), size: 16),
              label: const Text(
                'Owner',
                style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Sign Out',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Starting Banner with Hotline
          const PublishingBanner(isCompact: true),

          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search stories, authors, or genres...',
                hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFF59E0B)),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                ),
              ),
            ),
          ),

          // Format Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _formats.map((fmt) {
                final isSelected = _selectedFormat == fmt;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(fmt == 'All' ? 'All Formats' : fmt.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFormat = fmt);
                    },
                    selectedColor: const Color(0xFFF59E0B),
                    backgroundColor: const Color(0xFF0F172A),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF020617) : const Color(0xFF94A3B8),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Stories Grid / List
          Expanded(
            child: filteredStories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.menu_book, size: 56, color: Color(0xFF334155)),
                        SizedBox(height: 12),
                        Text(
                          'No books found',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredStories.length,
                    itemBuilder: (context, index) {
                      final story = filteredStories[index];
                      final isPurchased = storage.purchasedStoryIds.contains(story.id);
                      final isBookmarked = storage.bookmarks.contains(story.id);
                      final isLiked = storage.likes.contains(story.id);

                      return Card(
                        color: const Color(0xFF0F172A),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFF1E293B)),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReaderScreen(story: story),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cover Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    story.coverImage,
                                    width: 80,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 80,
                                      height: 110,
                                      color: const Color(0xFF1E293B),
                                      child: const Icon(Icons.book, color: Color(0xFFF59E0B)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        story.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'By ${story.authorName}',
                                        style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        story.synopsis,
                                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            isPurchased ? 'UNLOCKED' : '₹${story.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: isPurchased
                                                  ? const Color(0xFF34D399)
                                                  : const Color(0xFFF59E0B),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                                  color: isLiked ? Colors.redAccent : const Color(0xFF64748B),
                                                  size: 20,
                                                ),
                                                onPressed: () => storage.toggleLike(story.id),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                                  color: isBookmarked
                                                      ? const Color(0xFFF59E0B)
                                                      : const Color(0xFF64748B),
                                                  size: 20,
                                                ),
                                                onPressed: () => storage.toggleBookmark(story.id),
                                              ),
                                              if (!isPurchased && story.price > 0)
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => CheckoutScreen(story: story),
                                                      ),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFFF59E0B),
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Buy',
                                                    style: TextStyle(
                                                      color: Color(0xFF020617),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
