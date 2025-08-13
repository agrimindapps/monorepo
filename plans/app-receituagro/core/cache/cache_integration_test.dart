// Cache integration test for unified cache system
// Tests consistency, performance, and integration across refactored services

// Dart imports:
import 'dart:developer' as developer;


// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'i_cache_service.dart';

/// Integration test suite for unified cache system
class CacheIntegrationTest {
  static const String _testPrefix = 'cache_test_';

  /// Run complete cache integration test suite
  static Future<CacheTestResult> runIntegrationTests() async {
    final stopwatch = Stopwatch()..start();
    final results = <String, bool>{};
    final errors = <String, String>{};
    
    try {
      developer.log('🧪 Starting cache integration tests...');
      
      // Test 1: Basic cache operations
      final basicTest = await _testBasicCacheOperations();
      results['basic_operations'] = basicTest.success;
      if (!basicTest.success) errors['basic_operations'] = basicTest.error ?? 'Unknown error';
      
      // Test 2: TTL and expiration
      final ttlTest = await _testTtlAndExpiration();
      results['ttl_expiration'] = ttlTest.success;
      if (!ttlTest.success) errors['ttl_expiration'] = ttlTest.error ?? 'Unknown error';
      
      // Test 3: Batch operations
      final batchTest = await _testBatchOperations();
      results['batch_operations'] = batchTest.success;
      if (!batchTest.success) errors['batch_operations'] = batchTest.error ?? 'Unknown error';
      
      // Test 4: Pattern-based operations
      final patternTest = await _testPatternOperations();
      results['pattern_operations'] = patternTest.success;
      if (!patternTest.success) errors['pattern_operations'] = patternTest.error ?? 'Unknown error';
      
      // Test 5: Service integration consistency
      final integrationTest = await _testServiceIntegrationConsistency();
      results['service_integration'] = integrationTest.success;
      if (!integrationTest.success) errors['service_integration'] = integrationTest.error ?? 'Unknown error';
      
      // Test 6: Performance benchmark
      final performanceTest = await _testPerformanceBenchmark();
      results['performance'] = performanceTest.success;
      if (!performanceTest.success) errors['performance'] = performanceTest.error ?? 'Unknown error';
      
      stopwatch.stop();
      
      final successCount = results.values.where((success) => success).length;
      final totalTests = results.length;
      
      developer.log('🧪 Cache integration tests completed: $successCount/$totalTests passed');
      
      return CacheTestResult(
        success: errors.isEmpty,
        totalTests: totalTests,
        passedTests: successCount,
        failedTests: totalTests - successCount,
        duration: stopwatch.elapsedMilliseconds,
        results: results,
        errors: errors,
      );
      
    } catch (e, stackTrace) {
      stopwatch.stop();
      developer.log('❌ Cache integration tests failed: $e');
      
      return CacheTestResult(
        success: false,
        totalTests: 0,
        passedTests: 0,
        failedTests: 1,
        duration: stopwatch.elapsedMilliseconds,
        results: {},
        errors: {'critical_error': e.toString()},
        stackTrace: stackTrace.toString(),
      );
    }
  }

  /// Test basic cache operations (put, get, has, remove)
  static Future<TestResult> _testBasicCacheOperations() async {
    try {
      final cacheService = Get.find<ICacheService>();
      
      // Test put and get
      const testKey = '${_testPrefix}basic_test';
      const testData = {'test': 'data', 'number': 42};
      
      await cacheService.put(testKey, testData);
      final retrieved = await cacheService.get<Map<String, dynamic>>(testKey);
      
      if (retrieved == null) {
        return TestResult.failure('Failed to retrieve stored data');
      }
      
      if (retrieved['test'] != 'data' || retrieved['number'] != 42) {
        return TestResult.failure('Retrieved data does not match stored data');
      }
      
      // Test has
      final exists = await cacheService.has(testKey);
      if (!exists) {
        return TestResult.failure('Cache.has() returned false for existing key');
      }
      
      // Test remove
      await cacheService.remove(testKey);
      final afterRemove = await cacheService.get(testKey);
      if (afterRemove != null) {
        return TestResult.failure('Data still exists after removal');
      }
      
      return TestResult.success();
      
    } catch (e) {
      return TestResult.failure('Basic operations test failed: $e');
    }
  }

  /// Test TTL and expiration functionality
  static Future<TestResult> _testTtlAndExpiration() async {
    try {
      final cacheService = Get.find<ICacheService>();
      
      const testKey = '${_testPrefix}ttl_test';
      const testData = {'ttl': 'test'};
      
      // Store with very short TTL
      await cacheService.put(testKey, testData, ttl: const Duration(milliseconds: 100));
      
      // Should exist immediately
      final immediate = await cacheService.get(testKey);
      if (immediate == null) {
        return TestResult.failure('Data not found immediately after storage');
      }
      
      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Should be expired now
      final afterExpiry = await cacheService.get(testKey);
      if (afterExpiry != null) {
        return TestResult.failure('Data still exists after TTL expiration');
      }
      
      return TestResult.success();
      
    } catch (e) {
      return TestResult.failure('TTL test failed: $e');
    }
  }

