/** portable-hack-ast is MIT licensed, see /LICENSE. */
namespace HTL\Pha;

newtype Kind as string = string;
newtype SyntaxKind as Kind = Kind;
newtype TokenKind as Kind = Kind;
newtype TriviumKind as Kind = Kind;

function syntax_kind_from_kind(Kind $kind)[]: SyntaxKind {
  return $kind;
}

function syntax_kind_from_string(string $str)[]: SyntaxKind {
  return $str;
}

function token_kind_from_kind(Kind $kind)[]: TokenKind {
  return $kind;
}

function token_kind_from_string(string $str)[]: TokenKind {
  return $str;
}

function trivium_kind_from_kind(Kind $kind)[]: TriviumKind {
  return $kind;
}

function trivium_kind_from_string(string $str)[]: TriviumKind {
  return $str;
}

// Missing the codegen...
const SyntaxKind KIND_NAME_EXPRESSION = 'name_expression';
const SyntaxKind KIND_MISSING = 'missing';

const TriviumKind KIND_DELIMITED_COMMENT = 'delimited_comment';
const TriviumKind KIND_END_OF_LINE = 'end_of_line';
const TriviumKind KIND_FALL_THROUGH_COMMENT = 'fall_through';
const TriviumKind KIND_FIX_ME = 'fix_me';
const TriviumKind KIND_IGNORE_ERROR = 'ignore_error';
const TriviumKind KIND_SINGLE_LINE_COMMENT = 'single_line_comment';
const TriviumKind KIND_TOKEN_TEXT = 'token_text';
const TriviumKind KIND_WHITESPACE = 'whitespace';

// #region GENERATED CODE DO NOT EDIT BY HAND!
// This code was generated by bin/codegen_kind_constants.hack "4.94-172".

