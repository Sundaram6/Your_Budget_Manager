// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionListState {

 DateTime get selectedMonth; Map<DateTime, List<Transaction>> get groupedTransactions;
/// Create a copy of TransactionListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionListStateCopyWith<TransactionListState> get copyWith => _$TransactionListStateCopyWithImpl<TransactionListState>(this as TransactionListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionListState&&(identical(other.selectedMonth, selectedMonth) || other.selectedMonth == selectedMonth)&&const DeepCollectionEquality().equals(other.groupedTransactions, groupedTransactions));
}


@override
int get hashCode => Object.hash(runtimeType,selectedMonth,const DeepCollectionEquality().hash(groupedTransactions));

@override
String toString() {
  return 'TransactionListState(selectedMonth: $selectedMonth, groupedTransactions: $groupedTransactions)';
}


}

/// @nodoc
abstract mixin class $TransactionListStateCopyWith<$Res>  {
  factory $TransactionListStateCopyWith(TransactionListState value, $Res Function(TransactionListState) _then) = _$TransactionListStateCopyWithImpl;
@useResult
$Res call({
 DateTime selectedMonth, Map<DateTime, List<Transaction>> groupedTransactions
});




}
/// @nodoc
class _$TransactionListStateCopyWithImpl<$Res>
    implements $TransactionListStateCopyWith<$Res> {
  _$TransactionListStateCopyWithImpl(this._self, this._then);

  final TransactionListState _self;
  final $Res Function(TransactionListState) _then;

/// Create a copy of TransactionListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedMonth = null,Object? groupedTransactions = null,}) {
  return _then(_self.copyWith(
selectedMonth: null == selectedMonth ? _self.selectedMonth : selectedMonth // ignore: cast_nullable_to_non_nullable
as DateTime,groupedTransactions: null == groupedTransactions ? _self.groupedTransactions : groupedTransactions // ignore: cast_nullable_to_non_nullable
as Map<DateTime, List<Transaction>>,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionListState].
extension TransactionListStatePatterns on TransactionListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionListState value)  $default,){
final _that = this;
switch (_that) {
case _TransactionListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionListState value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime selectedMonth,  Map<DateTime, List<Transaction>> groupedTransactions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionListState() when $default != null:
return $default(_that.selectedMonth,_that.groupedTransactions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime selectedMonth,  Map<DateTime, List<Transaction>> groupedTransactions)  $default,) {final _that = this;
switch (_that) {
case _TransactionListState():
return $default(_that.selectedMonth,_that.groupedTransactions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime selectedMonth,  Map<DateTime, List<Transaction>> groupedTransactions)?  $default,) {final _that = this;
switch (_that) {
case _TransactionListState() when $default != null:
return $default(_that.selectedMonth,_that.groupedTransactions);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionListState implements TransactionListState {
  const _TransactionListState({required this.selectedMonth, required final  Map<DateTime, List<Transaction>> groupedTransactions}): _groupedTransactions = groupedTransactions;
  

@override final  DateTime selectedMonth;
 final  Map<DateTime, List<Transaction>> _groupedTransactions;
@override Map<DateTime, List<Transaction>> get groupedTransactions {
  if (_groupedTransactions is EqualUnmodifiableMapView) return _groupedTransactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_groupedTransactions);
}


/// Create a copy of TransactionListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionListStateCopyWith<_TransactionListState> get copyWith => __$TransactionListStateCopyWithImpl<_TransactionListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionListState&&(identical(other.selectedMonth, selectedMonth) || other.selectedMonth == selectedMonth)&&const DeepCollectionEquality().equals(other._groupedTransactions, _groupedTransactions));
}


@override
int get hashCode => Object.hash(runtimeType,selectedMonth,const DeepCollectionEquality().hash(_groupedTransactions));

@override
String toString() {
  return 'TransactionListState(selectedMonth: $selectedMonth, groupedTransactions: $groupedTransactions)';
}


}

/// @nodoc
abstract mixin class _$TransactionListStateCopyWith<$Res> implements $TransactionListStateCopyWith<$Res> {
  factory _$TransactionListStateCopyWith(_TransactionListState value, $Res Function(_TransactionListState) _then) = __$TransactionListStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime selectedMonth, Map<DateTime, List<Transaction>> groupedTransactions
});




}
/// @nodoc
class __$TransactionListStateCopyWithImpl<$Res>
    implements _$TransactionListStateCopyWith<$Res> {
  __$TransactionListStateCopyWithImpl(this._self, this._then);

  final _TransactionListState _self;
  final $Res Function(_TransactionListState) _then;

/// Create a copy of TransactionListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedMonth = null,Object? groupedTransactions = null,}) {
  return _then(_TransactionListState(
selectedMonth: null == selectedMonth ? _self.selectedMonth : selectedMonth // ignore: cast_nullable_to_non_nullable
as DateTime,groupedTransactions: null == groupedTransactions ? _self._groupedTransactions : groupedTransactions // ignore: cast_nullable_to_non_nullable
as Map<DateTime, List<Transaction>>,
  ));
}


}

// dart format on
