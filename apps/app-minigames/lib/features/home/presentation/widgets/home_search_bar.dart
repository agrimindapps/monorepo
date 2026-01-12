import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/home_providers.dart';

/// Search bar widget for the home page header
/// Extracted from HomeHeader for reuse with AppShell
class HomeSearchBar extends ConsumerStatefulWidget {
  const HomeSearchBar({super.key});

  @override
  ConsumerState<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends ConsumerState<HomeSearchBar> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isMobile ? double.infinity : (_isSearchFocused ? 400 : 300),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF252540),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: _isSearchFocused
                ? const Color(0xFFFFD700)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'O que vamos jogar hoje?',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            prefixIcon: Icon(
              Icons.search,
              color: _isSearchFocused
                  ? const Color(0xFFFFD700)
                  : Colors.white54,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).update(value);
          },
        ),
      ),
    );
  }
}