const SyntaxKind KIND_ALIAS_DECLARATION = 'alias_declaration';
const SyntaxKind KIND_ANONYMOUS_CLASS = 'anonymous_class';
const SyntaxKind KIND_ANONYMOUS_FUNCTION = 'anonymous_function';
const SyntaxKind KIND_ANONYMOUS_FUNCTION_USE_CLAUSE = 'anonymous_function_use_clause';
const SyntaxKind KIND_AS_EXPRESSION = 'as_expression';
const SyntaxKind KIND_ATTRIBUTE_SYNTAX = 'attribute';
const SyntaxKind KIND_ATTRIBUTE_SPECIFICATION = 'attribute_specification';
const SyntaxKind KIND_ATTRIBUTIZED_SPECIFIER = 'attributized_specifier';
const SyntaxKind KIND_AWAITABLE_CREATION_EXPRESSION = 'awaitable_creation_expression';
const SyntaxKind KIND_BINARY_EXPRESSION = 'binary_expression';
const SyntaxKind KIND_BRACED_EXPRESSION = 'braced_expression';
const SyntaxKind KIND_BREAK_STATEMENT = 'break_statement';
const SyntaxKind KIND_CASE_LABEL = 'case_label';
const SyntaxKind KIND_CAST_EXPRESSION = 'cast_expression';
const SyntaxKind KIND_CATCH_CLAUSE = 'catch_clause';
const SyntaxKind KIND_CLASSISH_BODY = 'classish_body';
const SyntaxKind KIND_CLASSISH_DECLARATION = 'classish_declaration';
const SyntaxKind KIND_CLASSNAME_TYPE_SPECIFIER = 'classname_type_specifier';
const SyntaxKind KIND_CLOSURE_PARAMETER_TYPE_SPECIFIER = 'closure_parameter_type_specifier';
const SyntaxKind KIND_CLOSURE_TYPE_SPECIFIER = 'closure_type_specifier';
const SyntaxKind KIND_COLLECTION_LITERAL_EXPRESSION = 'collection_literal_expression';
const SyntaxKind KIND_COMPOUND_STATEMENT = 'compound_statement';
const SyntaxKind KIND_CONCURRENT_STATEMENT = 'concurrent_statement';
const SyntaxKind KIND_CONDITIONAL_EXPRESSION = 'conditional_expression';
const SyntaxKind KIND_CONSTANT_DECLARATOR = 'constant_declarator';
const SyntaxKind KIND_CONSTRUCTOR_CALL = 'constructor_call';
const SyntaxKind KIND_CONST_DECLARATION = 'const_declaration';
const SyntaxKind KIND_CONTEXTS = 'contexts';
const SyntaxKind KIND_CONTEXT_ALIAS_DECLARATION = 'context_alias_declaration';
const SyntaxKind KIND_CONTEXT_CONSTRAINT = 'context_constraint';
const SyntaxKind KIND_CONTEXT_CONST_DECLARATION = 'context_const_declaration';
const SyntaxKind KIND_CONTINUE_STATEMENT = 'continue_statement';
const SyntaxKind KIND_CTX_IN_REFINEMENT = 'ctx_in_refinement';
const SyntaxKind KIND_DARRAY_INTRINSIC_EXPRESSION = 'darray_intrinsic_expression';
const SyntaxKind KIND_DARRAY_TYPE_SPECIFIER = 'darray_type_specifier';
const SyntaxKind KIND_DECORATED_EXPRESSION = 'decorated_expression';
const SyntaxKind KIND_DEFAULT_LABEL = 'default_label';
const SyntaxKind KIND_DEFINE_EXPRESSION = 'define_expression';
const SyntaxKind KIND_DICTIONARY_INTRINSIC_EXPRESSION = 'dictionary_intrinsic_expression';
const SyntaxKind KIND_DICTIONARY_TYPE_SPECIFIER = 'dictionary_type_specifier';
const SyntaxKind KIND_DO_STATEMENT = 'do_statement';
const SyntaxKind KIND_ECHO_STATEMENT = 'echo_statement';
const SyntaxKind KIND_ELEMENT_INITIALIZER = 'element_initializer';
const SyntaxKind KIND_ELSEIF_CLAUSE = 'elseif_clause';
const SyntaxKind KIND_ELSE_CLAUSE = 'else_clause';
const SyntaxKind KIND_EMBEDDED_BRACED_EXPRESSION = 'embedded_braced_expression';
const SyntaxKind KIND_EMBEDDED_MEMBER_SELECTION_EXPRESSION = 'embedded_member_selection_expression';
const SyntaxKind KIND_EMBEDDED_SUBSCRIPT_EXPRESSION = 'embedded_subscript_expression';
const SyntaxKind KIND_END_OF_FILE = 'end_of_file';
const SyntaxKind KIND_ENUMERATOR = 'enumerator';
const SyntaxKind KIND_ENUM_ATOM_EXPRESSION = 'enum_atom_expression';
const SyntaxKind KIND_ENUM_CLASS_DECLARATION = 'enum_class_declaration';
const SyntaxKind KIND_ENUM_CLASS_ENUMERATOR = 'enum_class_enumerator';
const SyntaxKind KIND_ENUM_CLASS_LABEL_EXPRESSION = 'enum_class_label_expression';
const SyntaxKind KIND_ENUM_DECLARATION = 'enum_declaration';
const SyntaxKind KIND_ENUM_USE = 'enum_use';
const SyntaxKind KIND_ERROR_SYNTAX = 'error_syntax';
const SyntaxKind KIND_ETSPLICE_EXPRESSION = 'eTSplice_expression';
const SyntaxKind KIND_EVAL_EXPRESSION = 'eval_expression';
const SyntaxKind KIND_EXPRESSION_STATEMENT = 'expression_statement';
const SyntaxKind KIND_FIELD_INITIALIZER = 'field_initializer';
const SyntaxKind KIND_FIELD_SPECIFIER = 'field_specifier';
const SyntaxKind KIND_FILE_ATTRIBUTE_SPECIFICATION = 'file_attribute_specification';
const SyntaxKind KIND_FINALLY_CLAUSE = 'finally_clause';
const SyntaxKind KIND_FOREACH_STATEMENT = 'foreach_statement';
const SyntaxKind KIND_FOR_STATEMENT = 'for_statement';
const SyntaxKind KIND_FUNCTION_CALL_EXPRESSION = 'function_call_expression';
const SyntaxKind KIND_FUNCTION_CTX_TYPE_SPECIFIER = 'function_ctx_type_specifier';
const SyntaxKind KIND_FUNCTION_DECLARATION = 'function_declaration';
const SyntaxKind KIND_FUNCTION_DECLARATION_HEADER = 'function_declaration_header';
const SyntaxKind KIND_FUNCTION_POINTER_EXPRESSION = 'function_pointer_expression';
const SyntaxKind KIND_GENERIC_TYPE_SPECIFIER = 'generic_type_specifier';
const SyntaxKind KIND_IF_STATEMENT = 'if_statement';
const SyntaxKind KIND_INCLUSION_DIRECTIVE = 'inclusion_directive';
const SyntaxKind KIND_INCLUSION_EXPRESSION = 'inclusion_expression';
const SyntaxKind KIND_INTERSECTION_TYPE_SPECIFIER = 'intersection_type_specifier';
const SyntaxKind KIND_ISSET_EXPRESSION = 'isset_expression';
const SyntaxKind KIND_IS_EXPRESSION = 'is_expression';
const SyntaxKind KIND_KEYSET_INTRINSIC_EXPRESSION = 'keyset_intrinsic_expression';
const SyntaxKind KIND_KEYSET_TYPE_SPECIFIER = 'keyset_type_specifier';
const SyntaxKind KIND_LAMBDA_EXPRESSION = 'lambda_expression';
const SyntaxKind KIND_LAMBDA_SIGNATURE = 'lambda_signature';
const SyntaxKind KIND_LIKE_TYPE_SPECIFIER = 'like_type_specifier';
const SyntaxKind KIND_LIST_EXPRESSION = 'list_expression';
const SyntaxKind KIND_LIST_ITEM = 'list_item';
const SyntaxKind KIND_LITERAL = 'literal';
const SyntaxKind KIND_MARKUP_SECTION = 'markup_section';
const SyntaxKind KIND_MARKUP_SUFFIX = 'markup_suffix';
const SyntaxKind KIND_MEMBER_SELECTION_EXPRESSION = 'member_selection_expression';
const SyntaxKind KIND_METHODISH_DECLARATION = 'methodish_declaration';
const SyntaxKind KIND_METHODISH_TRAIT_RESOLUTION = 'methodish_trait_resolution';
const SyntaxKind KIND_MODULE_DECLARATION = 'module_declaration';
const SyntaxKind KIND_MODULE_EXPORTS = 'module_exports';
const SyntaxKind KIND_MODULE_IMPORTS = 'module_imports';
const SyntaxKind KIND_MODULE_MEMBERSHIP_DECLARATION = 'module_membership_declaration';
const SyntaxKind KIND_MODULE_NAME = 'module_name';
const SyntaxKind KIND_NAMESPACE_BODY = 'namespace_body';
const SyntaxKind KIND_NAMESPACE_DECLARATION = 'namespace_declaration';
const SyntaxKind KIND_NAMESPACE_DECLARATION_HEADER = 'namespace_declaration_header';
const SyntaxKind KIND_NAMESPACE_EMPTY_BODY = 'namespace_empty_body';
const SyntaxKind KIND_NAMESPACE_GROUP_USE_DECLARATION = 'namespace_group_use_declaration';
const SyntaxKind KIND_NAMESPACE_USE_CLAUSE = 'namespace_use_clause';
const SyntaxKind KIND_NAMESPACE_USE_DECLARATION = 'namespace_use_declaration';
const SyntaxKind KIND_NULLABLE_AS_EXPRESSION = 'nullable_as_expression';
const SyntaxKind KIND_NULLABLE_TYPE_SPECIFIER = 'nullable_type_specifier';
const SyntaxKind KIND_OBJECT_CREATION_EXPRESSION = 'object_creation_expression';
const SyntaxKind KIND_OLD_ATTRIBUTE_SPECIFICATION = 'old_attribute_specification';
const SyntaxKind KIND_PACKAGE_DECLARATION = 'package_declaration';
const SyntaxKind KIND_PACKAGE_INCLUDES = 'package_includes';
const SyntaxKind KIND_PACKAGE_USES = 'package_uses';
const SyntaxKind KIND_PARAMETER_DECLARATION = 'parameter_declaration';
const SyntaxKind KIND_PARENTHESIZED_EXPRESSION = 'parenthesized_expression';
const SyntaxKind KIND_PIPE_VARIABLE = 'pipe_variable';
const SyntaxKind KIND_POSTFIX_UNARY_EXPRESSION = 'postfix_unary_expression';
const SyntaxKind KIND_PREFIXED_CODE_EXPRESSION = 'prefixed_code_expression';
const SyntaxKind KIND_PREFIXED_STRING = 'prefixed_string';
const SyntaxKind KIND_PREFIX_UNARY_EXPRESSION = 'prefix_unary_expression';
const SyntaxKind KIND_PROPERTY_DECLARATION = 'property_declaration';
const SyntaxKind KIND_PROPERTY_DECLARATOR = 'property_declarator';
const SyntaxKind KIND_QUALIFIED_NAME = 'qualified_name';
const SyntaxKind KIND_RECORD_CREATION_EXPRESSION = 'record_creation_expression';
const SyntaxKind KIND_RECORD_DECLARATION = 'record_declaration';
const SyntaxKind KIND_RECORD_FIELD = 'record_field';
const SyntaxKind KIND_REIFIED_TYPE_ARGUMENT = 'reified_type_argument';
const SyntaxKind KIND_REQUIRE_CLAUSE = 'require_clause';
const SyntaxKind KIND_RETURN_STATEMENT = 'return_statement';
const SyntaxKind KIND_SAFE_MEMBER_SELECTION_EXPRESSION = 'safe_member_selection_expression';
const SyntaxKind KIND_SCOPE_RESOLUTION_EXPRESSION = 'scope_resolution_expression';
const SyntaxKind KIND_SCRIPT = 'script';
const SyntaxKind KIND_SHAPE_EXPRESSION = 'shape_expression';
const SyntaxKind KIND_SHAPE_TYPE_SPECIFIER = 'shape_type_specifier';
const SyntaxKind KIND_SIMPLE_INITIALIZER = 'simple_initializer';
const SyntaxKind KIND_SIMPLE_TYPE_SPECIFIER = 'simple_type_specifier';
const SyntaxKind KIND_SOFT_TYPE_SPECIFIER = 'soft_type_specifier';
const SyntaxKind KIND_SUBSCRIPT_EXPRESSION = 'subscript_expression';
const SyntaxKind KIND_SWITCH_FALLTHROUGH = 'switch_fallthrough';
const SyntaxKind KIND_SWITCH_SECTION = 'switch_section';
const SyntaxKind KIND_SWITCH_STATEMENT = 'switch_statement';
const SyntaxKind KIND_THROW_STATEMENT = 'throw_statement';
const SyntaxKind KIND_TRAIT_USE = 'trait_use';
const SyntaxKind KIND_TRAIT_USE_ALIAS_ITEM = 'trait_use_alias_item';
const SyntaxKind KIND_TRAIT_USE_CONFLICT_RESOLUTION = 'trait_use_conflict_resolution';
const SyntaxKind KIND_TRAIT_USE_PRECEDENCE_ITEM = 'trait_use_precedence_item';
const SyntaxKind KIND_TRY_STATEMENT = 'try_statement';
const SyntaxKind KIND_TUPLE_EXPRESSION = 'tuple_expression';
const SyntaxKind KIND_TUPLE_TYPE_EXPLICIT_SPECIFIER = 'tuple_type_explicit_specifier';
const SyntaxKind KIND_TUPLE_TYPE_SPECIFIER = 'tuple_type_specifier';
const SyntaxKind KIND_TYPE_ARGUMENTS = 'type_arguments';
const SyntaxKind KIND_TYPE_CONSTANT = 'type_constant';
const SyntaxKind KIND_TYPE_CONSTRAINT = 'type_constraint';
const SyntaxKind KIND_TYPE_CONST_DECLARATION = 'type_const_declaration';
const SyntaxKind KIND_TYPE_IN_REFINEMENT = 'type_in_refinement';
const SyntaxKind KIND_TYPE_PARAMETER = 'type_parameter';
const SyntaxKind KIND_TYPE_PARAMETERS = 'type_parameters';
const SyntaxKind KIND_TYPE_REFINEMENT = 'type_refinement';
const SyntaxKind KIND_UNION_TYPE_SPECIFIER = 'union_type_specifier';
const SyntaxKind KIND_UNSET_STATEMENT = 'unset_statement';
const SyntaxKind KIND_UPCAST_EXPRESSION = 'upcast_expression';
const SyntaxKind KIND_USING_STATEMENT_BLOCK_SCOPED = 'using_statement_block_scoped';
const SyntaxKind KIND_USING_STATEMENT_FUNCTION_SCOPED = 'using_statement_function_scoped';
const SyntaxKind KIND_VARIABLE_SYNTAX = 'variable';
const SyntaxKind KIND_VARIADIC_PARAMETER = 'variadic_parameter';
const SyntaxKind KIND_VARRAY_INTRINSIC_EXPRESSION = 'varray_intrinsic_expression';
const SyntaxKind KIND_VARRAY_TYPE_SPECIFIER = 'varray_type_specifier';
const SyntaxKind KIND_VECTOR_INTRINSIC_EXPRESSION = 'vector_intrinsic_expression';
const SyntaxKind KIND_VECTOR_TYPE_SPECIFIER = 'vector_type_specifier';
const SyntaxKind KIND_WHERE_CLAUSE = 'where_clause';
const SyntaxKind KIND_WHERE_CONSTRAINT = 'where_constraint';
const SyntaxKind KIND_WHILE_STATEMENT = 'while_statement';
const SyntaxKind KIND_XHP_CATEGORY_DECLARATION = 'xhp_category_declaration';
const SyntaxKind KIND_XHP_CHILDREN_DECLARATION = 'xhp_children_declaration';
const SyntaxKind KIND_XHP_CHILDREN_PARENTHESIZED_LIST = 'xhp_children_parenthesized_list';
const SyntaxKind KIND_XHP_CLASS_ATTRIBUTE = 'xhp_class_attribute';
const SyntaxKind KIND_XHP_CLASS_ATTRIBUTE_DECLARATION = 'xhp_class_attribute_declaration';
const SyntaxKind KIND_XHP_CLOSE = 'xhp_close';
const SyntaxKind KIND_XHP_ENUM_TYPE = 'xhp_enum_type';
const SyntaxKind KIND_XHP_EXPRESSION = 'xhp_expression';
const SyntaxKind KIND_XHP_LATEINIT = 'XHP_lateinit';
const SyntaxKind KIND_XHP_OPEN = 'xhp_open';
const SyntaxKind KIND_XHP_REQUIRED = 'xhp_required';
const SyntaxKind KIND_XHP_SIMPLE_ATTRIBUTE = 'xhp_simple_attribute';
const SyntaxKind KIND_XHP_SIMPLE_CLASS_ATTRIBUTE = 'XHP_simple_class_attribute';
const SyntaxKind KIND_XHP_SPREAD_ATTRIBUTE = 'xhp_spread_attribute';
const SyntaxKind KIND_YIELD_BREAK_STATEMENT = 'yield_break_statement';
const SyntaxKind KIND_YIELD_EXPRESSION = 'yield_expression';

