import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

/// Wrapper widget para emoji picker com configuração customizada
class TaskolistEmojiPicker extends StatelessWidget {
  final Function(String emoji) onEmojiSelected;
  final String? selectedEmoji;

  const TaskolistEmojiPicker({
    super.key,
    required this.onEmojiSelected,
    this.selectedEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        onEmojiSelected(emoji.emoji);
      },
      config: Config(
        height: 256,
        checkPlatformCompatibility: true,
        emojiViewConfig: EmojiViewConfig(
          emojiSizeMax: 28 *
              (foundation.defaultTargetPlatform == TargetPlatform.iOS
                  ? 1.20
                  : 1.0),
          columns: 7,
          verticalSpacing: 0,
          horizontalSpacing: 0,
          gridPadding: EdgeInsets.zero,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          buttonMode: ButtonMode.MATERIAL,
          recentsLimit: 28,
        ),
        categoryViewConfig: CategoryViewConfig(
          iconColor: Colors.grey,
          iconColorSelected: Theme.of(context).colorScheme.primary,
          indicatorColor: Theme.of(context).colorScheme.primary,
          backspaceColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        bottomActionBarConfig: BottomActionBarConfig(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          buttonColor: Theme.of(context).scaffoldBackgroundColor,
          buttonIconColor: Colors.grey,
          showSearchViewButton: false,
        ),
        searchViewConfig: SearchViewConfig(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          buttonIconColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Bottom sheet com emoji picker
class EmojiPickerBottomSheet extends StatelessWidget {
  final Function(String emoji) onEmojiSelected;
  final String? currentEmoji;

  const EmojiPickerBottomSheet({
    super.key,
    required this.onEmojiSelected,
    this.currentEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Escolher Emoji',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (currentEmoji != null)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onEmojiSelected('');
                    },
                    child: const Text('Remover'),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Emoji picker
          Expanded(
            child: TaskolistEmojiPicker(
              onEmojiSelected: (emoji) {
                Navigator.pop(context);
                onEmojiSelected(emoji);
              },
              selectedEmoji: currentEmoji,
            ),
          ),
        ],
      ),
    );
  }

  /// Show emoji picker bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Function(String emoji) onEmojiSelected,
    String? currentEmoji,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiPickerBottomSheet(
        onEmojiSelected: onEmojiSelected,
        currentEmoji: currentEmoji,
      ),
    );
  }
}

/// TextField com botão de emoji picker
class EmojiTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? currentEmoji;
  final Function(String emoji)? onEmojiChanged;
  final InputDecoration? decoration;
  final int? maxLines;

  const EmojiTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.currentEmoji,
    this.onEmojiChanged,
    this.decoration,
    this.maxLines = 1,
  });

  @override
  State<EmojiTextField> createState() => _EmojiTextFieldState();
}

class _EmojiTextFieldState extends State<EmojiTextField> {
  String? _selectedEmoji;

  @override
  void initState() {
    super.initState();
    _selectedEmoji = widget.currentEmoji;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      maxLines: widget.maxLines,
      decoration: widget.decoration ??
          InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            prefixIcon: _selectedEmoji != null
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _selectedEmoji!,
                      style: const TextStyle(fontSize: 24),
                    ),
                  )
                : null,
            suffixIcon: IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: () => _showEmojiPicker(),
              tooltip: 'Adicionar emoji',
            ),
          ),
    );
  }

  void _showEmojiPicker() {
    EmojiPickerBottomSheet.show(
      context,
      currentEmoji: _selectedEmoji,
      onEmojiSelected: (emoji) {
        setState(() {
          if (emoji.isEmpty) {
            _selectedEmoji = null;
          } else {
            _selectedEmoji = emoji;
          }
        });
        widget.onEmojiChanged?.call(emoji);
      },
    );
  }
}
