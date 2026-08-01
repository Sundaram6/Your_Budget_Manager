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
  double get amount => throw _privateConstructorUsedError;
  double get remaining => throw _privateConstructorUsedError;
  int get daysLeft => throw _privateConstructorUsedError;
  bool get isHealthy => throw _privateConstructorUsedError;

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
  $Res call({double amount, double remaining, int daysLeft, bool isHealthy});
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
    Object? remaining = null,
    Object? daysLeft = null,
    Object? isHealthy = null,
  }) {
    return _then(
      _value.copyWith(
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            remaining: null == remaining
                ? _value.remaining
                : remaining // ignore: cast_nullable_to_non_nullable
                      as double,
            daysLeft: null == daysLeft
                ? _value.daysLeft
                : daysLeft // ignore: cast_nullable_to_non_nullable
                      as int,
            isHealthy: null == isHealthy
                ? _value.isHealthy
                : isHealthy // ignore: cast_nullable_to_non_nullable
                      as bool,
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
  $Res call({double amount, double remaining, int daysLeft, bool isHealthy});
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
    Object? remaining = null,
    Object? daysLeft = null,
    Object? isHealthy = null,
  }) {
    return _then(
      _$DailyAllowanceImpl(
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        remaining: null == remaining
            ? _value.remaining
            : remaining // ignore: cast_nullable_to_non_nullable
                  as double,
        daysLeft: null == daysLeft
            ? _value.daysLeft
            : daysLeft // ignore: cast_nullable_to_non_nullable
                  as int,
        isHealthy: null == isHealthy
            ? _value.isHealthy
            : isHealthy // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$DailyAllowanceImpl implements _DailyAllowance {
  const _$DailyAllowanceImpl({
    required this.amount,
    required this.remaining,
    required this.daysLeft,
    required this.isHealthy,
  });

  @override
  final double amount;
  @override
  final double remaining;
  @override
  final int daysLeft;
  @override
  final bool isHealthy;

  @override
  String toString() {
    return 'DailyAllowance(amount: $amount, remaining: $remaining, daysLeft: $daysLeft, isHealthy: $isHealthy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyAllowanceImpl &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.remaining, remaining) ||
                other.remaining == remaining) &&
            (identical(other.daysLeft, daysLeft) ||
                other.daysLeft == daysLeft) &&
            (identical(other.isHealthy, isHealthy) ||
                other.isHealthy == isHealthy));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, amount, remaining, daysLeft, isHealthy);

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
    required final double amount,
    required final double remaining,
    required final int daysLeft,
    required final bool isHealthy,
  }) = _$DailyAllowanceImpl;

  @override
  double get amount;
  @override
  double get remaining;
  @override
  int get daysLeft;
  @override
  bool get isHealthy;

  /// Create a copy of DailyAllowance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyAllowanceImplCopyWith<_$DailyAllowanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
