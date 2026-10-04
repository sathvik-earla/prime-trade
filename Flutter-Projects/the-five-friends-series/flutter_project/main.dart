import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'screens/login_screen.dart';
import 'screens/library_screen.dart';
import 'screens/owner_portal_screen.dart';
import 'screens/reader_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => StorageService()),
      ],
      child: const FiveFriendsApp(),
    ),
  );
}

class FiveFriendsApp extends StatelessWidget {
  const FiveFriendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Five Friends Series',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617), // Slate-950
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF59E0B), // Amber-500
          secondary: Color(0xFF10B981), // Emerald-500
          surface: Color(0xFF0F172A), // Slate-900
          onSurface: Color(0xFFF8FAFC),
        ),
        fontFamily: 'Roboto',
      ),
      home: const AuthGate(),
    );
  }
}

/// Authentication Gate: Compulsory login to enter the app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (!auth.isAuthenticated) {
      // Compulsory login screen
      return const LoginScreen();
    }

    // Authenticated Home shell with Bottom Navigation
    return const HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isOwner = auth.currentOwner != null;

    final screens = [
      const LibraryScreen(),
      const MyPurchasesTab(),
      const BookmarksTab(),
      if (isOwner) const OwnerPortalScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex.clamp(0, screens.length - 1),
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: const Color(0xFFF59E0B).withOpacity(0.2),
        selectedIndex: _currentIndex.clamp(0, isOwner ? 3 : 2),
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.menu_book, color: Color(0xFF94A3B8)),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFFF59E0B)),
            label: 'Library',
          ),
          const NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined, color: Color(0xFF94A3B8)),
            selectedIcon: Icon(Icons.shopping_bag, color: Color(0xFF34D399)),
            label: 'Purchases',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bookmark_outline, color: Color(0xFF94A3B8)),
            selectedIcon: Icon(Icons.bookmark, color: Color(0xFFF59E0B)),
            label: 'Bookmarks',
          ),
          if (isOwner)
            const NavigationDestination(
              icon: Icon(Icons.shield_outlined, color: Color(0xFF94A3B8)),
              selectedIcon: Icon(Icons.shield, color: Color(0xFF34D399)),
              label: 'Owner Portal',
            ),
        ],
      ),
    );
  }
}

class MyPurchasesTab extends StatelessWidget {
  const MyPurchasesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final purchases = storage.purchaseRecords;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('My Purchases & Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: purchases.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shopping_bag_outlined, size: 54, color: Color(0xFF334155)),
                  SizedBox(height: 12),
                  Text('No purchases yet', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                final rec = purchases[index];
                final matchingStory = storage.stories.firstWhere(
                  (s) => s.id == rec.storyId,
                  orElse: () => storage.stories.first,
                );

                return Card(
                  color: const Color(0xFF0F172A),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF1E293B)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: const Icon(Icons.verified, color: Color(0xFF34D399), size: 32),
                    title: Text(
                      rec.storyTitle,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Paid ₹${rec.amount.toStringAsFixed(2)} via ${rec.paymentMethod.toUpperCase()}',
                          style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12),
                        ),
                        if (rec.deliveryAddress != null)
                          Text(
                            'Delivery to: ${rec.deliveryAddress!.city}, ${rec.deliveryAddress!.postalCode} (${rec.status})',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34D399),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ReaderScreen(story: matchingStory)),
                        );
                      },
                      child: const Text('Read', style: TextStyle(color: Color(0xFF020617), fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class BookmarksTab extends StatelessWidget {
  const BookmarksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final bookmarkedStories = storage.stories.where((s) => storage.bookmarks.contains(s.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Saved Bookmarks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: bookmarkedStories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.bookmark_border, size: 54, color: Color(0xFF334155)),
                  SizedBox(height: 12),
                  Text('No bookmarked stories', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedStories.length,
              itemBuilder: (context, index) {
                final story = bookmarkedStories[index];
                return Card(
                  color: const Color(0xFF0F172A),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.bookmark, color: Color(0xFFF59E0B)),
                    title: Text(story.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('By ${story.authorName}', style: const TextStyle(color: Color(0xFF94A3B8))),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ReaderScreen(story: story)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
