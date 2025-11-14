import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'about_page.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  AppThemePreset _themePreset = AppThemePreset.sepia;

  void _updateTheme(AppThemePreset preset) {
    setState(() {
      _themePreset = preset;
      switch (preset) {
        case AppThemePreset.dark:
          _themeMode = ThemeMode.dark;
          break;
        case AppThemePreset.light:
          _themeMode = ThemeMode.light;
          break;
        case AppThemePreset.auto:
          _themeMode = ThemeMode.system;
          break;
        default:
          _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'شرح قطرالندى',
      themeMode: _themeMode,
      theme: _buildTheme(_themePreset, Brightness.light),
      darkTheme: _buildTheme(_themePreset, Brightness.dark),
      home: HomePage(
        onThemeChanged: _updateTheme,
        currentThemePreset: _themePreset,
      ),
    );
  }

  ThemeData _buildTheme(AppThemePreset preset, Brightness brightness) {
    switch (preset) {
      case AppThemePreset.dark:
        return _darkTheme();
      case AppThemePreset.light:
        return _lightTheme();
      case AppThemePreset.sepia:
        return _sepiaTheme();
      case AppThemePreset.night:
        return _nightTheme();
      case AppThemePreset.auto:
        return brightness == Brightness.dark ? _darkTheme() : _lightTheme();
    }
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF9C7EFF),
        secondary: const Color(0xFF6DB3F2),
        surface: const Color(0xFF1B1B1B),
        background: const Color(0xFF121212),
        error: const Color(0xFFCF6679),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: const Color(0xFFE8E8E8),
        onBackground: const Color(0xFFE8E8E8),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF242424),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B1B1B),
        foregroundColor: Color(0xFFE8E8E8),
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF9C7EFF),
        foregroundColor: Colors.black,
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF6750A4),
        secondary: const Color(0xFF625B71),
        surface: Colors.white,
        background: const Color(0xFFFFFBFE),
        error: const Color(0xFFB3261E),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF1C1B1F),
        onBackground: const Color(0xFF1C1B1F),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFBFE),
        foregroundColor: Color(0xFF1C1B1F),
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6750A4),
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData _sepiaTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFB89B72),
        secondary: Color(0xFF9D7C4F),
        surface: Color(0xFFFDF8E4),
        background: Color(0xFFF4ECD8),
        error: Color(0xFFB3261E),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF4B3F30),
        onBackground: Color(0xFF4B3F30),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFFFFFAED),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFB89B72),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFB89B72),
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData _nightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4A90E2),
        secondary: Color(0xFF50C878),
        surface: Color(0xFF0D1117),
        background: Color(0xFF010409),
        error: Color(0xFFCF6679),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Color(0xFFB0B0B0),
        onBackground: Color(0xFFB0B0B0),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF161B22),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D1117),
        foregroundColor: Color(0xFFB0B0B0),
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF4A90E2),
        foregroundColor: Colors.white,
      ),
    );
  }
}

enum AppThemePreset { dark, light, sepia, night, auto }

class HomePage extends StatefulWidget {
  final Function(AppThemePreset) onThemeChanged;
  final AppThemePreset currentThemePreset;

  const HomePage({
    Key? key,
    required this.onThemeChanged,
    required this.currentThemePreset,
  }) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<dynamic> data = [];
  int currentIndex = 0;
  int _selectedNavIndex = 0;
  double fontSize = 20.0;
  double minFontSize = 10.0;
  double maxFontSize = 30.0;
  String currentFont = 'Noto';
  bool _isReaderMode = false;
  late AnimationController _fabController;
  late AnimationController _pageController;

  final List<String> fontOptions = ['Noto', 'Noor', 'Amiri'];

  @override
  void initState() {
    super.initState();
    loadJsonData();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    setState(() {
      data = json.decode(jsonString);
    });
  }

  void increaseFontSize() {
    setState(() {
      if (fontSize < maxFontSize) fontSize += 2.0;
    });
    _showSnackBar('حجم الخط: ${fontSize.toInt()}');
  }

  void decreaseFontSize() {
    setState(() {
      if (fontSize > minFontSize) fontSize -= 2.0;
    });
    _showSnackBar('حجم الخط: ${fontSize.toInt()}');
  }

  void changeFont(String font) {
    setState(() {
      currentFont = font;
    });
    _showSnackBar('تم تغيير الخط إلى $font');
  }

  void nextPage() {
    if (currentIndex < data.length - 1) {
      setState(() {
        currentIndex++;
      });
      _pageController.forward(from: 0);
    }
  }

