#!/usr/bin/env dart

/// Quality Gates System for Flutter Monorepo
/// Prevents regression in code quality and architecture compliance
/// 
/// Usage:
/// dart quality_gates.dart [options]
/// 
/// Options:
/// --app=<app_name>     Target specific app (app-receituagro, app-gasometer, etc.)
/// --check=<type>       Specific check (file_size, architecture, performance, all)
/// --fix                Auto-fix issues where possible
/// --ci                 CI mode with stricter rules and exit codes
/// --report=<format>    Report format (console, json, html)

import 'dart:convert';
import 'dart:io';
import 'dart:math';

class QualityGates {
  static const String version = '1.0.0';
  
  // Quality Gate Limits
  static const int maxFileLines = 500;
  static const int warnFileLines = 300;
  static const int infoFileLines = 250;
  static const int maxWidgetLines = 100;
  static const int maxBuildMethodLines = 50;
  static const int maxSetStateCalls = 10;
  static const double maxComplexityScore = 15.0;
  
  final String targetApp;
  final String checkType;
  final bool fixMode;
  final bool ciMode;
  final String reportFormat;
  
  List<QualityIssue> issues = [];
  Map<String, dynamic> metrics = {};
  
  QualityGates({
    required this.targetApp,
    required this.checkType,
    this.fixMode = false,
    this.ciMode = false,
    this.reportFormat = 'console',
  });
  
  static Future<void> main(List<String> args) async {
    final gates = QualityGates.fromArgs(args);
    await gates.run();
  }
  
  factory QualityGates.fromArgs(List<String> args) {
    String targetApp = 'all';
    String checkType = 'all';
    bool fixMode = false;
    bool ciMode = false;
    String reportFormat = 'console';
    
    for (String arg in args) {
      if (arg.startsWith('--app=')) {
        targetApp = arg.substring(6);
      } else if (arg.startsWith('--check=')) {
        checkType = arg.substring(8);
      } else if (arg == '--fix') {
        fixMode = true;
      } else if (arg == '--ci') {
        ciMode = true;
      } else if (arg.startsWith('--report=')) {
        reportFormat = arg.substring(9);
      } else if (arg == '--help' || arg == '-h') {
        _printUsage();
        exit(0);
      }
    }
    
    return QualityGates(
      targetApp: targetApp,
      checkType: checkType,
      fixMode: fixMode,
      ciMode: ciMode,
      reportFormat: reportFormat,
    );
  }
  
  static void _printUsage() {
    print('''
Quality Gates System v$version

Usage:
  dart quality_gates.dart [options]

Options:
  --app=<name>         Target app: app-receituagro, app-gasometer, app-plantis, app_taskolist, all
  --check=<type>       Check type: file_size, architecture, performance, security, all
  --fix                Auto-fix issues where possible
  --ci                 CI mode with stricter rules and exit codes
  --report=<format>    Report format: console, json, html

Examples:
  dart quality_gates.dart --app=app-receituagro --check=file_size
  dart quality_gates.dart --app=all --check=all --ci
  dart quality_gates.dart --fix --report=html
''');
  }
  
  Future<void> run() async {
    print('🚦 Quality Gates System v$version');
    print('Target: $targetApp | Check: $checkType | CI Mode: $ciMode');
    print('=' * 60);
    
    final startTime = DateTime.now();
    
    try {
      // Get target directories
      final dirs = _getTargetDirectories();
      
      // Run checks based on type
      for (String dir in dirs) {
        await _runChecksForApp(dir);
      }
      
      // Generate report
      await _generateReport();
      
      final duration = DateTime.now().difference(startTime);
      print('\n✅ Quality Gates completed in ${duration.inMilliseconds}ms');
      
      // Exit with appropriate code in CI mode
      if (ciMode) {
        final criticalCount = issues.where((i) => i.severity == Severity.critical).length;
        exit(criticalCount > 0 ? 1 : 0);
      }
      
    } catch (e, stackTrace) {
      print('❌ Quality Gates failed: $e');
      if (ciMode) {
        print('Stack trace: $stackTrace');
        exit(2);
      }
    }
  }
  
