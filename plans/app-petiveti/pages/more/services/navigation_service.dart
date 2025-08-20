// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../models/navigation_model.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  BuildContext? _context;
  
  void setContext(BuildContext context) {
    _context = context;
  }

  Future<bool> navigateToPage(NavigationAction action) async {
    if (_context == null) {
      debugPrint('NavigationService: Context not set');
      return false;
    }

    try {
      switch (action.type) {
        case NavigationType.push:
          await Navigator.of(_context!).pushNamed(
            action.route,
            arguments: action.arguments,
          );
          break;
        case NavigationType.pushReplacement:
          await Navigator.of(_context!).pushReplacementNamed(
            action.route,
            arguments: action.arguments,
          );
          break;
        case NavigationType.pushAndRemoveUntil:
          await Navigator.of(_context!).pushNamedAndRemoveUntil(
            action.route,
            (route) => false,
            arguments: action.arguments,
          );
          break;
        case NavigationType.pop:
          Navigator.of(_context!).pop();
          break;
        case NavigationType.popAndPush:
          Navigator.of(_context!).pop();
          await Navigator.of(_context!).pushNamed(
            action.route,
            arguments: action.arguments,
          );
          break;
      }
      return true;
    } catch (e) {
      debugPrint('NavigationService Error: $e');
      return false;
    }
  }

  Future<bool> navigateToRoute(String route, {Map<String, dynamic>? arguments}) async {
    final action = NavigationAction(
      id: 'custom_navigation',
      title: 'Navigation',
      route: route,
      arguments: arguments,
    );
    return await navigateToPage(action);
  }

  Future<bool> openExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('NavigationService: Error opening URL $url: $e');
      return false;
    }
  }

  Future<bool> shareText(String text) async {
    try {
      await Share.share(text);
      return true;
    } catch (e) {
      debugPrint('NavigationService: Error sharing text: $e');
      return false;
    }
  }

  Future<bool> sendEmail({
    required String email,
    String? subject,
    String? body,
  }) async {
    try {
      final emailLaunchUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
        },
      );

      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('NavigationService: Error sending email: $e');
      return false;
    }
  }

  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final telLaunchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );

      if (await canLaunchUrl(telLaunchUri)) {
        await launchUrl(telLaunchUri);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('NavigationService: Error making phone call: $e');
      return false;
    }
  }

  Future<bool> sendSms(String phoneNumber, {String? message}) async {
    try {
      final smsLaunchUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {
          if (message != null) 'body': message,
        },
      );

      if (await canLaunchUrl(smsLaunchUri)) {
        await launchUrl(smsLaunchUri);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('NavigationService: Error sending SMS: $e');
      return false;
    }
  }

  void goBack() {
    if (_context != null) {
      Navigator.of(_context!).pop();
    }
  }

  bool canGoBack() {
    if (_context == null) return false;
    return Navigator.of(_context!).canPop();
  }

  Future<T?> showDialogCustom<T>(Widget dialog) async {
    if (_context == null) return null;
    
    return await showDialog<T>(
      context: _context!,
      builder: (context) => dialog,
    );
  }

  Future<void> showSnackBar(String message, {Duration? duration}) async {
    if (_context == null) return;
    
    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) async {
    if (_context == null) return false;

    final result = await showDialog<bool>(
      context: _context!,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static bool isValidPhoneNumber(String phoneNumber) {
    return RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phoneNumber);
  }

  Future<Map<String, dynamic>> getNavigationStatistics() async {
    return {
      'hasContext': _context != null,
      'canGoBack': canGoBack(),
      'currentRoute': _context?.mounted == true 
          ? ModalRoute.of(_context!)?.settings.name 
          : null,
    };
  }
}