  void previousPage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      _pageController.forward(from: 0);
    }
  }

  void navigateToPage(int index) {
    setState(() {
      currentIndex = index;
    });
    _pageController.forward(from: 0);
    Navigator.pop(context);
  }

  void _toggleReaderMode() {
    setState(() {
      _isReaderMode = !_isReaderMode;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر المظهر', textAlign: TextAlign.center),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('داكن', AppThemePreset.dark, Icons.dark_mode),
            _buildThemeOption('فاتح', AppThemePreset.light, Icons.light_mode),
            _buildThemeOption('سيبيا', AppThemePreset.sepia, Icons.auto_stories),
            _buildThemeOption('ليلي', AppThemePreset.night, Icons.nightlight_round),
            _buildThemeOption('تلقائي', AppThemePreset.auto, Icons.brightness_auto),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String label, AppThemePreset preset, IconData icon) {
    final isSelected = widget.currentThemePreset == preset;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : null),
      title: Text(label, style: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      )),
      trailing: isSelected ? const Icon(Icons.check_circle) : null,
      onTap: () {
        widget.onThemeChanged(preset);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildReaderView() {
    if (data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          previousPage();
        } else if (details.primaryVelocity! < 0) {
          nextPage();
        }
      },
      child: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: data.isEmpty ? 0 : (currentIndex + 1) / data.length,
            backgroundColor: Theme.of(context).colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Card(
                key: ValueKey(currentIndex),
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Chapter Title
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                data[currentIndex]['title'] ?? 'ﻻ يوجد شي',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: currentFont,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Chapter Number & Progress
                      Text(
                        'الفصل ${currentIndex + 1} من ${data.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontFamily: currentFont,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const Divider(height: 32),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            data[currentIndex]['content'] ?? 'لا يوجد شئ',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 2.2,
                              letterSpacing: 0.3,
                              fontFamily: currentFont,
                            ),
                            textAlign: TextAlign.justify,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Navigation Controls
          _buildNavigationControls(),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Next Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentIndex < data.length - 1 ? nextPage : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('التالي'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Font Controls
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: decreaseFontSize,
                  icon: const Icon(Icons.text_decrease),
                  tooltip: 'تصغير الخط',
                ),
                IconButton(
                  onPressed: increaseFontSize,
                  icon: const Icon(Icons.text_increase),
                  tooltip: 'تكبير الخط',
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Previous Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentIndex > 0 ? previousPage : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('السابق'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryView() {
    if (data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final isCurrentChapter = index == currentIndex;
        return Card(
          elevation: isCurrentChapter ? 4 : 1,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCurrentChapter
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isCurrentChapter
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            title: Text(
              data[index]['title'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCurrentChapter ? FontWeight.bold : FontWeight.normal,
                fontFamily: currentFont,
              ),
              textDirection: TextDirection.rtl,
            ),
            subtitle: Text(
              '${(data[index]['content'] as String).substring(0, (data[index]['content'] as String).length > 60 ? 60 : (data[index]['content'] as String).length)}...',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontFamily: currentFont,
              ),
              textDirection: TextDirection.rtl,
            ),
            trailing: Icon(
              isCurrentChapter ? Icons.menu_book : Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.primary,
            ),
            onTap: () {
              setState(() {
                currentIndex = index;
                _selectedNavIndex = 0;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Theme Settings Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.palette, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'المظهر',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('اختيار المظهر'),
                  subtitle: Text(_getThemeLabel(widget.currentThemePreset)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showThemeDialog,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Font Settings Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.text_fields, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'الخط',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...fontOptions.map((font) {
                  final isSelected = currentFont == font;
                  return ListTile(
                    title: Text(
                      font,
                      style: TextStyle(
                        fontFamily: font,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () => changeFont(font),
                  );
                }).toList(),
                const Divider(),
                ListTile(
                  title: const Text('حجم الخط'),
                  subtitle: Text('${fontSize.toInt()}'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: fontSize,
                        min: minFontSize,
                        max: maxFontSize,
                        divisions: 10,
                        label: fontSize.toInt().toString(),
                        onChanged: (value) {
                          setState(() {
                            fontSize = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Privacy Policy Card
        Card(
          child: ListTile(
            leading: Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
            title: const Text('سياسة الخصوصية'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final Uri url = Uri.parse(
                  'https://quranichub.blogspot.com/p/qatar-al-nada-apps-policy.html');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
          ),
        ),
      ],
    );
  }

  String _getThemeLabel(AppThemePreset preset) {
    switch (preset) {
      case AppThemePreset.dark:
        return 'داكن';
      case AppThemePreset.light:
        return 'فاتح';
      case AppThemePreset.sepia:
        return 'سيبيا';
      case AppThemePreset.night:
        return 'ليلي';
      case AppThemePreset.auto:
        return 'تلقائي';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildReaderView(),
      _buildLibraryView(),
      _buildSettingsView(),
      const AboutPage(),
    ];

    return Scaffold(
      appBar: _selectedNavIndex == 0
          ? null
          : AppBar(
              title: Text(_getAppBarTitle()),
              actions: [
                if (_selectedNavIndex == 0)
                  IconButton(
                    icon: Icon(_isReaderMode ? Icons.fullscreen_exit : Icons.fullscreen),
                    onPressed: _toggleReaderMode,
                  ),
              ],
            ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedNavIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        elevation: 8,
        backgroundColor: Theme.of(context).colorScheme.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'القراءة',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'المكتبة',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'عنا',
          ),
        ],
      ),
      floatingActionButton: _selectedNavIndex == 0 && data.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _selectedNavIndex = 1;
                });
              },
              icon: const Icon(Icons.list),
              label: const Text('الفصول'),
            )
          : null,
    );
  }

  String _getAppBarTitle() {
    switch (_selectedNavIndex) {
      case 1:
        return 'المكتبة';
      case 2:
        return 'الإعدادات';
      case 3:
        return 'عنا';
      default:
        return 'شرح قطرالندى';
    }
  }
}
