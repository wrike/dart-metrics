import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dart_code_metrics/src/models/code_issue.dart';
import 'package:dart_code_metrics/src/models/code_issue_severity.dart';

import 'base_rule.dart';
import 'rule_utils.dart';

class NoObjectDeclarationRule extends BaseRule {
  static const _warningMessage =
      'Avoid Object type declaration in class member';

  const NoObjectDeclarationRule()
      : super(
          id: 'no-object-declaration',
          severity: CodeIssueSeverity.style,
        );

  @override
  Iterable<CodeIssue> check(
    CompilationUnit unit,
    Uri sourceUrl,
    String sourceContent,
  ) {
    final _visitor = _Visitor();

    unit.visitChildren(_visitor);

    return _visitor.members
        .map(
          (member) => createIssue(
            this,
            _warningMessage,
            null,
            null,
            sourceUrl,
            sourceContent,
            unit.lineInfo,
            member,
          ),
        )
        .toList(growable: false);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final _members = <ClassMember>[];

  Iterable<ClassMember> get members => _members;

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    super.visitFieldDeclaration(node);

    if (_hasObjectType(node.fields.type)) {
      _members.add(node);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    super.visitMethodDeclaration(node);

    if (_hasObjectType(node.returnType)) {
      _members.add(node);
    }
  }

  bool _hasObjectType(TypeAnnotation type) =>
      type is TypeName && type.name.name == 'Object';
}
