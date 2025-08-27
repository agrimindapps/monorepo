import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../error/app_error.dart';
import 'error_boundary.dart';
import 'retry_button.dart';

/// Widget for testing error boundaries in development mode
/// Only shows in debug mode for testing error handling
class ErrorTestingWidget extends StatefulWidget {
  final Widget child;

  const ErrorTestingWidget({
    super.key,
    required this.child,
  });

  @override
  State<ErrorTestingWidget> createState() => _ErrorTestingWidgetState();
}

class _ErrorTestingWidgetState extends State<ErrorTestingWidget> {
  bool _showTestPanel = false;

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        
        // Floating test panel
        if (_showTestPanel)
          Positioned(
            top: 100,
            right: 16,
            child: _buildTestPanel(),
          ),
        
        // Toggle button
        Positioned(
          bottom: 100,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: "error_test_toggle",
            onPressed: () {
              setState(() {
                _showTestPanel = !_showTestPanel;
              });
            },
            backgroundColor: Colors.red.withOpacity(0.7),
            child: Icon(
              _showTestPanel ? Icons.close : Icons.bug_report,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestPanel() {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bug_report,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Error Testing',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Test buttons
          _buildTestButton(
            'Widget Error',
            () => _simulateWidgetError(),
            Colors.red,
          ),
          
          _buildTestButton(
            'Network Error',
            () => _simulateNetworkError(),
            Colors.orange,
          ),
          
          _buildTestButton(
            'Validation Error',
            () => _simulateValidationError(),
            Colors.yellow,
          ),
          
          _buildTestButton(
            'Async Error',
            () => _simulateAsyncError(),
            Colors.purple,
          ),
          
          _buildTestButton(
            'Provider Error',
            () => _simulateProviderError(),
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String label, VoidCallback onPressed, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  void _simulateWidgetError() {
    // Throw error in next frame to simulate widget build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      throw FlutterError('Simulated widget build error for testing');
    });
  }

  void _simulateNetworkError() {
    final error = NetworkError(
      message: 'Simulated network error for testing',
      statusCode: 500,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      throw error;
    });
  }

  void _simulateValidationError() {
    final error = ValidationError(
      message: 'Simulated validation error: Invalid input data',
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      throw error;
    });
  }

  void _simulateAsyncError() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final error = UnexpectedError(
      message: 'Simulated async error for testing',
      technicalDetails: 'This error was thrown asynchronously',
    );
    
    throw error;
  }

  void _simulateProviderError() {
    // Simulate provider state error
    final error = UnexpectedError(
      message: 'Simulated provider state error',
      technicalDetails: 'Provider state became inconsistent',
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      throw error;
    });
  }
}

/// Test page to validate error boundary functionality
class ErrorTestingPage extends StatelessWidget {
  const ErrorTestingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Boundary Testing'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ErrorTestingWidget(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Error Boundary Testing',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Esta página permite testar o funcionamento dos error boundaries em modo de desenvolvimento.',
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Use o botão flutuante no canto inferior direito para acessar os controles de teste.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Simulate different components that could fail
              const _TestComponent(title: 'Component 1'),
              const SizedBox(height: 16),
              const _TestComponent(title: 'Component 2'),
              const SizedBox(height: 16),
              const _TestComponent(title: 'Component 3'),
            ],
          ),
        ).withPageErrorBoundary(pageName: 'Error Testing'),
      ),
    );
  }
}

class _TestComponent extends StatelessWidget {
  final String title;

  const _TestComponent({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este é um componente de teste que pode ser usado para validar o comportamento do error boundary.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                RetryButton.compact(
                  onRetry: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$title: Retry button clicked'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    throw FlutterError('Test error from $title');
                  },
                  icon: const Icon(Icons.warning, size: 16),
                  label: const Text('Trigger Error'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).withErrorBoundary(
      title: 'Erro no $title',
      message: 'Algo deu errado neste componente de teste.',
      context: 'test_component',
    );
  }
}