import 'package:flutter/foundation.dart';

import 'platform_file_handler.dart';
import 'web_file_handler.dart';
import 'mobile_file_handler.dart';

/// Factory class to create the appropriate platform file handler
class PlatformFileHandlerFactory {
  /// Create platform-specific file handler
  static PlatformFileHandler create() {
    if (kIsWeb) {
      return WebFileHandler();
    } else {
      return MobileFileHandler();
    }
  }
}