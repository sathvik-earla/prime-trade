import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story_item.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class OwnerPortalScreen extends StatefulWidget {
  const OwnerPortalScreen({super.key});

  @override
  State<OwnerPortalScreen> createState() => _OwnerPortalScreenState();
}

class _OwnerPortalScreenState extends State<OwnerPortalScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _contentController = TextEditingController();
  final _customCoverController = TextEditingController();
  final _priceController = TextEditingController(text: '199');
  String _selectedType = 'storybook';
  String _selectedGenre = 'Adventure';
  int _freePages = 1;

  @override
  void initState() {
    super.initState();
    final owner = context.read<AuthService>().currentOwner;
    if (owner != null) {
      _authorController.text = owner.name;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _synopsisController.dispose();
    _contentController.dispose();
    _customCoverController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _publishStory() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a book title')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 199.0;
    final cover = _customCoverController.text.trim().isNotEmpty
        ? _customCoverController.text.trim()
        : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&q=80&w=800';

    final newStory = StoryItem(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: 'Published by ${_authorController.text.trim()}',
      synopsis: _synopsisController.text.trim().isNotEmpty
          ? _synopsisController.text.trim()
          : 'A new story in The Five Friends Series.',
      authorName: _authorController.text.trim().isNotEmpty
          ? _authorController.text.trim()
          : 'Earlasathvik R.S.',
      authorEmail: context.read<AuthService>().currentOwner?.email ?? 'earlasathvik.rs@gmail.com',
      type: _selectedType,
      genre: _selectedGenre,
      ageRange: 'All Ages',
      coverImage: cover,
      price: price,
      freeSamplePages: _freePages,
      readingTimeMinutes: 8,
      chapters: [
        Chapter(
          id: 'c1',
          pageNumber: 1,
          title: 'Chapter 1: The Beginning',
          content: _contentController.text.trim().isNotEmpty
              ? _contentController.text.trim()
              : 'Once upon a time in the world of The Five Friends...',
        ),
      ],
    );

    await context.read<StorageService>().saveStory(newStory);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully published "$title" to the bookstore!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<AuthService>().currentOwner;
    final storage = context.watch<StorageService>();

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('Owner Publishing Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Owner credentials badge
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF059669).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: Color(0xFF34D399), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          owner?.name ?? 'Publisher',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          owner?.role ?? 'Owner Access Granted',
                          style: const TextStyle(color: Color(0xFF34D399), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Publish New Book to Bookstore',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 14),

            // 1. Title & Author
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Book Title *',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _authorController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Author Name',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),

            // 2. Format & Genre
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Format Type',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'storybook', child: Text('Storybook')),
                      DropdownMenuItem(value: 'novel', child: Text('Novel')),
                      DropdownMenuItem(value: 'story', child: Text('Short Story')),
                      DropdownMenuItem(value: 'comic', child: Text('Comic')),
                      DropdownMenuItem(value: 'audiobook', child: Text('Audiobook')),
                    ],
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGenre,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Genre',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Adventure', child: Text('Adventure')),
                      DropdownMenuItem(value: 'Bedtime', child: Text('Bedtime')),
                      DropdownMenuItem(value: 'Fantasy', child: Text('Fantasy')),
                      DropdownMenuItem(value: 'Mythology', child: Text('Mythology')),
                      DropdownMenuItem(value: 'Sci-Fi', child: Text('Sci-Fi')),
                    ],
                    onChanged: (val) => setState(() => _selectedGenre = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 3. Price & Sample Pages
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Price in INR (₹)',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _freePages,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Free Sample Pages',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 Page Preview')),
                      DropdownMenuItem(value: 2, child: Text('2 Pages Preview')),
                      DropdownMenuItem(value: 3, child: Text('3 Pages Preview')),
                    ],
                    onChanged: (val) => setState(() => _freePages = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 4. Custom Book Covers (as requested: named 4. Custom Book Covers)
            TextField(
              controller: _customCoverController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: '4. Custom Book Covers (Image URL)',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                hintText: 'https://images.unsplash.com/... or uploaded cover URL',
                hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),

            // 5. Synopsis
            TextField(
              controller: _synopsisController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Synopsis / Description',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),

            // 6. Chapter Content
            TextField(
              controller: _contentController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'First Chapter / Story Content',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _publishStory,
              icon: const Icon(Icons.publish, color: Color(0xFF020617)),
              label: const Text(
                'Publish Book Now',
                style: TextStyle(color: Color(0xFF020617), fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 28),

            // Existing published books management
            const Text(
              'Manage Published Books',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...storage.stories.map((s) => ListTile(
                  tileColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.book, color: Color(0xFFF59E0B)),
                  title: Text(s.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text('₹${s.price.toStringAsFixed(2)} · ${s.chapters.length} chapters', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => storage.deleteStory(s.id),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
