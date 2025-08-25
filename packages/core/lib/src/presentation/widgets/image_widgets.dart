import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../infrastructure/services/image_service.dart';
import '../../shared/utils/result.dart';

/// Widget para preview de imagem com loading e error states
class ImagePreview extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const ImagePreview({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (imageUrl == null || imageUrl!.isEmpty) {
      child = _buildPlaceholder();
    } else {
      child = _buildNetworkImage();
    }

    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }

    if (onTap != null) {
      child = GestureDetector(onTap: onTap, child: child);
    }

    return child;
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey.shade400,
            size: 40,
          ),
        );
  }

  Widget _buildNetworkImage() {
    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildErrorWidget();
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.error_outline,
        color: Colors.red.shade400,
        size: 40,
      ),
    );
  }
}

/// Dialog para seleção de fonte de imagem
class ImageSourceDialog extends StatelessWidget {
  final String title;
  final String galleryLabel;
  final String cameraLabel;
  final String cancelLabel;
  final IconData galleryIcon;
  final IconData cameraIcon;

  const ImageSourceDialog({
    super.key,
    this.title = 'Selecionar Imagem',
    this.galleryLabel = 'Galeria',
    this.cameraLabel = 'Câmera',
    this.cancelLabel = 'Cancelar',
    this.galleryIcon = Icons.photo_library,
    this.cameraIcon = Icons.camera_alt,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(galleryIcon),
            title: Text(galleryLabel),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          ListTile(
            leading: Icon(cameraIcon),
            title: Text(cameraLabel),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelLabel),
        ),
      ],
    );
  }

  /// Mostra o dialog e retorna a fonte selecionada
  static Future<ImageSource?> show(BuildContext context) {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => const ImageSourceDialog(),
    );
  }
}

/// Widget para selecionar e exibir uma única imagem
class SingleImagePicker extends StatefulWidget {
  final ImageService imageService;
  final String? initialImageUrl;
  final double? width;
  final double? height;
  final String? uploadType;
  final String? folder;
  final Function(ImageUploadResult?)? onImageChanged;
  final Function(double)? onUploadProgress;
  final Widget? placeholder;
  final BorderRadius? borderRadius;

  const SingleImagePicker({
    super.key,
    required this.imageService,
    this.initialImageUrl,
    this.width = 150,
    this.height = 150,
    this.uploadType,
    this.folder,
    this.onImageChanged,
    this.onUploadProgress,
    this.placeholder,
    this.borderRadius,
  });

  @override
  State<SingleImagePicker> createState() => _SingleImagePickerState();
}

