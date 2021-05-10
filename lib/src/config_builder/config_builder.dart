import '../../config.dart';
import '../analyzers/lint_analyzer/anti_patterns/patterns_factory.dart';
import '../analyzers/lint_analyzer/lint_config.dart';
import '../analyzers/lint_analyzer/metrics/metrics_factory.dart';
import '../analyzers/lint_analyzer/metrics/models/metric.dart';
import '../analyzers/lint_analyzer/rules/rules_factory.dart';
import '../analyzers/models/entity_type.dart';
import '../cli/arguments_builder/models/parsed_arguments.dart';
import '../utils/exclude_utils.dart';
import 'models/config.dart';

class ConfigBuilder {
  static const _defaultSkippedFolders = [
    'ios/',
    '.dart_tool/**',
    'packages/**'
  ];

  static Config getConfig(
    AnalysisOptions options, [
    ParsedArguments? arguments,
  ]) =>
      arguments != null
          ? Config.fromAnalysisOptions(options)
              .merge(Config.fromArgs(arguments))
          : Config.fromAnalysisOptions(options);

  static LintConfig getLintConfig(
    Config config,
    String rootPath, {
    Iterable<Metric<num>>? classMetrics,
    Iterable<Metric<num>>? functionMetrics,
  }) =>
      LintConfig(
        prepareExcludes(
          [
            ..._defaultSkippedFolders,
            ...config.excludePatterns,
          ],
          rootPath,
        ),
        getRulesById(config.rules),
        getPatternsById(config.antiPatterns),
        classMetrics ??
            getMetrics(
              config: config.metrics,
              measuredType: EntityType.classEntity,
            ),
        functionMetrics ??
            getMetrics(
              config: config.metrics,
              measuredType: EntityType.methodEntity,
            ),
        prepareExcludes(config.excludeForMetricsPatterns, rootPath),
        config.metrics,
      );
}
