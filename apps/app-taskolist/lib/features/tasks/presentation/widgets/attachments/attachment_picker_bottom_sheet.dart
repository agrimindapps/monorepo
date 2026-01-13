import 'package:flutter/material.dart';

class AttachmentPickerBottomSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onFiles;

  const AttachmentPickerBottomSheet({
    super.key,
    required this.onCamera,
    required this.onGallery,
    required this.onFiles,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            title: const Text('Tirar Foto'),
            onTap: () {
              Navigator.pop(context);
              onCamera();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.green),
            title: const Text('Galeria de Fotos'),
            onTap: () {
              Navigator.pop(context);
              onGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_file, color: Colors.orange),
            title: const Text('Arquivos'),
            subtitle: const Text('PDF, documentos, etc.'),
            onTap: () {
              Navigator.pop(context);
              onFiles();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    required VoidCallback onFiles,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => AttachmentPickerBottomSheet(
        onCamera: onCamera,
        onGallery: onGallery,
        onFiles: onFiles,
      ),
    );
  }
}
