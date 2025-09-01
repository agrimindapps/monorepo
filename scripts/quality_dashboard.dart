#!/usr/bin/env dart

/// Quality Dashboard - Real-time monitoring of code quality metrics
/// Generates comprehensive HTML dashboard with trends and insights

import 'dart:io';
import 'dart:convert';
import 'dart:math';

class QualityDashboard {
  static const String version = '1.0.0';
  
  Map<String, AppMetrics> appMetrics = {};
  Map<String, dynamic> trends = {};
  
  Future<void> generate() async {
    print('📊 Generating Quality Dashboard v$version...');
    
    // Collect metrics from all apps
    await _collectMetrics();
    
    // Generate HTML dashboard
    await _generateHtmlDashboard();
    
    print('✅ Dashboard generated: quality_dashboard.html');
    print('🌐 Open in browser: file://${Directory.current.absolute.path}/quality_dashboard.html');
  }
  
  Future<void> _collectMetrics() async {
    final apps = ['app-receituagro', 'app-gasometer', 'app-plantis', 'app_taskolist', 'app-petiveti'];
    
    for (String app in apps) {
      final libDir = Directory('apps/$app/lib');
      if (libDir.existsSync()) {
        print('📁 Analyzing $app...');
        appMetrics[app] = await _analyzeApp(libDir);
      }
    }
  }
  
  Future<AppMetrics> _analyzeApp(Directory libDir) async {
    int totalFiles = 0;
    int totalLines = 0;
    int largeFiles = 0;
    int criticalFiles = 0;
    List<FileMetric> fileMetrics = [];
    
    await for (FileSystemEntity entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        totalFiles++;
        
        final lines = await _countLines(entity);
        totalLines += lines;
        
        final relativePath = entity.path.replaceFirst('${libDir.path}/', '');
        
        FileHealth health = FileHealth.healthy;
        if (lines > 500) {
          criticalFiles++;
          health = FileHealth.critical;
        } else if (lines > 300) {
          largeFiles++;
          health = FileHealth.warning;
        } else if (lines > 250) {
          health = FileHealth.attention;
        }
        
        fileMetrics.add(FileMetric(
          path: relativePath,
          lines: lines,
          health: health,
        ));
      }
    }
    
