import 'package:flutter/material.dart';

void main() {
  runApp(const BookVerseApp());
}

// Data Model
class Book {
  final int id;
  final String title;
  final String author;
  final String genre;
  final String description;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.description,
  });
}

class BookVerseApp extends StatelessWidget {
  const BookVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookVerse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF5B4BDB),
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5B4BDB),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Navigation State: 'home', 'library', 'publish', or 'details'
  String _currentPage = 'home';
  Book? _selectedBook;

  // Login (required at app startup)
  static const Set<String> _ownerEmails = {
    'earlasathvik.rs@gmail.com',
    'weakongames83@gmail.com',
  };
  static const String _ownerPassword = 'RTS590';

  // Client accounts created via Sign Up (email -> password).
  // In-memory only: cleared when the app restarts.
  final Map<String, String> _registeredClients = {};

  bool _isLoggedIn = false;
  bool _isOwner = false;
  bool _showSignUp = false;
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;
  String? _loginError;

  // Initial Book Data
  final List<Book> _allBooks = [
    Book(
      id: 2,
      title: "Mystery of Room 13",
      author: "Emma Carter",
      genre: "Mystery",
      description:
          "A mysterious room appears in an old hotel, and nobody knows who built it or what is inside.",
    ),
    Book(
      id: 3,
      title: "Beyond the Stars",
      author: "Ryan Blake",
      genre: "Science Fiction",
      description:
          "A group of young explorers travel beyond the solar system and discover something unexpected.",
    ),
    Book(
      id: 4,
      title: "The Lost Island",
      author: "Sam Wilson",
      genre: "Adventure",
      description:
          "Four friends find an ancient map leading to an island that has disappeared from every modern map.",
    ),
  ];

  // User's Library (Set of Book IDs)
  final Set<int> _libraryIds = {};

  // Search Filter
  String _searchQuery = '';

  // Form Controller Key
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedGenre = 'Fantasy';

  final List<String> _genres = [
    'Fantasy',
    'Adventure',
    'Mystery',
    'Science Fiction',
    'Romance',
    'Horror',
    'Other'
  ];

  // Helper: Switch Pages
  void _navigateTo(String page, {Book? book}) {
    setState(() {
      _currentPage = page;
      if (book != null) {
        _selectedBook = book;
      }
    });
  }

  // Helper: Add to Library
  void _addToLibrary(Book book) {
    if (_libraryIds.contains(book.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This book is already in your library.')),
      );
    } else {
      setState(() {
        _libraryIds.add(book.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book added to your library!')),
      );
    }
  }

  // Helper: Log In (required at app startup)
  // Owners use the fixed owner credentials; anyone else must already have
  // signed up as a client in this session.
  void _login() {
    if (_loginFormKey.currentState!.validate()) {
      final email = _loginEmailController.text.trim().toLowerCase();
      final password = _loginPasswordController.text;

      final isOwner =
          _ownerEmails.contains(email) && password == _ownerPassword;
      final isClient = _registeredClients[email] == password;

      if (isOwner || isClient) {
        setState(() {
          _isLoggedIn = true;
          _isOwner = isOwner;
          _loginError = null;
          _loginEmailController.clear();
          _loginPasswordController.clear();
        });
      } else {
        setState(() {
          _loginError = 'Incorrect email or password.';
        });
      }
    }
  }

  // Helper: Sign Up (any email/password creates a client account)
  // Client accounts live only in memory for this app session.
  void _signUp() {
    if (_loginFormKey.currentState!.validate()) {
      final email = _loginEmailController.text.trim().toLowerCase();
      final password = _loginPasswordController.text;

      if (_ownerEmails.contains(email)) {
        setState(() {
          _loginError = 'That email is reserved. Please log in instead.';
        });
        return;
      }

      setState(() {
        _registeredClients[email] = password;
        _isLoggedIn = true;
        _isOwner = false;
        _loginError = null;
        _loginEmailController.clear();
        _loginPasswordController.clear();
      });
    }
  }

  // Helper: Log Out
  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _isOwner = false;
      _showSignUp = false;
      _loginEmailController.clear();
      _loginPasswordController.clear();
      _loginError = null;
    });
    _navigateTo('home');
  }

  // Helper: Publish a New Book
  void _publishBook() {
    if (!_isOwner) return; // Publishing is restricted to the site owners.
    if (_formKey.currentState!.validate()) {
      final newBook = Book(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text,
        author: _authorController.text,
        genre: _selectedGenre,
        description: _descriptionController.text,
      );

      setState(() {
        _allBooks.add(newBook);
        _titleController.clear();
        _authorController.clear();
        _descriptionController.clear();
        _selectedGenre = 'Fantasy';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Your book has been published!')),
      );

      _navigateTo('home');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return _buildLoginGate();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📚 BookVerse',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          TextButton(
            onPressed: () => _navigateTo('home'),
            child: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => _navigateTo('library'),
            child: const Text('My Library', style: TextStyle(color: Colors.white)),
          ),
          if (_isOwner)
            TextButton(
              onPressed: () => _navigateTo('publish'),
              child:
                  const Text('Publish', style: TextStyle(color: Colors.white)),
            ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _buildBody(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFFF4F6FB),
        padding: const EdgeInsets.all(24.0),
        child: const Text(
          '© 2026 BookVerse • Read. Write. Discover.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF777777)),
        ),
      ),
    );
  }

  // Router View
  Widget _buildBody() {
    switch (_currentPage) {
      case 'home':
        return _buildHomePage();
      case 'library':
        return _buildLibraryPage();
      case 'publish':
        // Publishing is restricted to the site owners.
        return _isOwner ? _buildPublishPage() : _buildHomePage();
      case 'details':
        return _buildDetailsPage();
      default:
        return _buildHomePage();
    }
  }

  // --- HOME PAGE ---
  Widget _buildHomePage() {
    final filteredBooks = _allBooks.where((book) {
      final query = _searchQuery.toLowerCase();
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.genre.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF5B4BDB), Color(0xFF8C7CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Discover Your Next Book',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Read, discover and publish your own stories.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 25),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '🔎 Search books...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Featured Books',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        filteredBooks.isEmpty
            ? const Text('No books found.')
            : _buildBookGrid(filteredBooks, showAddLibrary: true),
      ],
    );
  }

  // --- LIBRARY PAGE ---
  Widget _buildLibraryPage() {
    final libraryBooks =
        _allBooks.where((book) => _libraryIds.contains(book.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '❤️ My Library',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        libraryBooks.isEmpty
            ? const Text('Your library is empty. Add some books!')
            : _buildBookGrid(libraryBooks, showAddLibrary: false),
      ],
    );
  }

  // --- FULL-SCREEN LOGIN GATE (required before the app can be used) ---
  Widget _buildLoginGate() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 48.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '📚 BookVerse',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showSignUp
                        ? 'Create an account to continue'
                        : 'Please log in to continue',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 16, color: Color(0xFF666666)),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Form(
                      key: _loginFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormFieldLabel('Email'),
                          TextFormField(
                            controller: _loginEmailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Please enter your email'
                                : null,
                            decoration: _inputDecoration(),
                          ),
                          _buildFormFieldLabel('Password'),
                          TextFormField(
                            controller: _loginPasswordController,
                            obscureText: _obscureLoginPassword,
                            validator: (val) => val == null || val.isEmpty
                                ? 'Please enter the password'
                                : null,
                            decoration: _inputDecoration().copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureLoginPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureLoginPassword = !_obscureLoginPassword;
                                  });
                                },
                              ),
                            ),
                            onFieldSubmitted: (_) =>
                                _showSignUp ? _signUp() : _login(),
                          ),
                          if (_loginError != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _loginError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _showSignUp ? _signUp : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B4BDB),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _showSignUp ? 'Sign Up' : 'Log In',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _showSignUp = !_showSignUp;
                                  _loginError = null;
                                  _loginPasswordController.clear();
                                });
                              },
                              child: Text(
                                _showSignUp
                                    ? 'Already have an account? Log In'
                                    : "Don't have an account? Sign Up",
                                style:
                                    const TextStyle(color: Color(0xFF5B4BDB)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- PUBLISH PAGE ---
  Widget _buildPublishPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '✍️ Publish Your Book',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormFieldLabel('Book Title'),
                  TextFormField(
                    controller: _titleController,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Please enter a title'
                        : null,
                    decoration: _inputDecoration(),
                  ),
                  _buildFormFieldLabel('Author'),
                  TextFormField(
                    controller: _authorController,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Please enter author name'
                        : null,
                    decoration: _inputDecoration(),
                  ),
                  _buildFormFieldLabel('Genre'),
                  DropdownButtonFormField<String>(
                    value: _selectedGenre,
                    items: _genres
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedGenre = val);
                    },
                    decoration: _inputDecoration(),
                  ),
                  _buildFormFieldLabel('Book Description'),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Please enter a description'
                        : null,
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _publishBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4BDB),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Publish Book',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- DETAILS PAGE ---
  Widget _buildDetailsPage() {
    if (_selectedBook == null) return const SizedBox.shrink();

    final book = _selectedBook!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => _navigateTo('home'),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          label: const Text('Back', style: TextStyle(color: Colors.black, fontSize: 17)),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoverCard(book.title),
              const SizedBox(height: 20),
              Text(
                book.title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'By ${book.author}',
                style: const TextStyle(fontSize: 18, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 15),
              Text(
                'Genre: ${book.genre}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Text(
                book.description,
                style: const TextStyle(height: 1.7, fontSize: 16),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => _addToLibrary(book),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B4BDB),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '❤️ Add to My Library',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- REUSABLE COMPONENTS ---

  Widget _buildBookGrid(List<Book> books, {required bool showAddLibrary}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Simple responsive column count
        int crossAxisCount = (constraints.maxWidth / 240).floor();
        if (crossAxisCount < 1) crossAxisCount = 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 25,
            mainAxisSpacing: 25,
            childAspectRatio: showAddLibrary ? 0.52 : 0.62,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCoverCard(book.title),
                  const SizedBox(height: 10),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('✍️ ${book.author}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF666666))),
                  if (showAddLibrary) ...[
                    const SizedBox(height: 4),
                    Text('🏷️ ${book.genre}',
                        style: const TextStyle(color: Color(0xFF666666))),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateTo('details', book: book),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B4BDB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        showAddLibrary ? 'View Book' : 'Read / View',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  if (showAddLibrary) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _addToLibrary(book),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B4BDB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '❤️ Add to Library',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCoverCard(String title) {
    return Container(
      height: 160,
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B4BDB), Color(0xFFFF7EB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFormFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 7.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
    );
  }
}