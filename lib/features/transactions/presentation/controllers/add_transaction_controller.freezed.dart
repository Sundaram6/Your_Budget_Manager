// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_transaction_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddTransactionState {

 Transaction? get existingTransaction; int get amount; TransactionType get type; String? get selectedCategoryId; DateTime get date; String get note; PaymentMethod get paymentMethod; bool get isSaving; String? get error;
/// Create a copy of AddTransactionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddTransactionStateCopyWith<AddTransactionState> get copyWith => _$AddTransactionStateCopyWithImpl<AddTransactionState>(this as AddTransactionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddTransactionState&&(identical(other.existingTransaction, existingTransaction) || other.existingTransaction == existingTransaction)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.selectedCategoryId, selectedCategoryId) || other.selectedCategoryId == selectedCategoryId)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,existingTransaction,amount,type,selectedCategoryId,date,note,paymentMethod,isSaving,error);

@override
String toString() {
  return 'AddTransactionState(existingTransaction: $existingTransaction, amount: $amount, type: $type, selectedCategoryId: $selectedCategoryId, date: $date, note: $note, paymentMethod: $paymentMethod, isSaving: $isSaving, error: $error)';
}


}

/// @nodoc
abstract mixin class $AddTransactionStateCopyWith<$Res>  {
  factory $AddTransactionStateCopyWith(AddTransactionState value, $Res Function(AddTransactionState) _then) = _$AddTransactionStateCopyWithImpl;
@useResult
$Res call({
 Transaction? existingTransaction, int amount, TransactionType type, String? selectedCategoryId, DateTime date, String note, PaymentMethod paymentMethod, bool isSaving, String? error
});


$TransactionCopyWith<$Res>? get existingTransaction;

}
/// @nodoc
class _$AddTransactionStateCopyWithImpl<$Res>
    implements $AddTransactionStateCopyWith<$Res> {
  _$AddTransactionStateCopyWithImpl(this._self, this._then);

  final AddTransactionState _self;
  final $Res Function(AddTransactionState) _then;

/// Create a copy of AddTransactionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? existingTransaction = freezed,Object? amount = null,Object? type = null,Object? selectedCategoryId = freezed,Object? date = null,Object? note = null,Object? paymentMethod = null,Object? isSaving = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
existingTransaction: freezed == existingTransaction ? _self.existingTransaction : existingTransaction // ignore: cast_nullable_to_non_nullable
as Transaction?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,selectedCategoryId: freezed == selectedCategoryId ? _self.selectedCategoryId : selectedCategoryId // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AddTransactionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionCopyWith<$Res>? get existingTransaction {
    if (_self.existingTransaction == null) {
    return null;
  }

  return $TransactionCopyWith<$Res>(_self.existingTransaction!, (value) {
    return _then(_self.copyWith(existingTransaction: value));
  });
}
}


/// Adds pattern-matching-related methods to [AddTransactionState].
extension AddTransactionStatePatterns on AddTransactionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddTransactionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddTransactionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddTransactionState value)  $default,){
final _that = this;
switch (_that) {
case _AddTransactionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddTransactionState value)?  $default,){
final _that = this;
switch (_that) {
case _AddTransactionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Transaction? existingTransaction,  int amount,  TransactionType type,  String? selectedCategoryId,  DateTime date,  String note,  PaymentMethod paymentMethod,  bool isSaving,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddTransactionState() when $default != null:
return $default(_that.existingTransaction,_that.amount,_that.type,_that.selectedCategoryId,_that.date,_that.note,_that.paymentMethod,_that.isSaving,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Transaction? existingTransaction,  int amount,  TransactionType type,  String? selectedCategoryId,  DateTime date,  String note,  PaymentMethod paymentMethod,  bool isSaving,  String? error)  $default,) {final _that = this;
switch (_that) {
case _AddTransactionState():
return $default(_that.existingTransaction,_that.amount,_that.type,_that.selectedCategoryId,_that.date,_that.note,_that.paymentMethod,_that.isSaving,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Transaction? existingTransaction,  int amount,  TransactionType type,  String? selectedCategoryId,  DateTime date,  String note,  PaymentMethod paymentMethod,  bool isSaving,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _AddTransactionState() when $default != null:
return $default(_that.existingTransaction,_that.amount,_that.type,_that.selectedCategoryId,_that.date,_that.note,_that.paymentMethod,_that.isSaving,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _AddTransactionState implements AddTransactionState {
  const _AddTransactionState({this.existingTransaction, this.amount = 0, this.type = TransactionType.expense, this.selectedCategoryId, required this.date, this.note = '', this.paymentMethod = PaymentMethod.cash, this.isSaving = false, this.error});
  

@override final  Transaction? existingTransaction;
@override@JsonKey() final  int amount;
@override@JsonKey() final  TransactionType type;
@override final  String? selectedCategoryId;
@override final  DateTime date;
@override@JsonKey() final  String note;
@override@JsonKey() final  PaymentMethod paymentMethod;
@override@JsonKey() final  bool isSaving;
@override final  String? error;

/// Create a copy of AddTransactionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddTransactionStateCopyWith<_AddTransactionState> get copyWith => __$AddTransactionStateCopyWithImpl<_AddTransactionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddTransactionState&&(identical(other.existingTransaction, existingTransaction) || other.existingTransaction == existingTransaction)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.selectedCategoryId, selectedCategoryId) || other.selectedCategoryId == selectedCategoryId)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,existingTransaction,amount,type,selectedCategoryId,date,note,paymentMethod,isSaving,error);

@override
String toString() {
  return 'AddTransactionState(existingTransaction: $existingTransaction, amount: $amount, type: $type, selectedCategoryId: $selectedCategoryId, date: $date, note: $note, paymentMethod: $paymentMethod, isSaving: $isSaving, error: $error)';
}


}

/// @nodoc
abstract mixin class _$AddTransactionStateCopyWith<$Res> implements $AddTransactionStateCopyWith<$Res> {
  factory _$AddTransactionStateCopyWith(_AddTransactionState value, $Res Function(_AddTransactionState) _then) = __$AddTransactionStateCopyWithImpl;
@override @useResult
$Res call({
 Transaction? existingTransaction, int amount, TransactionType type, String? selectedCategoryId, DateTime date, String note, PaymentMethod paymentMethod, bool isSaving, String? error
});


@override $TransactionCopyWith<$Res>? get existingTransaction;

}
/// @nodoc
class __$AddTransactionStateCopyWithImpl<$Res>
    implements _$AddTransactionStateCopyWith<$Res> {
  __$AddTransactionStateCopyWithImpl(this._self, this._then);

  final _AddTransactionState _self;
  final $Res Function(_AddTransactionState) _then;

/// Create a copy of AddTransactionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? existingTransaction = freezed,Object? amount = null,Object? type = null,Object? selectedCategoryId = freezed,Object? date = null,Object? note = null,Object? paymentMethod = null,Object? isSaving = null,Object? error = freezed,}) {
  return _then(_AddTransactionState(
existingTransaction: freezed == existingTransaction ? _self.existingTransaction : existingTransaction // ignore: cast_nullable_to_non_nullable
as Transaction?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,selectedCategoryId: freezed == selectedCategoryId ? _self.selectedCategoryId : selectedCategoryId // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AddTransactionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionCopyWith<$Res>? get existingTransaction {
    if (_self.existingTransaction == null) {
    return null;
  }

  return $TransactionCopyWith<$Res>(_self.existingTransaction!, (value) {
    return _then(_self.copyWith(existingTransaction: value));
  });
}
}

// dart format on
