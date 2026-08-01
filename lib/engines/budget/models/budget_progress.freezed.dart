// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BudgetProgress {
  double get spent => throw _privateConstructorUsedError;
  double get limit => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;
  bool get isOverBudget => throw _privateConstructorUsedError;

  /// Create a copy of BudgetProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BudgetProgressCopyWith<BudgetProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BudgetProgressCopyWith<$Res> {
  factory $BudgetProgressCopyWith(
    BudgetProgress value,
    $Res Function(BudgetProgress) then,
  ) = _$BudgetProgressCopyWithImpl<$Res, BudgetProgress>;
  @useResult
  $Res call({double spent, double limit, double percentage, bool isOverBudget});
}

/// @nodoc
class _$BudgetProgressCopyWithImpl<$Res, $Val extends BudgetProgress>
    implements $BudgetProgressCopyWith<$Res> {
  _$BudgetProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BudgetProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? spent = null,
    Object? limit = null,
    Object? percentage = null,
    Object? isOverBudget = null,
  }) {
    return _then(
      _value.copyWith(
            spent: null == spent
                ? _value.spent
                : spent // ignore: cast_nullable_to_non_nullable
                      as double,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as double,
            percentage: null == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as double,
            isOverBudget: null == isOverBudget
                ? _value.isOverBudget
                : isOverBudget // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BudgetProgressImplCopyWith<$Res>
    implements $BudgetProgressCopyWith<$Res> {
  factory _$$BudgetProgressImplCopyWith(
    _$BudgetProgressImpl value,
    $Res Function(_$BudgetProgressImpl) then,
  ) = __$$BudgetProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double spent, double limit, double percentage, bool isOverBudget});
}

/// @nodoc
class __$$BudgetProgressImplCopyWithImpl<$Res>
    extends _$BudgetProgressCopyWithImpl<$Res, _$BudgetProgressImpl>
    implements _$$BudgetProgressImplCopyWith<$Res> {
  __$$BudgetProgressImplCopyWithImpl(
    _$BudgetProgressImpl _value,
    $Res Function(_$BudgetProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BudgetProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? spent = null,
    Object? limit = null,
    Object? percentage = null,
    Object? isOverBudget = null,
  }) {
    return _then(
      _$BudgetProgressImpl(
        spent: null == spent
            ? _value.spent
            : spent // ignore: cast_nullable_to_non_nullable
                  as double,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as double,
        percentage: null == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double,
        isOverBudget: null == isOverBudget
            ? _value.isOverBudget
            : isOverBudget // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$BudgetProgressImpl implements _BudgetProgress {
  const _$BudgetProgressImpl({
    required this.spent,
    required this.limit,
    required this.percentage,
    required this.isOverBudget,
  });

  @override
  final double spent;
  @override
  final double limit;
  @override
  final double percentage;
  @override
  final bool isOverBudget;

  @override
  String toString() {
    return 'BudgetProgress(spent: $spent, limit: $limit, percentage: $percentage, isOverBudget: $isOverBudget)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BudgetProgressImpl &&
            (identical(other.spent, spent) || other.spent == spent) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.isOverBudget, isOverBudget) ||
                other.isOverBudget == isOverBudget));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, spent, limit, percentage, isOverBudget);

  /// Create a copy of BudgetProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BudgetProgressImplCopyWith<_$BudgetProgressImpl> get copyWith =>
      __$$BudgetProgressImplCopyWithImpl<_$BudgetProgressImpl>(
        this,
        _$identity,
      );
}

abstract class _BudgetProgress implements BudgetProgress {
  const factory _BudgetProgress({
    required final double spent,
    required final double limit,
    required final double percentage,
    required final bool isOverBudget,
  }) = _$BudgetProgressImpl;

  @override
  double get spent;
  @override
  double get limit;
  @override
  double get percentage;
  @override
  bool get isOverBudget;

  /// Create a copy of BudgetProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BudgetProgressImplCopyWith<_$BudgetProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