  /// Test batch operations
  static Future<TestResult> _testBatchOperations() async {
    try {
      final cacheService = Get.find<ICacheService>();
      
      // Prepare batch data
      final batchData = {
        '${_testPrefix}batch_1': {'id': 1, 'name': 'Item 1'},
        '${_testPrefix}batch_2': {'id': 2, 'name': 'Item 2'},
        '${_testPrefix}batch_3': {'id': 3, 'name': 'Item 3'},
      };
      
      // Test putBatch
      await cacheService.putBatch(batchData);
      
      // Test getBatch
      final keys = batchData.keys.toList();
      final retrieved = await cacheService.getBatch<Map<String, dynamic>>(keys);
      
      if (retrieved.length != batchData.length) {
        return TestResult.failure('Batch retrieval count mismatch');
      }
      
      for (final key in keys) {
        final original = batchData[key];
        final retrievedItem = retrieved[key];
        
        if (retrievedItem == null) {
          return TestResult.failure('Batch item $key not found');
        }
        
        if (retrievedItem['id'] != original!['id'] || 
            retrievedItem['name'] != original['name']) {
          return TestResult.failure('Batch item $key data mismatch');
        }
      }
      
      // Cleanup
      for (final key in keys) {
        await cacheService.remove(key);
      }
      
      return TestResult.success();
      
    } catch (e) {
      return TestResult.failure('Batch operations test failed: $e');
    }
  }

  /// Test pattern-based operations
  static Future<TestResult> _testPatternOperations() async {
    try {
      final cacheService = Get.find<ICacheService>();
      
      // Store test data with patterns
      final testItems = {
        '${_testPrefix}pattern_user_1': 'user1',
        '${_testPrefix}pattern_user_2': 'user2',
        '${_testPrefix}pattern_product_1': 'product1',
        '${_testPrefix}pattern_product_2': 'product2',
      };
      
      for (final entry in testItems.entries) {
        await cacheService.put(entry.key, entry.value);
      }
      
      // Test clearByPattern
      await cacheService.clearByPattern('pattern_user');
      
      // Verify user items are gone
      final user1 = await cacheService.get('${_testPrefix}pattern_user_1');
      final user2 = await cacheService.get('${_testPrefix}pattern_user_2');
      
      if (user1 != null || user2 != null) {
        return TestResult.failure('Pattern clear did not remove user items');
      }
      
      // Verify product items still exist
      final product1 = await cacheService.get('${_testPrefix}pattern_product_1');
      final product2 = await cacheService.get('${_testPrefix}pattern_product_2');
      
      if (product1 == null || product2 == null) {
        return TestResult.failure('Pattern clear incorrectly removed product items');
      }
      
      // Test clearByPrefix
      await cacheService.clearByPrefix('${_testPrefix}pattern_product');
      
      // Verify all pattern items are gone
      final afterPrefix1 = await cacheService.get('${_testPrefix}pattern_product_1');
      final afterPrefix2 = await cacheService.get('${_testPrefix}pattern_product_2');
      
      if (afterPrefix1 != null || afterPrefix2 != null) {
        return TestResult.failure('Prefix clear did not remove product items');
      }
      
      return TestResult.success();
      
    } catch (e) {
      return TestResult.failure('Pattern operations test failed: $e');
    }
  }

