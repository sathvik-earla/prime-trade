import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story_item.dart';
import '../services/storage_service.dart';
import 'checkout_screen.dart';

class ReaderScreen extends StatefulWidget {
  final StoryItem story;

  const ReaderScreen({super.key, required this.story});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  int _currentPage = 1;
  double _fontSize = 16.0;
  bool _isPlayingAudio = false;
  String _theme = 'dark'; // 'dark' | 'sepia' | 'light'

  @override
  void initState() {
    super.initState();
    final progress = context.read<StorageService>().readingProgress[widget.story.id];
    if (progress != null && progress > 0) {
      _currentPage = progress;
    }
  }

  Color get _bgColor {
    switch (_theme) {
      case 'sepia':
        return const Color(0xFFFBF0D9);
      case 'light':
        return Colors.white;
      default:
        return const Color(0xFF020617);
    }
  }

  Color get _textColor {
    switch (_theme) {
      case 'sepia':
        return const Color(0xFF3F2B1D);
      case 'light':
        return const Color(0xFF0F172A);
      default:
        return const Color(0xFFE2E8F0);
    }
  }

  void _nextPage(bool isPurchased) {
    if (!isPurchased && _currentPage >= widget.story.freeSamplePages) {
      _showPurchasePrompt();
      return;
    }
    if (_currentPage < widget.story.chapters.length) {
      setState(() => _currentPage++);
      context.read<StorageService>().updateProgress(widget.story.id, _currentPage);
    }
  }

  void _prevPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
      context.read<StorageService>().updateProgress(widget.story.id, _currentPage);
    }
  }

  void _showPurchasePrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Free Sample Ended', style: TextStyle(color: Colors.white)),
        content: Text(
          'You have reached the end of the free sample for "${widget.story.title}". Purchase the full story for ₹${widget.story.price.toStringAsFixed(2)} to continue reading.',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CheckoutScreen(story: widget.story)),
              );
            },
            child: const Text('Buy Full Book', style: TextStyle(color: Color(0xFF020617), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final isPurchased = storage.purchasedStoryIds.contains(widget.story.id) || widget.story.price <= 0;
    final totalChapters = widget.story.chapters.length;
    final currentChapter = widget.story.chapters.isNotEmpty
        ? widget.story.chapters[(_currentPage - 1).clamp(0, totalChapters - 1)]
        : Chapter(id: '0', pageNumber: 1, title: widget.story.title, content: widget.story.synopsis);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _theme == 'dark' ? const Color(0xFF0F172A) : Colors.amber.shade100,
        elevation: 0,
        iconTheme: IconThemeData(color: _textColor),
        title: Text(
          widget.story.title,
          style: TextStyle(color: _textColor, fontSize: 15, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(_isPlayingAudio ? Icons.pause_circle_filled : Icons.play_circle_fill),
            color: const Color(0xFFF59E0B),
            tooltip: 'Audio Narration',
            onPressed: () {
              setState(() => _isPlayingAudio = !_isPlayingAudio);
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: _textColor),
            onSelected: (val) {
              if (val == 'bigger') setState(() => _fontSize += 2);
              if (val == 'smaller' && _fontSize > 12) setState(() => _fontSize -= 2);
              if (val == 'dark' || val == 'sepia' || val == 'light') setState(() => _theme = val);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'bigger', child: Text('Text Size +')),
              const PopupMenuItem(value: 'smaller', child: Text('Text Size -')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'dark', child: Text('Theme: Night Dark')),
              const PopupMenuItem(value: 'sepia', child: Text('Theme: Cozy Sepia')),
              const PopupMenuItem(value: 'light', child: Text('Theme: Crisp Light')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Audio playback status bar
          if (_isPlayingAudio)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF59E0B).withOpacity(0.2),
              child: Row(
                children: [
                  const Icon(Icons.volume_up, size: 18, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  Text(
                    'Playing voice narration for page $_currentPage of $totalChapters...',
                    style: TextStyle(color: _textColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // Main Reading Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentChapter.illustrationUrl != null &&
                      currentChapter.illustrationUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        currentChapter.illustrationUrl!,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    currentChapter.title,
                    style: TextStyle(
                      fontSize: _fontSize + 4,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    currentChapter.content,
                    style: TextStyle(
                      fontSize: _fontSize,
                      height: 1.7,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation bottom controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _theme == 'dark' ? const Color(0xFF0F172A) : Colors.amber.shade50,
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _currentPage > 1 ? _prevPage : null,
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  color: _textColor,
                ),
                Text(
                  'Page $_currentPage of $totalChapters',
                  style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                IconButton(
                  onPressed: _currentPage < totalChapters ? () => _nextPage(isPurchased) : null,
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  color: _textColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