    return AppMetrics(
      totalFiles: totalFiles,
      totalLines: totalLines,
      averageLines: totalFiles > 0 ? (totalLines / totalFiles).round() : 0,
      largeFiles: largeFiles,
      criticalFiles: criticalFiles,
      healthScore: _calculateHealthScore(totalFiles, largeFiles, criticalFiles),
      fileMetrics: fileMetrics,
    );
  }
  
  Future<int> _countLines(File file) async {
    try {
      final lines = await file.readAsLines();
      return lines.where((line) => line.trim().isNotEmpty).length;
    } catch (e) {
      return 0;
    }
  }
  
  double _calculateHealthScore(int total, int large, int critical) {
    if (total == 0) return 10.0;
    
    double penalty = 0.0;
    penalty += (critical / total) * 5.0; // Critical files reduce score significantly
    penalty += (large / total) * 2.0;    // Large files reduce score moderately
    
    return max(0.0, 10.0 - penalty);
  }
  
  Future<void> _generateHtmlDashboard() async {
    final html = _buildDashboardHtml();
    final file = File('quality_dashboard.html');
    await file.writeAsString(html);
  }
  
  String _buildDashboardHtml() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quality Dashboard - Flutter Monorepo</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .dashboard {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #2C3E50 0%, #3498DB 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 { font-size: 2.5em; margin-bottom: 10px; }
        .header p { opacity: 0.9; font-size: 1.1em; }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            padding: 30px;
            background: #f8f9fa;
        }
        
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.15);
        }
        
        .stat-number {
            font-size: 2.5em;
            font-weight: bold;
            margin-bottom: 10px;
        }
        
        .stat-label { color: #666; font-size: 1.1em; }
        
        .healthy { color: #27AE60; }
        .warning { color: #F39C12; }
        .critical { color: #E74C3C; }
        
        .apps-section {
            padding: 30px;
        }
        
        .section-title {
            font-size: 1.8em;
            margin-bottom: 25px;
            color: #2C3E50;
            border-bottom: 3px solid #3498DB;
            padding-bottom: 10px;
        }
        
        .apps-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 25px;
        }
        
        .app-card {
            background: white;
            border: 1px solid #ddd;
            border-radius: 10px;
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .app-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 15px rgba(0,0,0,0.1);
        }
        
        .app-header {
            padding: 20px;
            background: linear-gradient(135deg, #34495E 0%, #2C3E50 100%);
            color: white;
        }
        
        .app-name { font-size: 1.3em; font-weight: bold; }
        .app-health { font-size: 0.9em; opacity: 0.9; margin-top: 5px; }
        
        .app-metrics {
            padding: 20px;
        }
        
        .metric-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            padding-bottom: 12px;
            border-bottom: 1px solid #eee;
        }
        
        .metric-row:last-child { border-bottom: none; margin-bottom: 0; }
        
        .metric-label { color: #666; }
        .metric-value { font-weight: bold; }
        
        .health-bar {
            width: 100%;
            height: 8px;
            background: #eee;
            border-radius: 4px;
            overflow: hidden;
            margin-top: 15px;
        }
        
        .health-fill {
            height: 100%;
            border-radius: 4px;
            transition: width 0.5s ease;
        }
        
        .charts-section {
            padding: 30px;
            background: #f8f9fa;
        }
        
        .charts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 25px;
        }
        
        .chart-container {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .chart-title {
            font-size: 1.2em;
            margin-bottom: 15px;
            color: #2C3E50;
            text-align: center;
        }
        
        .footer {
            background: #2C3E50;
            color: white;
            padding: 20px;
            text-align: center;
        }
        
        .timestamp {
            opacity: 0.8;
            font-size: 0.9em;
        }
        
        @media (max-width: 768px) {
            .stats-grid { grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); }
            .apps-grid { grid-template-columns: 1fr; }
            .charts-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="dashboard">
        <div class="header">
            <h1>🚦 Quality Dashboard</h1>
            <p>Real-time monitoring of Flutter Monorepo code quality</p>
        </div>
        
        ${_buildOverallStats()}
        
        <div class="apps-section">
            <h2 class="section-title">📱 Applications Overview</h2>
            <div class="apps-grid">
                ${_buildAppCards()}
            </div>
        </div>
        
        <div class="charts-section">
            <h2 class="section-title">📊 Quality Metrics</h2>
            <div class="charts-grid">
                <div class="chart-container">
                    <h3 class="chart-title">Health Score by App</h3>
                    <canvas id="healthChart"></canvas>
                </div>
                <div class="chart-container">
                    <h3 class="chart-title">File Size Distribution</h3>
                    <canvas id="sizeChart"></canvas>
                </div>
                <div class="chart-container">
                    <h3 class="chart-title">Lines of Code Comparison</h3>
                    <canvas id="linesChart"></canvas>
                </div>
                <div class="chart-container">
                    <h3 class="chart-title">Quality Issues Overview</h3>
                    <canvas id="issuesChart"></canvas>
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>Quality Dashboard v$version | Generated on ${DateTime.now()}</p>
            <p class="timestamp">Last updated: ${DateTime.now().toLocal()}</p>
        </div>
    </div>
    
    <script>
        // Chart.js configurations and data
        const chartColors = ['#3498DB', '#E74C3C', '#F39C12', '#27AE60', '#9B59B6'];
        
        // Health Score Chart
        new Chart(document.getElementById('healthChart'), {
            type: 'bar',
            data: {
                labels: [${appMetrics.keys.map((k) => "'$k'").join(', ')}],
                datasets: [{
                    label: 'Health Score',
                    data: [${appMetrics.values.map((m) => m.healthScore).join(', ')}],
                    backgroundColor: chartColors,
                    borderRadius: 8,
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: { beginAtZero: true, max: 10 }
                },
                plugins: {
                    legend: { display: false }
                }
            }
        });
        
        // File Size Distribution
        new Chart(document.getElementById('sizeChart'), {
            type: 'doughnut',
            data: {
                labels: ['Healthy (<250)', 'Attention (250-300)', 'Warning (300-500)', 'Critical (>500)'],
                datasets: [{
                    data: [
                        ${_getTotalHealthyFiles()},
                        ${_getTotalAttentionFiles()},
                        ${_getTotalWarningFiles()},
                        ${_getTotalCriticalFiles()}
                    ],
                    backgroundColor: ['#27AE60', '#F1C40F', '#F39C12', '#E74C3C'],
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'bottom' }
                }
            }
        });
        
        // Lines of Code
        new Chart(document.getElementById('linesChart'), {
            type: 'bar',
            data: {
                labels: [${appMetrics.keys.map((k) => "'$k'").join(', ')}],
                datasets: [{
                    label: 'Total Lines',
                    data: [${appMetrics.values.map((m) => m.totalLines).join(', ')}],
                    backgroundColor: '#3498DB',
                    borderRadius: 8,
                }, {
                    label: 'Average per File',
                    data: [${appMetrics.values.map((m) => m.averageLines).join(', ')}],
                    backgroundColor: '#E74C3C',
                    borderRadius: 8,
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: { beginAtZero: true }
                }
            }
        });
        
        // Quality Issues
        new Chart(document.getElementById('issuesChart'), {
            type: 'radar',
            data: {
                labels: [${appMetrics.keys.map((k) => "'$k'").join(', ')}],
                datasets: [{
                    label: 'Critical Files',
                    data: [${appMetrics.values.map((m) => m.criticalFiles).join(', ')}],
                    backgroundColor: 'rgba(231, 76, 60, 0.2)',
                    borderColor: '#E74C3C',
                    pointBackgroundColor: '#E74C3C',
                }, {
                    label: 'Large Files',
                    data: [${appMetrics.values.map((m) => m.largeFiles).join(', ')}],
                    backgroundColor: 'rgba(243, 156, 18, 0.2)',
                    borderColor: '#F39C12',
                    pointBackgroundColor: '#F39C12',
                }]
            },
            options: {
                responsive: true,
                scales: {
                    r: { beginAtZero: true }
                }
            }
        });
    </script>
</body>
</html>
''';
  }
  
  String _buildOverallStats() {
    final totalFiles = appMetrics.values.fold(0, (sum, m) => sum + m.totalFiles);
    final totalLines = appMetrics.values.fold(0, (sum, m) => sum + m.totalLines);
    final totalCritical = appMetrics.values.fold(0, (sum, m) => sum + m.criticalFiles);
    final avgHealth = appMetrics.values.isEmpty ? 0.0 : 
        appMetrics.values.fold(0.0, (sum, m) => sum + m.healthScore) / appMetrics.length;
    
    return '''
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-number">${appMetrics.length}</div>
            <div class="stat-label">Applications</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">$totalFiles</div>
            <div class="stat-label">Dart Files</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">${(totalLines / 1000).toStringAsFixed(1)}K</div>
            <div class="stat-label">Lines of Code</div>
        </div>
        <div class="stat-card">
            <div class="stat-number ${totalCritical == 0 ? 'healthy' : 'critical'}">$totalCritical</div>
            <div class="stat-label">Critical Files</div>
        </div>
        <div class="stat-card">
            <div class="stat-number ${avgHealth > 8 ? 'healthy' : avgHealth > 6 ? 'warning' : 'critical'}">${avgHealth.toStringAsFixed(1)}</div>
            <div class="stat-label">Avg Health Score</div>
        </div>
    </div>
    ''';
  }
  
  String _buildAppCards() {
    return appMetrics.entries.map((entry) {
      final app = entry.key;
      final metrics = entry.value;
      
      String healthColor = 'healthy';
      String healthText = 'Excellent';
      
      if (metrics.healthScore < 6) {
        healthColor = 'critical';
        healthText = 'Needs Attention';
      } else if (metrics.healthScore < 8) {
        healthColor = 'warning';
        healthText = 'Good';
      }
      
      return '''
      <div class="app-card">
          <div class="app-header">
              <div class="app-name">📱 $app</div>
              <div class="app-health $healthColor">$healthText (${metrics.healthScore.toStringAsFixed(1)}/10)</div>
          </div>
          <div class="app-metrics">
              <div class="metric-row">
                  <span class="metric-label">Total Files</span>
                  <span class="metric-value">${metrics.totalFiles}</span>
              </div>
              <div class="metric-row">
                  <span class="metric-label">Total Lines</span>
                  <span class="metric-value">${metrics.totalLines.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')})</span>
              </div>
              <div class="metric-row">
                  <span class="metric-label">Average Lines/File</span>
                  <span class="metric-value">${metrics.averageLines}</span>
              </div>
              <div class="metric-row">
                  <span class="metric-label">Large Files (>300)</span>
                  <span class="metric-value ${metrics.largeFiles > 0 ? 'warning' : 'healthy'}">${metrics.largeFiles}</span>
              </div>
              <div class="metric-row">
                  <span class="metric-label">Critical Files (>500)</span>
                  <span class="metric-value ${metrics.criticalFiles > 0 ? 'critical' : 'healthy'}">${metrics.criticalFiles}</span>
              </div>
              <div class="health-bar">
                  <div class="health-fill $healthColor" style="width: ${metrics.healthScore * 10}%; background-color: ${healthColor == 'healthy' ? '#27AE60' : healthColor == 'warning' ? '#F39C12' : '#E74C3C'};"></div>
              </div>
          </div>
      </div>
      ''';
    }).join('\n');
  }
  
  int _getTotalHealthyFiles() => appMetrics.values.fold(0, (sum, m) => 
    sum + m.fileMetrics.where((f) => f.health == FileHealth.healthy).length);
  
  int _getTotalAttentionFiles() => appMetrics.values.fold(0, (sum, m) => 
    sum + m.fileMetrics.where((f) => f.health == FileHealth.attention).length);
  
  int _getTotalWarningFiles() => appMetrics.values.fold(0, (sum, m) => 
    sum + m.fileMetrics.where((f) => f.health == FileHealth.warning).length);
  
  int _getTotalCriticalFiles() => appMetrics.values.fold(0, (sum, m) => 
    sum + m.fileMetrics.where((f) => f.health == FileHealth.critical).length);
}

class AppMetrics {
  final int totalFiles;
  final int totalLines;
  final int averageLines;
  final int largeFiles;
  final int criticalFiles;
  final double healthScore;
  final List<FileMetric> fileMetrics;
  
  AppMetrics({
    required this.totalFiles,
    required this.totalLines,
    required this.averageLines,
    required this.largeFiles,
    required this.criticalFiles,
    required this.healthScore,
    required this.fileMetrics,
  });
}

class FileMetric {
  final String path;
  final int lines;
  final FileHealth health;
  
  FileMetric({
    required this.path,
    required this.lines,
    required this.health,
  });
}

enum FileHealth { healthy, attention, warning, critical }

void main() async {
  final dashboard = QualityDashboard();
  await dashboard.generate();
}