  /// Test consistency across different service integrations
  static Future<TestResult> _testServiceIntegrationConsistency() async {
    try {
      final cacheService = Get.find<ICacheService>();
      
      // Test data consistency across different prefixes (simulating different services)
      final testData = {
        'favoritos_defensivos_test123': {'id': '123', 'name': 'Test Defensivo'},
        'diagnostico_cache_test456': {'id': '456', 'data': 'Test Diagnostic'},
        'praga_data_test789': {'id': '789', 'species': 'Test Praga'},
        'route_cache_test_route': {'name': '/test', 'registered': true},
      };
      
      // Store with different TTL values to simulate different services
      await cacheService.put(
        'favoritos_defensivos_test123', 
        testData['favoritos_defensivos_test123'],
        ttl: const Duration(minutes: 5)
      );
      
      await cacheService.put(
        'diagnostico_cache_test456',
        testData['diagnostico_cache_test456'],
        ttl: const Duration(minutes: 30)
      );
      
      await cacheService.put(
        'praga_data_test789',
        testData['praga_data_test789'],
        ttl: const Duration(hours: 24)
      );
      
      await cacheService.put(
        'route_cache_test_route',
        testData['route_cache_test_route'],
        ttl: const Duration(hours: 24)
      );
      
      // Verify all data is accessible
      for (final entry in testData.entries) {
        final retrieved = await cacheService.get<Map<String, dynamic>>(entry.key);
        if (retrieved == null) {
          return TestResult.failure('Integration test: ${entry.key} not found');
        }
        
        // Basic data integrity check
        final original = entry.value;
        final hasIdMatch = retrieved['id'] == original['id'] ||
                          retrieved['name'] == original['name'] ||
                          retrieved['data'] == original['data'] ||
                          retrieved['species'] == original['species'];
                          
        if (!hasIdMatch) {
          return TestResult.failure('Integration test: ${entry.key} data integrity failed');
        }
      }
      
      // Test cross-service cache operations
      final allKeys = testData.keys.toList();
      final allRetrieved = await cacheService.getBatch<Map<String, dynamic>>(allKeys);
      
      if (allRetrieved.length != testData.length) {
        return TestResult.failure('Integration test: batch retrieval count mismatch');
      }
      
      // Cleanup
      for (final key in allKeys) {
        await cacheService.remove(key);
      }
      
      return TestResult.success();
      
    } catch (e) {
      return TestResult.failure('Service integration test failed: $e');
    }
  }

  /// Performance benchmark test
  static Future<TestResult> _testPerformanceBenchmark() async {
    try {
      final cacheService = Get.find<ICacheService>();
      
      const iterations = 100;
      final testData = {'benchmark': 'data', 'iteration': 0};
      
      // Benchmark PUT operations
      final putStopwatch = Stopwatch()..start();
      for (int i = 0; i < iterations; i++) {
        testData['iteration'] = i;
        await cacheService.put('${_testPrefix}perf_$i', testData);
      }
      putStopwatch.stop();
      
      // Benchmark GET operations
      final getStopwatch = Stopwatch()..start();
      for (int i = 0; i < iterations; i++) {
        await cacheService.get('${_testPrefix}perf_$i');
      }
      getStopwatch.stop();
      
      // Performance thresholds (adjust based on requirements)
      const maxPutTimeMs = 50; // 50ms for 100 PUT operations
      const maxGetTimeMs = 30; // 30ms for 100 GET operations
      
      final putTimeMs = putStopwatch.elapsedMilliseconds;
      final getTimeMs = getStopwatch.elapsedMilliseconds;
      
      developer.log('Cache performance: PUT ${putTimeMs}ms, GET ${getTimeMs}ms');
      
      // Cleanup
      for (int i = 0; i < iterations; i++) {
        await cacheService.remove('${_testPrefix}perf_$i');
      }
      
      if (putTimeMs > maxPutTimeMs) {
        return TestResult.failure('PUT operations too slow: ${putTimeMs}ms > ${maxPutTimeMs}ms');
      }
      
      if (getTimeMs > maxGetTimeMs) {
        return TestResult.failure('GET operations too slow: ${getTimeMs}ms > ${maxGetTimeMs}ms');
      }
      
      return TestResult.success(
        metadata: {
          'putTimeMs': putTimeMs,
          'getTimeMs': getTimeMs,
          'iterations': iterations,
        }
      );
      
    } catch (e) {
      return TestResult.failure('Performance benchmark failed: $e');
    }
  }

  /// Clean up all test data
  static Future<void> cleanupTestData() async {
    try {
      final cacheService = Get.find<ICacheService>();
      await cacheService.clearByPrefix(_testPrefix);
      developer.log('🧹 Cache test cleanup completed');
    } catch (e) {
      developer.log('⚠️ Cache test cleanup failed: $e');
    }
  }
}

/// Individual test result
class TestResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? metadata;

  TestResult.success({this.metadata}) : success = true, error = null;
  TestResult.failure(this.error, {this.metadata}) : success = false;
}

/// Complete test suite result
class CacheTestResult {
  final bool success;
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final int duration;
  final Map<String, bool> results;
  final Map<String, String> errors;
  final String? stackTrace;

  CacheTestResult({
    required this.success,
    required this.totalTests,
    required this.passedTests,
    required this.failedTests,
    required this.duration,
    required this.results,
    required this.errors,
    this.stackTrace,
  });

  double get successRate => totalTests > 0 ? (passedTests / totalTests) : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'totalTests': totalTests,
      'passedTests': passedTests,
      'failedTests': failedTests,
      'successRate': successRate,
      'duration': duration,
      'results': results,
      'errors': errors,
      if (stackTrace != null) 'stackTrace': stackTrace,
    };
  }

  @override
  String toString() {
    return 'CacheTestResult(success: $success, passed: $passedTests/$totalTests, duration: ${duration}ms)';
  }
}