const TokenKind KIND_ABSTRACT = 'abstract';
const TokenKind KIND_AMPERSAND = '&';
const TokenKind KIND_AMPERSAND_AMPERSAND = '&&';
const TokenKind KIND_AMPERSAND_EQUAL = '&=';
const TokenKind KIND_ARRAYKEY = 'arraykey';
const TokenKind KIND_AS = 'as';
const TokenKind KIND_ASYNC = 'async';
const TokenKind KIND_AT = '@';
const TokenKind KIND_ATTRIBUTE_TOKEN = 'attribute';
const TokenKind KIND_AWAIT = 'await';
const TokenKind KIND_BACKSLASH = '\\';
const TokenKind KIND_BACKTICK = '`';
const TokenKind KIND_BAR = '|';
const TokenKind KIND_BAR_BAR = '||';
const TokenKind KIND_BAR_EQUAL = '|=';
const TokenKind KIND_BAR_GREATER_THAN = '|>';
const TokenKind KIND_BINARY = 'binary';
const TokenKind KIND_BINARY_LITERAL = 'binary_literal';
const TokenKind KIND_BOOL = 'bool';
const TokenKind KIND_BOOLEAN = 'boolean';
const TokenKind KIND_BOOLEAN_LITERAL = 'boolean_literal';
const TokenKind KIND_BREAK = 'break';
const TokenKind KIND_CARAT = '^';
const TokenKind KIND_CARAT_EQUAL = '^=';
const TokenKind KIND_CASE = 'case';
const TokenKind KIND_CATCH = 'catch';
const TokenKind KIND_CATEGORY = 'category';
const TokenKind KIND_CHILDREN = 'children';
const TokenKind KIND_CLASS = 'class';
const TokenKind KIND_CLASSNAME = 'classname';
const TokenKind KIND_CLONE = 'clone';
const TokenKind KIND_COLON = ':';
const TokenKind KIND_COLON_COLON = '::';
const TokenKind KIND_COMMA = ',';
const TokenKind KIND_CONCURRENT = 'concurrent';
const TokenKind KIND_CONST = 'const';
const TokenKind KIND_CONSTRUCT = '__construct';
const TokenKind KIND_CONTINUE = 'continue';
const TokenKind KIND_CTX = 'ctx';
const TokenKind KIND_DARRAY = 'darray';
const TokenKind KIND_DECIMAL_LITERAL = 'decimal_literal';
const TokenKind KIND_DEFAULT = 'default';
const TokenKind KIND_DEFINE = 'define';
const TokenKind KIND_DICT = 'dict';
const TokenKind KIND_DO = 'do';
const TokenKind KIND_DOLLAR = '$';
const TokenKind KIND_DOLLAR_DOLLAR = '$$';
const TokenKind KIND_DOT = '.';
const TokenKind KIND_DOT_DOT_DOT = '...';
const TokenKind KIND_DOT_EQUAL = '.=';
const TokenKind KIND_DOUBLE = 'double';
const TokenKind KIND_DOUBLE_QUOTED_STRING_LITERAL = 'double_quoted_string_literal';
const TokenKind KIND_DOUBLE_QUOTED_STRING_LITERAL_HEAD = 'double_quoted_string_literal_head';
const TokenKind KIND_DOUBLE_QUOTED_STRING_LITERAL_TAIL = 'double_quoted_string_literal_tail';
const TokenKind KIND_ECHO = 'echo';
const TokenKind KIND_ELSE = 'else';
const TokenKind KIND_ELSEIF = 'elseif';
const TokenKind KIND_EMPTY = 'empty';
const TokenKind KIND_ENDFOR = 'endfor';
const TokenKind KIND_ENDFOREACH = 'endforeach';
const TokenKind KIND_ENDIF = 'endif';
const TokenKind KIND_ENDSWITCH = 'endswitch';
const TokenKind KIND_ENDWHILE = 'endwhile';
const TokenKind KIND_ENUM = 'enum';
const TokenKind KIND_EQUAL = '=';
const TokenKind KIND_EQUAL_EQUAL = '==';
const TokenKind KIND_EQUAL_EQUAL_EQUAL = '===';
const TokenKind KIND_EQUAL_EQUAL_GREATER_THAN = '==>';
const TokenKind KIND_EQUAL_GREATER_THAN = '=>';
const TokenKind KIND_ERROR_TOKEN = 'error_token';
const TokenKind KIND_EVAL = 'eval';
const TokenKind KIND_EXCLAMATION = '!';
const TokenKind KIND_EXCLAMATION_EQUAL = '!=';
const TokenKind KIND_EXCLAMATION_EQUAL_EQUAL = '!==';
const TokenKind KIND_EXPORTS = 'exports';
const TokenKind KIND_EXTENDS = 'extends';
const TokenKind KIND_FALLTHROUGH = 'fallthrough';
const TokenKind KIND_FILE = 'file';
const TokenKind KIND_FINAL = 'final';
const TokenKind KIND_FINALLY = 'finally';
const TokenKind KIND_FLOAT = 'float';
const TokenKind KIND_FLOATING_LITERAL = 'floating_literal';
const TokenKind KIND_FOR = 'for';
const TokenKind KIND_FOREACH = 'foreach';
const TokenKind KIND_FROM = 'from';
const TokenKind KIND_FUNCTION = 'function';
const TokenKind KIND_GLOBAL = 'global';
const TokenKind KIND_GREATER_THAN = '>';
const TokenKind KIND_GREATER_THAN_EQUAL = '>=';
const TokenKind KIND_GREATER_THAN_GREATER_THAN = '>>';
const TokenKind KIND_GREATER_THAN_GREATER_THAN_EQUAL = '>>=';
const TokenKind KIND_HASH = '#';
const TokenKind KIND_HASHBANG = 'hashbang';
const TokenKind KIND_HEREDOC_STRING_LITERAL = 'heredoc_string_literal';
const TokenKind KIND_HEREDOC_STRING_LITERAL_HEAD = 'heredoc_string_literal_head';
const TokenKind KIND_HEREDOC_STRING_LITERAL_TAIL = 'heredoc_string_literal_tail';
const TokenKind KIND_HEXADECIMAL_LITERAL = 'hexadecimal_literal';
const TokenKind KIND_IF = 'if';
const TokenKind KIND_IMPLEMENTS = 'implements';
const TokenKind KIND_IMPORTS = 'imports';
const TokenKind KIND_INCLUDE = 'include';
const TokenKind KIND_INCLUDE_ONCE = 'include_once';
const TokenKind KIND_INOUT = 'inout';
const TokenKind KIND_INSTANCEOF = 'instanceof';
const TokenKind KIND_INSTEADOF = 'insteadof';
const TokenKind KIND_INT = 'int';
const TokenKind KIND_INTEGER = 'integer';
const TokenKind KIND_INTERFACE = 'interface';
const TokenKind KIND_INTERNAL = 'internal';
const TokenKind KIND_IS = 'is';
const TokenKind KIND_ISSET = 'isset';
const TokenKind KIND_KEYSET = 'keyset';
const TokenKind KIND_LATEINIT = 'lateinit';
const TokenKind KIND_LEFT_BRACE = '{';
const TokenKind KIND_LEFT_BRACKET = '[';
const TokenKind KIND_LEFT_PAREN = '(';
const TokenKind KIND_LESS_THAN = '<';
const TokenKind KIND_LESS_THAN_EQUAL = '<=';
const TokenKind KIND_LESS_THAN_EQUAL_GREATER_THAN = '<=>';
const TokenKind KIND_LESS_THAN_LESS_THAN = '<<';
const TokenKind KIND_LESS_THAN_LESS_THAN_EQUAL = '<<=';
const TokenKind KIND_LESS_THAN_QUESTION = '<?';
const TokenKind KIND_LESS_THAN_SLASH = '</';
const TokenKind KIND_LIST = 'list';
const TokenKind KIND_MINUS = '-';
const TokenKind KIND_MINUS_EQUAL = '-=';
const TokenKind KIND_MINUS_GREATER_THAN = '->';
const TokenKind KIND_MINUS_MINUS = '--';
const TokenKind KIND_MIXED = 'mixed';
const TokenKind KIND_MODULE = 'module';
const TokenKind KIND_NAME = 'name';
const TokenKind KIND_NAMESPACE = 'namespace';
const TokenKind KIND_NEW = 'new';
const TokenKind KIND_NEWCTX = 'newctx';
const TokenKind KIND_NEWTYPE = 'newtype';
const TokenKind KIND_NORETURN = 'noreturn';
const TokenKind KIND_NOWDOC_STRING_LITERAL = 'nowdoc_string_literal';
const TokenKind KIND_NULL_LITERAL = 'null';
const TokenKind KIND_NUM = 'num';
const TokenKind KIND_OBJECT = 'object';
const TokenKind KIND_OCTAL_LITERAL = 'octal_literal';
const TokenKind KIND_PACKAGE = 'package';
const TokenKind KIND_PARENT = 'parent';
const TokenKind KIND_PERCENT = '%';
const TokenKind KIND_PERCENT_EQUAL = '%=';
const TokenKind KIND_PLUS = '+';
const TokenKind KIND_PLUS_EQUAL = '+=';
const TokenKind KIND_PLUS_PLUS = '++';
const TokenKind KIND_PRINT = 'print';
const TokenKind KIND_PRIVATE = 'private';
const TokenKind KIND_PROTECTED = 'protected';
const TokenKind KIND_PUBLIC = 'public';
const TokenKind KIND_QUESTION = '?';
const TokenKind KIND_QUESTION_AS = '?as';
const TokenKind KIND_QUESTION_COLON = '?:';
const TokenKind KIND_QUESTION_MINUS_GREATER_THAN = '?->';
const TokenKind KIND_QUESTION_QUESTION = '??';
const TokenKind KIND_QUESTION_QUESTION_EQUAL = '??=';
const TokenKind KIND_READONLY = 'readonly';
const TokenKind KIND_REAL = 'real';
const TokenKind KIND_RECORD = 'recordname';
const TokenKind KIND_RECORD_DEC = 'record';
const TokenKind KIND_REIFY = 'reify';
const TokenKind KIND_REQUIRE = 'require';
const TokenKind KIND_REQUIRED = 'required';
const TokenKind KIND_REQUIRE_ONCE = 'require_once';
const TokenKind KIND_RESOURCE = 'resource';
const TokenKind KIND_RETURN = 'return';
const TokenKind KIND_RIGHT_BRACE = '}';
const TokenKind KIND_RIGHT_BRACKET = ']';
const TokenKind KIND_RIGHT_PAREN = ')';
const TokenKind KIND_SELF = 'self';
const TokenKind KIND_SEMICOLON = ';';
const TokenKind KIND_SHAPE = 'shape';
const TokenKind KIND_SINGLE_QUOTED_STRING_LITERAL = 'single_quoted_string_literal';
const TokenKind KIND_SLASH = '/';
const TokenKind KIND_SLASH_EQUAL = '/=';
const TokenKind KIND_SLASH_GREATER_THAN = '/>';
const TokenKind KIND_STAR = '*';
const TokenKind KIND_STAR_EQUAL = '*=';
const TokenKind KIND_STAR_STAR = '**';
const TokenKind KIND_STAR_STAR_EQUAL = '**=';
const TokenKind KIND_STATIC = 'static';
const TokenKind KIND_STRING = 'string';
const TokenKind KIND_STRING_LITERAL_BODY = 'string_literal_body';
const TokenKind KIND_SUPER = 'super';
const TokenKind KIND_SWITCH = 'switch';
const TokenKind KIND_THIS = 'this';
const TokenKind KIND_THROW = 'throw';
const TokenKind KIND_TILDE = '~';
const TokenKind KIND_TRAIT = 'trait';
const TokenKind KIND_TRY = 'try';
const TokenKind KIND_TUPLE = 'tuple';
const TokenKind KIND_TYPE = 'type';
const TokenKind KIND_UNSET = 'unset';
const TokenKind KIND_UPCAST = 'upcast';
const TokenKind KIND_USE = 'use';
const TokenKind KIND_USING = 'using';
const TokenKind KIND_VAR = 'var';
const TokenKind KIND_VARIABLE_TOKEN = 'variable';
const TokenKind KIND_VARRAY = 'varray';
const TokenKind KIND_VEC = 'vec';
const TokenKind KIND_VOID = 'void';
const TokenKind KIND_WHERE = 'where';
const TokenKind KIND_WHILE = 'while';
const TokenKind KIND_WITH = 'with';
const TokenKind KIND_XHP = 'xhp';
const TokenKind KIND_XHP_BODY = 'XHP_body';
const TokenKind KIND_XHP_CATEGORY_NAME = 'XHP_category_name';
const TokenKind KIND_XHP_CLASS_NAME = 'XHP_class_name';
const TokenKind KIND_XHP_COMMENT = 'XHP_comment';
const TokenKind KIND_XHP_ELEMENT_NAME = 'XHP_element_name';
const TokenKind KIND_XHP_STRING_LITERAL = 'XHP_string_literal';
const TokenKind KIND_YIELD = 'yield';
// #endregion
