import 'package:analyzer/dart/ast/ast.dart';
import 'package:source_span/source_span.dart';

import '../models/issue.dart';
import '../models/scoped_function_declaration.dart';
import '../models/severity.dart';
import 'models/pattern.dart';

Issue createIssue({
  required Pattern pattern,
  required SourceSpan location,
  required String message,
  String? verboseMessage,
}) =>
    Issue(
      ruleId: pattern.id,
      documentation: documentation(pattern),
      location: location,
      severity: Severity.none,
      message: message,
      verboseMessage: verboseMessage,
    );

/// Returns a url of a page containing documentation associated with [pattern]
Uri documentation(Pattern pattern) => Uri(
      scheme: 'https',
      host: 'github.com',
      pathSegments: [
        'dart-code-checker',
        'dart-code-metrics',
        'tree',
        'master',
        'doc',
        'anti-patterns',
        '${pattern.id}.html',
      ],
    );

int getArgumentsCount(ScopedFunctionDeclaration dec) {
  final declaration = dec.declaration;

  int? argumentsCount;
  if (declaration is FunctionDeclaration) {
    argumentsCount =
        declaration.functionExpression.parameters?.parameters.length;
  } else if (declaration is MethodDeclaration) {
    argumentsCount = declaration.parameters?.parameters.length;
  }

  return argumentsCount ?? 0;
}
