// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_allowance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyAllowance {

 int get amount; String get message; bool get isOverBudget; int get remaining; int get daysLeft;
/// Create a copy of DailyAllowance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyAllowanceCopyWith<DailyAllowance> get copyWith => _$DailyAllowanceCopyWithImpl<DailyAllowance>(this as DailyAllowance, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyAllowance&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.message, message) || other.message == message)&&(identical(other.isOverBudget, isOverBudget) || other.isOverBudget == isOverBudget)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft));
}


@override
int get hashCode => Object.hash(runtimeType,amount,message,isOverBudget,remaining,daysLeft);

@override
String toString() {
  return 'DailyAllowance(amount: $amount, message: $message, isOverBudget: $isOverBudget, remaining: $remaining, daysLeft: $daysLeft)';
}


}

/// @nodoc
abstract mixin class $DailyAllowanceCopyWith<$Res>  {
  factory $DailyAllowanceCopyWith(DailyAllowance value, $Res Function(DailyAllowance) _then) = _$DailyAllowanceCopyWithImpl;
@useResult
$Res call({
 int amount, String message, bool isOverBudget, int remaining, int daysLeft
});




}
/// @nodoc
class _$DailyAllowanceCopyWithImpl<$Res>
    implements $DailyAllowanceCopyWith<$Res> {
  _$DailyAllowanceCopyWithImpl(this._self, this._then);

  final DailyAllowance _self;
  final $Res Function(DailyAllowance) _then;

/// Create a copy of DailyAllowance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,Object? message = null,Object? isOverBudget = null,Object? remaining = null,Object? daysLeft = null,}) {
  return _then(_self.copyWith(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isOverBudget: null == isOverBudget ? _self.isOverBudget : isOverBudget // ignore: cast_nullable_to_non_nullable
as bool,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyAllowance].
extension DailyAllowancePatterns on DailyAllowance {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyAllowance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyAllowance() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyAllowance value)  $default,){
final _that = this;
switch (_that) {
case _DailyAllowance():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyAllowance value)?  $default,){
final _that = this;
switch (_that) {
case _DailyAllowance() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int amount,  String message,  bool isOverBudget,  int remaining,  int daysLeft)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyAllowance() when $default != null:
return $default(_that.amount,_that.message,_that.isOverBudget,_that.remaining,_that.daysLeft);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int amount,  String message,  bool isOverBudget,  int remaining,  int daysLeft)  $default,) {final _that = this;
switch (_that) {
case _DailyAllowance():
return $default(_that.amount,_that.message,_that.isOverBudget,_that.remaining,_that.daysLeft);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int amount,  String message,  bool isOverBudget,  int remaining,  int daysLeft)?  $default,) {final _that = this;
switch (_that) {
case _DailyAllowance() when $default != null:
return $default(_that.amount,_that.message,_that.isOverBudget,_that.remaining,_that.daysLeft);case _:
  return null;

}
}

}

/// @nodoc


class _DailyAllowance implements DailyAllowance {
  const _DailyAllowance({required this.amount, required this.message, required this.isOverBudget, required this.remaining, required this.daysLeft});
  

@override final  int amount;
@override final  String message;
@override final  bool isOverBudget;
@override final  int remaining;
@override final  int daysLeft;

/// Create a copy of DailyAllowance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyAllowanceCopyWith<_DailyAllowance> get copyWith => __$DailyAllowanceCopyWithImpl<_DailyAllowance>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyAllowance&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.message, message) || other.message == message)&&(identical(other.isOverBudget, isOverBudget) || other.isOverBudget == isOverBudget)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft));
}


@override
int get hashCode => Object.hash(runtimeType,amount,message,isOverBudget,remaining,daysLeft);

@override
String toString() {
  return 'DailyAllowance(amount: $amount, message: $message, isOverBudget: $isOverBudget, remaining: $remaining, daysLeft: $daysLeft)';
}


}

/// @nodoc
abstract mixin class _$DailyAllowanceCopyWith<$Res> implements $DailyAllowanceCopyWith<$Res> {
  factory _$DailyAllowanceCopyWith(_DailyAllowance value, $Res Function(_DailyAllowance) _then) = __$DailyAllowanceCopyWithImpl;
@override @useResult
$Res call({
 int amount, String message, bool isOverBudget, int remaining, int daysLeft
});




}
/// @nodoc
class __$DailyAllowanceCopyWithImpl<$Res>
    implements _$DailyAllowanceCopyWith<$Res> {
  __$DailyAllowanceCopyWithImpl(this._self, this._then);

  final _DailyAllowance _self;
  final $Res Function(_DailyAllowance) _then;

/// Create a copy of DailyAllowance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? message = null,Object? isOverBudget = null,Object? remaining = null,Object? daysLeft = null,}) {
  return _then(_DailyAllowance(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isOverBudget: null == isOverBudget ? _self.isOverBudget : isOverBudget // ignore: cast_nullable_to_non_nullable
as bool,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
