import 'dart:io';

import 'package:dart_code_metrics/metrics_analyzer.dart';
import 'package:dart_code_metrics/src/analyzers/lint_analyzer/metrics/models/metric_value_level.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group('LintAnalyzer', () {
    const analyzer = LintAnalyzer();
    const rootDirectory = '';
    final folders = [
      normalize(File('test/resources/lint_analyzer').absolute.path)
    ];

    test('should analyze files', () async {
      final config = _createConfig();

      final result = await analyzer.runCliAnalysis(
        folders,
        rootDirectory,
        config,
      );

      expect(result, hasLength(2));
    });

    test('should analyze only one file', () async {
      final config = _createConfig(
        excludePatterns: ['test/resources/**/*_exclude_example.dart'],
      );

      final result = await analyzer.runCliAnalysis(
        folders,
        rootDirectory,
        config,
      );

      expect(result, hasLength(1));
    });

    test('should report default code metrics', () async {
      final config = _createConfig();

      final result = await analyzer.runCliAnalysis(
        folders,
        rootDirectory,
        config,
      );

      final report = result.first.functions.values.first;
      final metrics = {for (final m in report.metrics) m.metricsId: m.level};

      expect(metrics, {
        'cyclomatic-complexity': MetricValueLevel.none,
        'lines-of-code': MetricValueLevel.none,
        'maximum-nesting-level': MetricValueLevel.none,
        'number-of-parameters': MetricValueLevel.none,
        'source-lines-of-code': MetricValueLevel.none,
        'maintainability-index': MetricValueLevel.none,
      });
    });

    test('should report lines-of-executable-code metric', () async {
      final config = _createConfig(metrics: {'lines-of-executable-code': 50});

      final result = await analyzer.runCliAnalysis(
        folders,
        rootDirectory,
        config,
      );

      final report = result.first.functions.values.first;
      final metrics = {for (final m in report.metrics) m.metricsId: m.level};

      expect(metrics, {
        'cyclomatic-complexity': MetricValueLevel.none,
        'lines-of-code': MetricValueLevel.none,
        'maximum-nesting-level': MetricValueLevel.none,
        'number-of-parameters': MetricValueLevel.none,
        'source-lines-of-code': MetricValueLevel.none,
        'maintainability-index': MetricValueLevel.none,
        'lines-of-executable-code': MetricValueLevel.none,
      });
    });

    test('should exceed source-lines-of-code metric', () async {
      final config = _createConfig(metrics: {'source-lines-of-code': 1});

      final result = await analyzer.runCliAnalysis(
        folders,
        rootDirectory,
        config,
      );

      final report = result.first.functions.values.first;
      final metrics = {for (final m in report.metrics) m.metricsId: m.level};

      expect(metrics, {
        'cyclomatic-complexity': MetricValueLevel.none,
        'lines-of-code': MetricValueLevel.none,
        'maximum-nesting-level': MetricValueLevel.none,
        'number-of-parameters': MetricValueLevel.none,
        'source-lines-of-code': MetricValueLevel.alarm,
        'maintainability-index': MetricValueLevel.none,
      });
    });

    test('should report prefer-trailing-comma rule', () async {
      final config = _createConfig(rules: {'prefer-trailing-comma': {}});

      final result = await analyzer.runCliAnalysis(
        folders,
        rootDirectory,
        config,
      );

      final issues = result.first.issues;
      final ids = issues.map((issue) => issue.ruleId);

      expect(ids, List.filled(6, 'prefer-trailing-comma'));
    });
  });
}

Config _createConfig({
  Map<String, Map<String, Object>> antiPatterns = const {},
  Iterable<String> excludePatterns = const [],
  Map<String, Object> metrics = const {},
  Iterable<String> excludeForMetricsPatterns = const [],
  Map<String, Map<String, Object>> rules = const {},
}) =>
    Config(
      antiPatterns: antiPatterns,
      excludePatterns: excludePatterns,
      metrics: metrics,
      excludeForMetricsPatterns: excludeForMetricsPatterns,
      rules: rules,
    );
