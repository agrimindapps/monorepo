import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/home_providers.dart';

/// Header with search bar and profile
class HomeHeader extends ConsumerStatefulWidget {
  final VoidCallback? onMenuTap;

  const HomeHeader({
    super.key,
    this.onMenuTap,
  });

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
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

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F1A).withOpacity(0.8),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
          // Menu button (mobile)
          if (isMobile && widget.onMenuTap != null)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: widget.onMenuTap,
            ),

          // Logo (mobile)
          if (isMobile)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.games,
                color: Colors.white,
                size: 20,
              ),
            ),

          if (isMobile) const SizedBox(width: 12),

          // Spacer before search
          if (!isMobile) const Spacer(),

          // Search bar
          Expanded(
            flex: isMobile ? 1 : 0,
            child: AnimatedContainer(
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
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
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
            ),
          ),

          // Spacer after search
          if (!isMobile) const Spacer(),

          const SizedBox(width: 16),

          // Profile avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white24,
                width: 2,
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade400,
                  Colors.blue.shade400,
                ],
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}
