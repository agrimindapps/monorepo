import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) idField;
  final String Function(T) valueField;
  final bool isMultiSelect;
  final List<T> selectedItems;
  final void Function(List<T>) onSelectionChanged;
  final String dialogTitle;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.idField,
    required this.valueField,
    this.isMultiSelect = false,
    this.selectedItems = const [],
    required this.onSelectionChanged,
    this.dialogTitle = 'Select Items',
  });

  @override
  _CustomDropdownState<T> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  late List<T> filteredItems;
  late List<T> selectedItems;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    selectedItems = List.from(widget.selectedItems);
  }

  void _filterItems(String query) {
    setState(() {
      searchQuery = query;
      filteredItems = widget.items
          .where((item) => widget
              .valueField(item)
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectAll() {
    setState(() {
      selectedItems
          .addAll(filteredItems.where((item) => !selectedItems.contains(item)));
    });
  }

  void _deselectAll() {
    setState(() {
      selectedItems.removeWhere((item) => filteredItems.contains(item));
    });
  }

  void _toggleSelection(T item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
    });
  }

  Future<void> _openSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(widget.dialogTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _filterItems('');
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filterItems(value);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isSelected = selectedItems.contains(item);
                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(widget.valueField(item)),
                          onChanged: (value) {
                            setState(() {
                              _toggleSelection(item);
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectAll();
                    });
                  },
                  child: const Text('Select All'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _deselectAll();
                    });
                  },
                  child: const Text('Deselect All'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );

    widget.onSelectionChanged(selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openSelectionDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          selectedItems.isNotEmpty
              ? selectedItems.map((item) => widget.valueField(item)).join(', ')
              : 'Select an option',
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}


// class MyDropdownExample extends StatelessWidget {
//   final List<Map<String, String>> items = [
//     {"id": "1", "value": "Item 1"},
//     {"id": "2", "value": "Item 2"},
//     {"id": "3", "value": "Item 3"},
//     {"id": "4", "value": "Item 4"},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Custom Dropdown Example")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: CustomDropdown<Map<String, String>>(
//           items: items,
//           idField: (item) => item["id"]!,
//           valueField: (item) => item["value"]!,
//           isMultiSelect: true,
//           selectedItems: [],
//           onSelectionChanged: (selectedItems) {
//             print("Selected Items: $selectedItems");
//           },
//         ),
//       ),
//     );
//   }
// }
