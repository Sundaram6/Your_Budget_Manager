// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_allowance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DailyAllowance {
  int get amount =>
      throw _privateConstructorUsedError; // Integer daily allowance amount (in paise: e.g. 50000 = ₹500)
  String get message => throw _privateConstructorUsedError;
  bool get isOverBudget => throw _privateConstructorUsedError;
  int get remaining =>
      throw _privateConstructorUsedError; // Integer remaining amount in paise
  int get daysLeft => throw _privateConstructorUsedError;

  /// Create a copy of DailyAllowance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyAllowanceCopyWith<DailyAllowance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyAllowanceCopyWith<$Res> {
  factory $DailyAllowanceCopyWith(
    DailyAllowance value,
    $Res Function(DailyAllowance) then,
  ) = _$DailyAllowanceCopyWithImpl<$Res, DailyAllowance>;
  @useResult
  $Res call({
    int amount,
    String message,
    bool isOverBudget,
    int remaining,
    int daysLeft,
  });
}

/// @nodoc
class _$DailyAllowanceCopyWithImpl<$Res, $Val extends DailyAllowance>
    implements $DailyAllowanceCopyWith<$Res> {
  _$DailyAllowanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyAllowance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? message = null,
    Object? isOverBudget = null,
    Object? remaining = null,
    Object? daysLeft = null,
  }) {
    return _then(
      _value.copyWith(
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as int,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            isOverBudget: null == isOverBudget
                ? _value.isOverBudget
                : isOverBudget // ignore: cast_nullable_to_non_nullable
                      as bool,
            remaining: null == remaining
                ? _value.remaining
                : remaining // ignore: cast_nullable_to_non_nullable
                      as int,
            daysLeft: null == daysLeft
                ? _value.daysLeft
                : daysLeft // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyAllowanceImplCopyWith<$Res>
    implements $DailyAllowanceCopyWith<$Res> {
  factory _$$DailyAllowanceImplCopyWith(
    _$DailyAllowanceImpl value,
    $Res Function(_$DailyAllowanceImpl) then,
  ) = __$$DailyAllowanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int amount,
    String message,
    bool isOverBudget,
    int remaining,
    int daysLeft,
  });
}

/// @nodoc
class __$$DailyAllowanceImplCopyWithImpl<$Res>
    extends _$DailyAllowanceCopyWithImpl<$Res, _$DailyAllowanceImpl>
    implements _$$DailyAllowanceImplCopyWith<$Res> {
  __$$DailyAllowanceImplCopyWithImpl(
    _$DailyAllowanceImpl _value,
    $Res Function(_$DailyAllowanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyAllowance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? message = null,
    Object? isOverBudget = null,
    Object? remaining = null,
    Object? daysLeft = null,
  }) {
    return _then(
      _$DailyAllowanceImpl(
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as int,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        isOverBudget: null == isOverBudget
            ? _value.isOverBudget
            : isOverBudget // ignore: cast_nullable_to_non_nullable
                  as bool,
        remaining: null == remaining
            ? _value.remaining
            : remaining // ignore: cast_nullable_to_non_nullable
                  as int,
        daysLeft: null == daysLeft
            ? _value.daysLeft
            : daysLeft // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$DailyAllowanceImpl implements _DailyAllowance {
  const _$DailyAllowanceImpl({
    required this.amount,
    required this.message,
    required this.isOverBudget,
    required this.remaining,
    required this.daysLeft,
  });

  @override
  final int amount;
  // Integer daily allowance amount (in paise: e.g. 50000 = ₹500)
  @override
  final String message;
  @override
  final bool isOverBudget;
  @override
  final int remaining;
  // Integer remaining amount in paise
  @override
  final int daysLeft;

  @override
  String toString() {
    return 'DailyAllowance(amount: $amount, message: $message, isOverBudget: $isOverBudget, remaining: $remaining, daysLeft: $daysLeft)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyAllowanceImpl &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.isOverBudget, isOverBudget) ||
                other.isOverBudget == isOverBudget) &&
            (identical(other.remaining, remaining) ||
                other.remaining == remaining) &&
            (identical(other.daysLeft, daysLeft) ||
                other.daysLeft == daysLeft));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    amount,
    message,
    isOverBudget,
    remaining,
    daysLeft,
  );

  /// Create a copy of DailyAllowance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyAllowanceImplCopyWith<_$DailyAllowanceImpl> get copyWith =>
      __$$DailyAllowanceImplCopyWithImpl<_$DailyAllowanceImpl>(
        this,
        _$identity,
      );
}

abstract class _DailyAllowance implements DailyAllowance {
  const factory _DailyAllowance({
    required final int amount,
    required final String message,
    required final bool isOverBudget,
    required final int remaining,
    required final int daysLeft,
  }) = _$DailyAllowanceImpl;

  @override
  int get amount; // Integer daily allowance amount (in paise: e.g. 50000 = ₹500)
  @override
  String get message;
  @override
  bool get isOverBudget;
  @override
  int get remaining; // Integer remaining amount in paise
  @override
  int get daysLeft;

  /// Create a copy of DailyAllowance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyAllowanceImplCopyWith<_$DailyAllowanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