class _SingleImagePickerState extends State<SingleImagePicker> {
  String? _currentImageUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.initialImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading ? null : _pickImage,
      child: Stack(
        children: [
          ImagePreview(
            imageUrl: _currentImageUrl,
            width: widget.width,
            height: widget.height,
            borderRadius: widget.borderRadius,
            placeholder: widget.placeholder ?? _buildDefaultPlaceholder(),
          ),
          if (_isUploading) _buildUploadingOverlay(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: widget.borderRadius,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicionar\nImagem',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: widget.borderRadius,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_uploadProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_currentImageUrl == null || _isUploading) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 4,
      right: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 20),
          onPressed: _removeImage,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await ImageSourceDialog.show(context);
    if (source == null) return;

    Result<File> pickResult;
    
    if (source == ImageSource.gallery) {
      pickResult = await widget.imageService.pickImageFromGallery();
    } else {
      pickResult = await widget.imageService.pickImageFromCamera();
    }

    if (pickResult.isError) {
      _showError(pickResult.error!.userMessage);
      return;
    }

    await _uploadImage(pickResult.data!);
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final uploadResult = await widget.imageService.uploadImage(
      imageFile,
      folder: widget.folder,
      uploadType: widget.uploadType,
      onProgress: (progress) {
        setState(() {
          _uploadProgress = progress;
        });
        widget.onUploadProgress?.call(progress);
      },
    );

    setState(() {
      _isUploading = false;
    });

    if (uploadResult.isError) {
      _showError(uploadResult.error!.userMessage);
      return;
    }

    setState(() {
      _currentImageUrl = uploadResult.data!.downloadUrl;
    });

    widget.onImageChanged?.call(uploadResult.data);
  }

  void _removeImage() {
    setState(() {
      _currentImageUrl = null;
    });
    widget.onImageChanged?.call(null);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Widget para selecionar e exibir múltiplas imagens
class MultipleImagePicker extends StatefulWidget {
  final ImageService imageService;
  final List<String> initialImageUrls;
  final int maxImages;
  final String? uploadType;
  final String? folder;
  final Function(List<ImageUploadResult>)? onImagesChanged;
  final Function(int index, double progress)? onUploadProgress;
  final double itemWidth;
  final double itemHeight;

  const MultipleImagePicker({
    super.key,
    required this.imageService,
    this.initialImageUrls = const [],
    this.maxImages = 5,
    this.uploadType,
    this.folder,
    this.onImagesChanged,
    this.onUploadProgress,
    this.itemWidth = 100,
    this.itemHeight = 100,
  });

  @override
  State<MultipleImagePicker> createState() => _MultipleImagePickerState();
}

class _MultipleImagePickerState extends State<MultipleImagePicker> {
  final List<ImageUploadResult> _uploadedImages = [];
  final List<bool> _uploadingStates = [];
  final List<double> _uploadProgresses = [];

  @override
  void initState() {
    super.initState();
    _initializeImages();
  }

  void _initializeImages() {
    for (final url in widget.initialImageUrls) {
      _uploadedImages.add(
        ImageUploadResult(
          downloadUrl: url,
          fileName: '',
          folder: '',
          uploadedAt: DateTime.now(),
        ),
      );
      _uploadingStates.add(false);
      _uploadProgresses.add(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._buildImageItems(),
        if (_uploadedImages.length < widget.maxImages) _buildAddButton(),
      ],
    );
  }

  List<Widget> _buildImageItems() {
    return List.generate(_uploadedImages.length, (index) {
      return Stack(
        children: [
          ImagePreview(
            imageUrl: _uploadedImages[index].downloadUrl,
            width: widget.itemWidth,
            height: widget.itemHeight,
            borderRadius: BorderRadius.circular(8),
          ),
          if (_uploadingStates[index]) _buildUploadingOverlay(index),
          _buildRemoveButton(index),
        ],
      );
    });
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: widget.itemWidth,
        height: widget.itemHeight,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              'Adicionar',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadingOverlay(int index) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: CircularProgressIndicator(
            value: _uploadProgresses[index],
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveButton(int index) {
    if (_uploadingStates[index]) return const SizedBox.shrink();

    return Positioned(
      top: 4,
      right: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 16),
          onPressed: () => _removeImage(index),
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final remainingSlots = widget.maxImages - _uploadedImages.length;
    
    final pickResult = await widget.imageService.pickMultipleImages(
      maxImages: remainingSlots,
    );

    if (pickResult.isError) {
      _showError(pickResult.error!.userMessage);
      return;
    }

    await _uploadImages(pickResult.data!);
  }

  Future<void> _uploadImages(List<File> imageFiles) async {
    for (int i = 0; i < imageFiles.length; i++) {
      final index = _uploadedImages.length;
      
      // Adicionar estados de upload
      _uploadingStates.add(true);
      _uploadProgresses.add(0.0);
      setState(() {});

      final uploadResult = await widget.imageService.uploadImage(
        imageFiles[i],
        folder: widget.folder,
        uploadType: widget.uploadType,
        onProgress: (progress) {
          if (index < _uploadProgresses.length) {
            setState(() {
              _uploadProgresses[index] = progress;
            });
            widget.onUploadProgress?.call(index, progress);
          }
        },
      );

      if (uploadResult.isSuccess) {
        _uploadedImages.add(uploadResult.data!);
        _uploadingStates[index] = false;
      } else {
        _uploadingStates.removeAt(index);
        _uploadProgresses.removeAt(index);
        _showError(uploadResult.error!.userMessage);
      }

      setState(() {});
    }

    widget.onImagesChanged?.call(_uploadedImages);
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
      _uploadingStates.removeAt(index);
      _uploadProgresses.removeAt(index);
    });
    widget.onImagesChanged?.call(_uploadedImages);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}