  List<String> _getTargetDirectories() {
    final base = Directory.current.path;
    final List<String> dirs = [];
    
    if (targetApp == 'all') {
      dirs.addAll([
        '$base/apps/app-receituagro/lib',
        '$base/apps/app-gasometer/lib',
        '$base/apps/app-plantis/lib',
        '$base/apps/app_taskolist/lib',
        '$base/apps/app-petiveti/lib',
      ]);
    } else {
      dirs.add('$base/apps/$targetApp/lib');
    }
    
    return dirs.where((dir) => Directory(dir).existsSync()).toList();
  }
  
  Future<void> _runChecksForApp(String libDir) async {
    final appName = libDir.split('/').reversed.elementAt(1);
    print('\n📁 Analyzing $appName...');
    
    if (checkType == 'all' || checkType == 'file_size') {
      await _checkFileSizes(libDir, appName);
    }
    
    if (checkType == 'all' || checkType == 'architecture') {
      await _checkArchitecture(libDir, appName);
    }
    
    if (checkType == 'all' || checkType == 'performance') {
      await _checkPerformance(libDir, appName);
    }
    
    if (checkType == 'all' || checkType == 'security') {
      await _checkSecurity(libDir, appName);
    }
  }
  
  Future<void> _checkFileSizes(String libDir, String appName) async {
    print('  🔍 Checking file sizes...');
    
    await for (FileSystemEntity entity in Directory(libDir).list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final lines = await _countLines(entity);
        final relativePath = entity.path.replaceFirst(libDir, '');
        
        if (lines > maxFileLines) {
          issues.add(QualityIssue(
            type: 'file_size',
            severity: Severity.critical,
            message: 'File exceeds maximum line limit ($lines > $maxFileLines)',
            file: relativePath,
            app: appName,
            line: null,
            data: {'lines': lines, 'limit': maxFileLines},
          ));
        } else if (lines > warnFileLines) {
          issues.add(QualityIssue(
            type: 'file_size',
            severity: Severity.warning,
            message: 'File approaching line limit ($lines > $warnFileLines)',
            file: relativePath,
            app: appName,
            line: null,
            data: {'lines': lines, 'limit': warnFileLines},
          ));
        } else if (lines > infoFileLines) {
          issues.add(QualityIssue(
            type: 'file_size',
            severity: Severity.info,
            message: 'Consider refactoring large file ($lines > $infoFileLines)',
            file: relativePath,
            app: appName,
            line: null,
            data: {'lines': lines, 'limit': infoFileLines},
          ));
        }
      }
    }
  }
  
  Future<void> _checkArchitecture(String libDir, String appName) async {
    print('  🏗️  Checking architecture patterns...');
    
    await for (FileSystemEntity entity in Directory(libDir).list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        final relativePath = entity.path.replaceFirst(libDir, '');
        
        await _checkWidgetComplexity(content, relativePath, appName);
        await _checkProviderPatterns(content, relativePath, appName);
        await _checkCleanArchitecture(content, relativePath, appName);
      }
    }
  }
  
  Future<void> _checkPerformance(String libDir, String appName) async {
    print('  ⚡ Checking performance patterns...');
    
    await for (FileSystemEntity entity in Directory(libDir).list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        final relativePath = entity.path.replaceFirst(libDir, '');
        
        await _checkSetStateUsage(content, relativePath, appName);
        await _checkMemoryLeaks(content, relativePath, appName);
        await _checkUnnecessaryRebuilds(content, relativePath, appName);
      }
    }
  }
  
  Future<void> _checkSecurity(String libDir, String appName) async {
    print('  🔒 Checking security patterns...');
    
    await for (FileSystemEntity entity in Directory(libDir).list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        final relativePath = entity.path.replaceFirst(libDir, '');
        
        await _checkHardcodedSecrets(content, relativePath, appName);
        await _checkInputValidation(content, relativePath, appName);
        await _checkDataExposure(content, relativePath, appName);
      }
    }
  }
  
  Future<int> _countLines(File file) async {
    try {
      final lines = await file.readAsLines();
      return lines.where((line) => line.trim().isNotEmpty).length;
    } catch (e) {
      return 0;
    }
  }
  
  Future<void> _checkWidgetComplexity(String content, String file, String app) async {
    // Check for large widgets
    final widgetMatches = RegExp(r'class\s+(\w+Widget?)\s+extends\s+\w+').allMatches(content);
    
    for (Match match in widgetMatches) {
      final widgetName = match.group(1)!;
      final widgetStart = match.start;
      final widgetEnd = _findWidgetEnd(content, widgetStart);
      final widgetContent = content.substring(widgetStart, widgetEnd);
      final lines = widgetContent.split('\n').length;
      
      if (lines > maxWidgetLines) {
        issues.add(QualityIssue(
          type: 'widget_complexity',
          severity: lines > 200 ? Severity.critical : Severity.warning,
          message: 'Widget $widgetName is too complex ($lines lines > $maxWidgetLines)',
          file: file,
          app: app,
          line: _getLineNumber(content, widgetStart),
          data: {'widget': widgetName, 'lines': lines},
        ));
      }
    }
    
    // Check build method complexity
    final buildMatches = RegExp(r'Widget\s+build\s*\([^)]*\)\s*\{').allMatches(content);
    for (Match match in buildMatches) {
      final buildStart = match.start;
      final buildEnd = _findMethodEnd(content, buildStart);
      final buildContent = content.substring(buildStart, buildEnd);
      final lines = buildContent.split('\n').length;
      
      if (lines > maxBuildMethodLines) {
        issues.add(QualityIssue(
          type: 'build_complexity',
          severity: Severity.warning,
          message: 'Build method too complex ($lines lines > $maxBuildMethodLines)',
          file: file,
          app: app,
          line: _getLineNumber(content, buildStart),
          data: {'lines': lines},
        ));
      }
    }
  }
  
  Future<void> _checkProviderPatterns(String content, String file, String app) async {
    // Check for proper Provider usage
    if (content.contains('ChangeNotifier') && !content.contains('dispose()')) {
      issues.add(QualityIssue(
        type: 'provider_pattern',
        severity: Severity.warning,
        message: 'ChangeNotifier without dispose() method',
        file: file,
        app: app,
        line: null,
        data: {},
      ));
    }
    
    // Check for Consumer usage
    final consumerCount = RegExp(r'Consumer<').allMatches(content).length;
    if (consumerCount > 5) {
      issues.add(QualityIssue(
        type: 'provider_pattern',
        severity: Severity.info,
        message: 'High number of Consumer widgets ($consumerCount), consider optimization',
        file: file,
        app: app,
        line: null,
        data: {'consumer_count': consumerCount},
      ));
    }
  }
  
  Future<void> _checkCleanArchitecture(String content, String file, String app) async {
    final path = file.toLowerCase();
    
    // Check layer separation
    if (path.contains('/presentation/') && 
        (content.contains('import') && content.contains('/data/') && !content.contains('/domain/'))) {
      issues.add(QualityIssue(
        type: 'clean_architecture',
        severity: Severity.critical,
        message: 'Presentation layer directly importing data layer (violates Clean Architecture)',
        file: file,
        app: app,
        line: null,
        data: {},
      ));
    }
    
    // Check for proper use cases in presentation
    if (path.contains('/presentation/') && path.contains('_page.dart') && 
        !content.contains('usecase') && !content.contains('UseCase')) {
      issues.add(QualityIssue(
        type: 'clean_architecture',
        severity: Severity.warning,
        message: 'Page not using use cases pattern',
        file: file,
        app: app,
        line: null,
        data: {},
      ));
    }
  }
  
  Future<void> _checkSetStateUsage(String content, String file, String app) async {
    final setStateCount = RegExp(r'setState\s*\(').allMatches(content).length;
    
    if (setStateCount > maxSetStateCalls) {
      issues.add(QualityIssue(
        type: 'performance',
        severity: Severity.warning,
        message: 'Excessive setState calls ($setStateCount > $maxSetStateCalls)',
        file: file,
        app: app,
        line: null,
        data: {'setstate_count': setStateCount},
      ));
    }
  }
  
  Future<void> _checkMemoryLeaks(String content, String file, String app) async {
    // Check for controllers without disposal
    if (content.contains('Controller') && 
        content.contains('initState') && 
        !content.contains('dispose')) {
      issues.add(QualityIssue(
        type: 'memory_leak',
        severity: Severity.critical,
        message: 'Controller initialized but not disposed',
        file: file,
        app: app,
        line: null,
        data: {},
      ));
    }
    
    // Check for stream subscriptions
    if (content.contains('StreamSubscription') && !content.contains('cancel()')) {
      issues.add(QualityIssue(
        type: 'memory_leak',
        severity: Severity.critical,
        message: 'StreamSubscription not cancelled',
        file: file,
        app: app,
        line: null,
        data: {},
      ));
    }
  }
  
  Future<void> _checkUnnecessaryRebuilds(String content, String file, String app) async {
    // Check for const constructors
    final widgetMatches = RegExp(r'return\s+(\w+)\s*\(').allMatches(content);
    for (Match match in widgetMatches) {
      final widgetCall = match.group(0)!;
      if (!widgetCall.contains('const') && _isStaticWidget(widgetCall)) {
        issues.add(QualityIssue(
          type: 'unnecessary_rebuild',
          severity: Severity.info,
          message: 'Widget could be const to prevent rebuilds',
          file: file,
          app: app,
          line: _getLineNumber(content, match.start),
          data: {'widget_call': widgetCall},
        ));
      }
    }
  }
  
  Future<void> _checkHardcodedSecrets(String content, String file, String app) async {
    // Check for API keys and secrets
    final patterns = <String, RegExp>{
      'stripe_key': RegExp(r'[sp]k_(live|test)_[A-Za-z0-9]{20,}'),
      'google_api': RegExp(r'AIza[A-Za-z0-9_-]{35}'),
      'generic_hash': RegExp(r'[0-9a-f]{32}'),
      'password_hardcoded': RegExp(r'password.*=.*[a-zA-Z0-9]{8,}', caseSensitive: false),
    };
    
    for (String patternName in patterns.keys) {
      final pattern = patterns[patternName]!;
      final matches = pattern.allMatches(content);
      for (Match match in matches) {
        issues.add(QualityIssue(
          type: 'hardcoded_secret',
          severity: Severity.critical,
          message: 'Potential hardcoded secret detected ($patternName)',
          file: file,
          app: app,
          line: _getLineNumber(content, match.start),
          data: {
            'pattern_type': patternName,
            'match_preview': '${match.group(0)!.substring(0, min(20, match.group(0)!.length))}...'
          },
        ));
      }
    }
  }
  
  Future<void> _checkInputValidation(String content, String file, String app) async {
    // Check for user input without validation
    if (content.contains('TextField') && !content.contains('validator')) {
      issues.add(QualityIssue(
        type: 'input_validation',
        severity: Severity.warning,
        message: 'TextField without validation',
        file: file,
        app: app,
        line: null,
        data: {},
      ));
    }
  }
  
  Future<void> _checkDataExposure(String content, String file, String app) async {
    // Check for print statements in production code
    if (content.contains('print(') && !file.contains('test/')) {
      final printCount = RegExp(r'print\s*\(').allMatches(content).length;
      issues.add(QualityIssue(
        type: 'data_exposure',
        severity: Severity.warning,
        message: 'Print statements in production code ($printCount occurrences)',
        file: file,
        app: app,
        line: null,
        data: {'print_count': printCount},
      ));
    }
  }
  
  int _findWidgetEnd(String content, int start) {
    int braceCount = 0;
    bool inBraces = false;
    
    for (int i = start; i < content.length; i++) {
      if (content[i] == '{') {
        inBraces = true;
        braceCount++;
      } else if (content[i] == '}') {
        braceCount--;
        if (inBraces && braceCount == 0) {
          return i;
        }
      }
    }
    return content.length;
  }
  
  int _findMethodEnd(String content, int start) {
    return _findWidgetEnd(content, start);
  }
  
  int _getLineNumber(String content, int position) {
    return content.substring(0, position).split('\n').length;
  }
  
  bool _isStaticWidget(String widgetCall) {
    final staticWidgets = ['Text', 'Icon', 'Container', 'SizedBox', 'Padding'];
    return staticWidgets.any((widget) => widgetCall.contains(widget));
  }
  
  Future<void> _generateReport() async {
    switch (reportFormat) {
      case 'json':
        await _generateJsonReport();
        break;
      case 'html':
        await _generateHtmlReport();
        break;
      default:
        _generateConsoleReport();
    }
  }
  
  void _generateConsoleReport() {
    print('\n📊 QUALITY GATES REPORT');
    print('=' * 60);
    
    final grouped = _groupIssuesBySeverity();
    
    for (Severity severity in Severity.values) {
      final severityIssues = grouped[severity] ?? [];
      if (severityIssues.isNotEmpty) {
        final icon = _getSeverityIcon(severity);
        final color = _getSeverityColor(severity);
        print('\n$icon $color${severity.name.toUpperCase()}: ${severityIssues.length} issues');
        
        for (QualityIssue issue in severityIssues.take(10)) {
          print('  • ${issue.app}${issue.file}: ${issue.message}');
        }
        
        if (severityIssues.length > 10) {
          print('  ... and ${severityIssues.length - 10} more');
        }
      }
    }
    
    print('\n📈 SUMMARY');
    print('Total issues: ${issues.length}');
    print('Critical: ${grouped[Severity.critical]?.length ?? 0}');
    print('Warning: ${grouped[Severity.warning]?.length ?? 0}');
    print('Info: ${grouped[Severity.info]?.length ?? 0}');
    
    if (issues.isEmpty) {
      print('\n🎉 All quality gates passed!');
    }
  }
  
  Future<void> _generateJsonReport() async {
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'version': version,
      'target_app': targetApp,
      'check_type': checkType,
      'summary': {
        'total_issues': issues.length,
        'critical': issues.where((i) => i.severity == Severity.critical).length,
        'warning': issues.where((i) => i.severity == Severity.warning).length,
        'info': issues.where((i) => i.severity == Severity.info).length,
      },
      'issues': issues.map((i) => i.toJson()).toList(),
      'metrics': metrics,
    };
    
    final file = File('quality_gates_report.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(report));
    print('📄 JSON report generated: ${file.path}');
  }
  
  Future<void> _generateHtmlReport() async {
    final html = _buildHtmlReport();
    final file = File('quality_gates_report.html');
    await file.writeAsString(html);
    print('📄 HTML report generated: ${file.path}');
  }
  
  String _buildHtmlReport() {
    final grouped = _groupIssuesBySeverity();
    
    return '''
<!DOCTYPE html>
<html>
<head>
    <title>Quality Gates Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 30px; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .metric-card { background: #f8f9fa; padding: 20px; border-radius: 6px; text-align: center; }
        .metric-number { font-size: 2em; font-weight: bold; margin-bottom: 5px; }
        .critical { color: #dc3545; }
        .warning { color: #ffc107; }
        .info { color: #17a2b8; }
        .issues-section { margin: 20px 0; }
        .issue-item { background: #f8f9fa; margin: 10px 0; padding: 15px; border-radius: 4px; border-left: 4px solid #ddd; }
        .issue-item.critical { border-left-color: #dc3545; }
        .issue-item.warning { border-left-color: #ffc107; }
        .issue-item.info { border-left-color: #17a2b8; }
        .issue-header { font-weight: bold; margin-bottom: 5px; }
        .issue-details { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚦 Quality Gates Report</h1>
            <p>Generated on ${DateTime.now().toString()}</p>
            <p>Target: $targetApp | Check: $checkType</p>
        </div>
        
        <div class="summary">
            <div class="metric-card">
                <div class="metric-number">${issues.length}</div>
                <div>Total Issues</div>
            </div>
            <div class="metric-card">
                <div class="metric-number critical">${grouped[Severity.critical]?.length ?? 0}</div>
                <div>Critical</div>
            </div>
            <div class="metric-card">
                <div class="metric-number warning">${grouped[Severity.warning]?.length ?? 0}</div>
                <div>Warnings</div>
            </div>
            <div class="metric-card">
                <div class="metric-number info">${grouped[Severity.info]?.length ?? 0}</div>
                <div>Info</div>
            </div>
        </div>
        
        ${_buildIssuesHtml(grouped)}
    </div>
</body>
</html>
''';
  }
  
  String _buildIssuesHtml(Map<Severity, List<QualityIssue>> grouped) {
    StringBuffer html = StringBuffer();
    
    for (Severity severity in Severity.values) {
      final severityIssues = grouped[severity] ?? [];
      if (severityIssues.isNotEmpty) {
        html.writeln('<div class="issues-section">');
        html.writeln('<h2>${severity.name.toUpperCase()} (${severityIssues.length})</h2>');
        
        for (QualityIssue issue in severityIssues) {
          html.writeln('<div class="issue-item ${severity.name}">');
          html.writeln('<div class="issue-header">${issue.message}</div>');
          html.writeln('<div class="issue-details">');
          html.writeln('App: ${issue.app} | File: ${issue.file}');
          if (issue.line != null) html.writeln(' | Line: ${issue.line}');
          html.writeln('</div>');
          html.writeln('</div>');
        }
        
        html.writeln('</div>');
      }
    }
    
    return html.toString();
  }
  
  Map<Severity, List<QualityIssue>> _groupIssuesBySeverity() {
    Map<Severity, List<QualityIssue>> grouped = {};
    
    for (QualityIssue issue in issues) {
      grouped.putIfAbsent(issue.severity, () => []).add(issue);
    }
    
    return grouped;
  }
  
  String _getSeverityIcon(Severity severity) {
    switch (severity) {
      case Severity.critical:
        return '🔴';
      case Severity.warning:
        return '🟡';
      case Severity.info:
        return '🔵';
    }
  }
  
  String _getSeverityColor(Severity severity) {
    switch (severity) {
      case Severity.critical:
        return '\x1B[31m'; // Red
      case Severity.warning:
        return '\x1B[33m'; // Yellow
      case Severity.info:
        return '\x1B[36m'; // Cyan
    }
  }
}

enum Severity { critical, warning, info }

class QualityIssue {
  final String type;
  final Severity severity;
  final String message;
  final String file;
  final String app;
  final int? line;
  final Map<String, dynamic> data;
  
  QualityIssue({
    required this.type,
    required this.severity,
    required this.message,
    required this.file,
    required this.app,
    this.line,
    required this.data,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'severity': severity.name,
    'message': message,
    'file': file,
    'app': app,
    'line': line,
    'data': data,
  };
}

// Main entry point
Future<void> main(List<String> args) async {
  await QualityGates.main(args);
}