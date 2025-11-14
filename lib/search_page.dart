import 'package:flutter/material.dart';
import 'dart:async';

class SearchResult {
  final int index;
  final String title;
  final String content;
  final List<int> titleMatches;
  final List<int> contentMatches;
  final double relevanceScore;

  SearchResult({
    required this.index,
    required this.title,
    required this.content,
    required this.titleMatches,
    required this.contentMatches,
    required this.relevanceScore,
  });
}

class SearchPage extends StatefulWidget {
  final List<dynamic> data;
  final Function(int) onChapterSelected;
  final String currentFont;

  const SearchPage({
    Key? key,
    required this.data,
    required this.onChapterSelected,
    required this.currentFont,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<SearchResult> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isSearching = false;
  Timer? _debounceTimer;
  String _searchFilter = 'all'; // 'all', 'title', 'content'
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchController.addListener(_onSearchChanged);
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_searchController.text.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      } else {
        _performSearch(_searchController.text);
      }
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Fast search with relevance scoring
    final results = <SearchResult>[];
    final lowerQuery = query.toLowerCase().trim();
    final queryWords = lowerQuery.split(RegExp(r'\s+'));

    for (int i = 0; i < widget.data.length; i++) {
      final item = widget.data[i];
      final title = (item['title'] as String? ?? '').toLowerCase();
      final content = (item['content'] as String? ?? '').toLowerCase();

      List<int> titleMatches = [];
      List<int> contentMatches = [];
      double relevanceScore = 0.0;

      // Skip if filter doesn't match
      if (_searchFilter == 'title') {
        // Search only in title
        titleMatches = _findMatches(title, queryWords);
        if (titleMatches.isEmpty) continue;
        relevanceScore = _calculateRelevance(titleMatches, title.length, true);
      } else if (_searchFilter == 'content') {
        // Search only in content
        contentMatches = _findMatches(content, queryWords);
        if (contentMatches.isEmpty) continue;
        relevanceScore = _calculateRelevance(contentMatches, content.length, false);
      } else {
        // Search in both
        titleMatches = _findMatches(title, queryWords);
        contentMatches = _findMatches(content, queryWords);

        if (titleMatches.isEmpty && contentMatches.isEmpty) continue;

        // Title matches are weighted higher
        final titleScore = _calculateRelevance(titleMatches, title.length, true);
        final contentScore = _calculateRelevance(contentMatches, content.length, false);
        relevanceScore = (titleScore * 3.0) + contentScore;
      }

      results.add(SearchResult(
        index: i,
        title: item['title'] ?? '',
        content: item['content'] ?? '',
        titleMatches: titleMatches,
        contentMatches: contentMatches,
        relevanceScore: relevanceScore,
      ));
    }

    // Sort by relevance (highest first)
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });

    // Add to search history
    if (!_searchHistory.contains(query) && results.isNotEmpty) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.sublist(0, 10);
        }
      });
    }

    _animationController.forward(from: 0);
  }

  List<int> _findMatches(String text, List<String> queryWords) {
    final matches = <int>[];
    for (final word in queryWords) {
      int index = text.indexOf(word);
      while (index != -1) {
        matches.add(index);
        index = text.indexOf(word, index + 1);
      }
    }
    return matches;
  }

  double _calculateRelevance(List<int> matches, int textLength, bool isTitle) {
    if (matches.isEmpty) return 0.0;

    // More matches = higher relevance
    double score = matches.length * 10.0;

    // Earlier matches = higher relevance
    if (matches.isNotEmpty) {
      final firstMatchPosition = matches.reduce((a, b) => a < b ? a : b);
      score += (textLength - firstMatchPosition) / textLength * 5.0;
    }

    // Title matches are more relevant
    if (isTitle) {
      score *= 2.0;
    }

    return score;
  }

  String _getHighlightedText(String text, int maxLength) {
    if (text.length <= maxLength) return text;

    // Find the first match position to show context
    final query = _searchController.text.toLowerCase();
    final lowerText = text.toLowerCase();
    final matchIndex = lowerText.indexOf(query);

    if (matchIndex == -1) {
      return '${text.substring(0, maxLength)}...';
    }

    // Show context around the match
    int start = matchIndex - 30;
    int end = matchIndex + query.length + 30;

    if (start < 0) start = 0;
    if (end > text.length) end = text.length;

    String prefix = start > 0 ? '...' : '';
    String suffix = end < text.length ? '...' : '';

    return '$prefix${text.substring(start, end)}$suffix';
  }

  Widget _buildHighlightedText(String text, List<int> matches, {int? maxLength}) {
    if (matches.isEmpty) {
      final displayText = maxLength != null && text.length > maxLength
          ? _getHighlightedText(text, maxLength)
          : text;
      return Text(
        displayText,
        style: TextStyle(fontFamily: widget.currentFont),
        textDirection: TextDirection.rtl,
      );
    }

    final query = _searchController.text.toLowerCase();
    final lowerText = text.toLowerCase();
    final spans = <TextSpan>[];
    int currentIndex = 0;

    // Simple highlighting by finding query occurrences
    while (currentIndex < text.length) {
      final matchIndex = lowerText.indexOf(query, currentIndex);

      if (matchIndex == -1) {
        spans.add(TextSpan(
          text: text.substring(currentIndex),
          style: TextStyle(fontFamily: widget.currentFont),
        ));
        break;
      }

      // Add text before match
      if (matchIndex > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, matchIndex),
          style: TextStyle(fontFamily: widget.currentFont),
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(matchIndex, matchIndex + query.length),
        style: TextStyle(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
          fontFamily: widget.currentFont,
        ),
      ));

      currentIndex = matchIndex + query.length;
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontFamily: widget.currentFont,
        ),
        children: spans,
      ),
      textDirection: TextDirection.rtl,
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
    });
  }

  void _clearHistory() {
    setState(() {
      _searchHistory = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search Input
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث في الفصول والمحتوى...',
                  hintStyle: TextStyle(fontFamily: widget.currentFont),
                  prefixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('الكل', 'all', Icons.all_inclusive),
                    const SizedBox(width: 8),
                    _buildFilterChip('العناوين', 'title', Icons.title),
                    const SizedBox(width: 8),
                    _buildFilterChip('المحتوى', 'content', Icons.text_snippet),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Results
        Expanded(
          child: _buildResultsView(),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _searchFilter == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _searchFilter = value;
        });
        if (_searchController.text.isNotEmpty) {
          _performSearch(_searchController.text);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    if (_searchController.text.isEmpty) {
      return _buildSearchHistoryView();
    }

    if (_searchResults.isEmpty && !_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontFamily: widget.currentFont,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'حاول البحث بكلمات مختلفة',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                fontFamily: widget.currentFont,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results count
        if (_searchResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'تم العثور على ${_searchResults.length} نتيجة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontFamily: widget.currentFont,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        // Results list
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (index / _searchResults.length) * 0.5,
                      1.0,
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                child: _buildSearchResultCard(result),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultCard(SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          widget.onChapterSelected(result.index);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chapter number and relevance badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'الفصل ${result.index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontFamily: widget.currentFont,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (result.titleMatches.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.title,
                            size: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${result.titleMatches.length}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 4),
                  if (result.contentMatches.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.text_snippet,
                            size: 12,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${result.contentMatches.length}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Title with highlighting
              _buildHighlightedText(
                result.title,
                result.titleMatches,
              ),
              const SizedBox(height: 8),
              // Content preview with highlighting
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
                child: _buildHighlightedText(
                  result.content,
                  result.contentMatches,
                  maxLength: 150,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHistoryView() {
    if (_searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'ابدأ البحث',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontFamily: widget.currentFont,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابحث في جميع الفصول والمحتوى',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                fontFamily: widget.currentFont,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عمليات البحث الأخيرة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: widget.currentFont,
                ),
                textDirection: TextDirection.rtl,
              ),
              TextButton(
                onPressed: _clearHistory,
                child: const Text('مسح'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              final query = _searchHistory[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    query,
                    style: TextStyle(fontFamily: widget.currentFont),
                    textDirection: TextDirection.rtl,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 20),
                    onPressed: () {
                      _searchController.text = query;
                      _performSearch(query);
                    },
                  ),
                  onTap: () {
                    _searchController.text = query;
                    _performSearch(query);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
