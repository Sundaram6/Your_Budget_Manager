// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetProgress {

 int get spent; int get limit; double get percentage; bool get isOverBudget; int get committedRecurring; int get committedSavings; int get totalCommitted; int get remaining;
/// Create a copy of BudgetProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetProgressCopyWith<BudgetProgress> get copyWith => _$BudgetProgressCopyWithImpl<BudgetProgress>(this as BudgetProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetProgress&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.isOverBudget, isOverBudget) || other.isOverBudget == isOverBudget)&&(identical(other.committedRecurring, committedRecurring) || other.committedRecurring == committedRecurring)&&(identical(other.committedSavings, committedSavings) || other.committedSavings == committedSavings)&&(identical(other.totalCommitted, totalCommitted) || other.totalCommitted == totalCommitted)&&(identical(other.remaining, remaining) || other.remaining == remaining));
}


@override
int get hashCode => Object.hash(runtimeType,spent,limit,percentage,isOverBudget,committedRecurring,committedSavings,totalCommitted,remaining);

@override
String toString() {
  return 'BudgetProgress(spent: $spent, limit: $limit, percentage: $percentage, isOverBudget: $isOverBudget, committedRecurring: $committedRecurring, committedSavings: $committedSavings, totalCommitted: $totalCommitted, remaining: $remaining)';
}


}

/// @nodoc
abstract mixin class $BudgetProgressCopyWith<$Res>  {
  factory $BudgetProgressCopyWith(BudgetProgress value, $Res Function(BudgetProgress) _then) = _$BudgetProgressCopyWithImpl;
@useResult
$Res call({
 int spent, int limit, double percentage, bool isOverBudget, int committedRecurring, int committedSavings, int totalCommitted, int remaining
});




}
/// @nodoc
class _$BudgetProgressCopyWithImpl<$Res>
    implements $BudgetProgressCopyWith<$Res> {
  _$BudgetProgressCopyWithImpl(this._self, this._then);

  final BudgetProgress _self;
  final $Res Function(BudgetProgress) _then;

/// Create a copy of BudgetProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? spent = null,Object? limit = null,Object? percentage = null,Object? isOverBudget = null,Object? committedRecurring = null,Object? committedSavings = null,Object? totalCommitted = null,Object? remaining = null,}) {
  return _then(_self.copyWith(
spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,isOverBudget: null == isOverBudget ? _self.isOverBudget : isOverBudget // ignore: cast_nullable_to_non_nullable
as bool,committedRecurring: null == committedRecurring ? _self.committedRecurring : committedRecurring // ignore: cast_nullable_to_non_nullable
as int,committedSavings: null == committedSavings ? _self.committedSavings : committedSavings // ignore: cast_nullable_to_non_nullable
as int,totalCommitted: null == totalCommitted ? _self.totalCommitted : totalCommitted // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetProgress].
extension BudgetProgressPatterns on BudgetProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetProgress value)  $default,){
final _that = this;
switch (_that) {
case _BudgetProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetProgress value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int spent,  int limit,  double percentage,  bool isOverBudget,  int committedRecurring,  int committedSavings,  int totalCommitted,  int remaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetProgress() when $default != null:
return $default(_that.spent,_that.limit,_that.percentage,_that.isOverBudget,_that.committedRecurring,_that.committedSavings,_that.totalCommitted,_that.remaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int spent,  int limit,  double percentage,  bool isOverBudget,  int committedRecurring,  int committedSavings,  int totalCommitted,  int remaining)  $default,) {final _that = this;
switch (_that) {
case _BudgetProgress():
return $default(_that.spent,_that.limit,_that.percentage,_that.isOverBudget,_that.committedRecurring,_that.committedSavings,_that.totalCommitted,_that.remaining);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int spent,  int limit,  double percentage,  bool isOverBudget,  int committedRecurring,  int committedSavings,  int totalCommitted,  int remaining)?  $default,) {final _that = this;
switch (_that) {
case _BudgetProgress() when $default != null:
return $default(_that.spent,_that.limit,_that.percentage,_that.isOverBudget,_that.committedRecurring,_that.committedSavings,_that.totalCommitted,_that.remaining);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetProgress implements BudgetProgress {
  const _BudgetProgress({required this.spent, required this.limit, required this.percentage, required this.isOverBudget, this.committedRecurring = 0, this.committedSavings = 0, this.totalCommitted = 0, this.remaining = 0});
  

@override final  int spent;
@override final  int limit;
@override final  double percentage;
@override final  bool isOverBudget;
@override@JsonKey() final  int committedRecurring;
@override@JsonKey() final  int committedSavings;
@override@JsonKey() final  int totalCommitted;
@override@JsonKey() final  int remaining;

/// Create a copy of BudgetProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetProgressCopyWith<_BudgetProgress> get copyWith => __$BudgetProgressCopyWithImpl<_BudgetProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetProgress&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.isOverBudget, isOverBudget) || other.isOverBudget == isOverBudget)&&(identical(other.committedRecurring, committedRecurring) || other.committedRecurring == committedRecurring)&&(identical(other.committedSavings, committedSavings) || other.committedSavings == committedSavings)&&(identical(other.totalCommitted, totalCommitted) || other.totalCommitted == totalCommitted)&&(identical(other.remaining, remaining) || other.remaining == remaining));
}


@override
int get hashCode => Object.hash(runtimeType,spent,limit,percentage,isOverBudget,committedRecurring,committedSavings,totalCommitted,remaining);

@override
String toString() {
  return 'BudgetProgress(spent: $spent, limit: $limit, percentage: $percentage, isOverBudget: $isOverBudget, committedRecurring: $committedRecurring, committedSavings: $committedSavings, totalCommitted: $totalCommitted, remaining: $remaining)';
}


}

/// @nodoc
abstract mixin class _$BudgetProgressCopyWith<$Res> implements $BudgetProgressCopyWith<$Res> {
  factory _$BudgetProgressCopyWith(_BudgetProgress value, $Res Function(_BudgetProgress) _then) = __$BudgetProgressCopyWithImpl;
@override @useResult
$Res call({
 int spent, int limit, double percentage, bool isOverBudget, int committedRecurring, int committedSavings, int totalCommitted, int remaining
});




}
/// @nodoc
class __$BudgetProgressCopyWithImpl<$Res>
    implements _$BudgetProgressCopyWith<$Res> {
  __$BudgetProgressCopyWithImpl(this._self, this._then);

  final _BudgetProgress _self;
  final $Res Function(_BudgetProgress) _then;

/// Create a copy of BudgetProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? spent = null,Object? limit = null,Object? percentage = null,Object? isOverBudget = null,Object? committedRecurring = null,Object? committedSavings = null,Object? totalCommitted = null,Object? remaining = null,}) {
  return _then(_BudgetProgress(
spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,isOverBudget: null == isOverBudget ? _self.isOverBudget : isOverBudget // ignore: cast_nullable_to_non_nullable
as bool,committedRecurring: null == committedRecurring ? _self.committedRecurring : committedRecurring // ignore: cast_nullable_to_non_nullable
as int,committedSavings: null == committedSavings ? _self.committedSavings : committedSavings // ignore: cast_nullable_to_non_nullable
as int,totalCommitted: null == totalCommitted ? _self.totalCommitted : totalCommitted // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
