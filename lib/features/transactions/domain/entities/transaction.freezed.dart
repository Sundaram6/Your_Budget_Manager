// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Transaction {

 String get id;@AmountConverter() Amount get amount; DateTime get date; String get categoryId; TransactionType get type; String? get note; String? get sourceApp; PaymentMethod get paymentMethod; String? get cardLast4; String? get accountLast4; String? get transactionRef; String? get transferPairId; bool get isRecurring; String? get recurringId; String? get merchantName; String? get merchantId; String? get recurrenceOccurrenceKey; String? get sourceMessageId; int? get createdAt; int? get updatedAt;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.type, type) || other.type == type)&&(identical(other.note, note) || other.note == note)&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.cardLast4, cardLast4) || other.cardLast4 == cardLast4)&&(identical(other.accountLast4, accountLast4) || other.accountLast4 == accountLast4)&&(identical(other.transactionRef, transactionRef) || other.transactionRef == transactionRef)&&(identical(other.transferPairId, transferPairId) || other.transferPairId == transferPairId)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurringId, recurringId) || other.recurringId == recurringId)&&(identical(other.merchantName, merchantName) || other.merchantName == merchantName)&&(identical(other.merchantId, merchantId) || other.merchantId == merchantId)&&(identical(other.recurrenceOccurrenceKey, recurrenceOccurrenceKey) || other.recurrenceOccurrenceKey == recurrenceOccurrenceKey)&&(identical(other.sourceMessageId, sourceMessageId) || other.sourceMessageId == sourceMessageId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,amount,date,categoryId,type,note,sourceApp,paymentMethod,cardLast4,accountLast4,transactionRef,transferPairId,isRecurring,recurringId,merchantName,merchantId,recurrenceOccurrenceKey,sourceMessageId,createdAt,updatedAt]);

@override
String toString() {
  return 'Transaction(id: $id, amount: $amount, date: $date, categoryId: $categoryId, type: $type, note: $note, sourceApp: $sourceApp, paymentMethod: $paymentMethod, cardLast4: $cardLast4, accountLast4: $accountLast4, transactionRef: $transactionRef, transferPairId: $transferPairId, isRecurring: $isRecurring, recurringId: $recurringId, merchantName: $merchantName, merchantId: $merchantId, recurrenceOccurrenceKey: $recurrenceOccurrenceKey, sourceMessageId: $sourceMessageId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
 String id,@AmountConverter() Amount amount, DateTime date, String categoryId, TransactionType type, String? note, String? sourceApp, PaymentMethod paymentMethod, String? cardLast4, String? accountLast4, String? transactionRef, String? transferPairId, bool isRecurring, String? recurringId, String? merchantName, String? merchantId, String? recurrenceOccurrenceKey, String? sourceMessageId, int? createdAt, int? updatedAt
});


$AmountCopyWith<$Res> get amount;

}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? date = null,Object? categoryId = null,Object? type = null,Object? note = freezed,Object? sourceApp = freezed,Object? paymentMethod = null,Object? cardLast4 = freezed,Object? accountLast4 = freezed,Object? transactionRef = freezed,Object? transferPairId = freezed,Object? isRecurring = null,Object? recurringId = freezed,Object? merchantName = freezed,Object? merchantId = freezed,Object? recurrenceOccurrenceKey = freezed,Object? sourceMessageId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Amount,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,sourceApp: freezed == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,cardLast4: freezed == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String?,accountLast4: freezed == accountLast4 ? _self.accountLast4 : accountLast4 // ignore: cast_nullable_to_non_nullable
as String?,transactionRef: freezed == transactionRef ? _self.transactionRef : transactionRef // ignore: cast_nullable_to_non_nullable
as String?,transferPairId: freezed == transferPairId ? _self.transferPairId : transferPairId // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringId: freezed == recurringId ? _self.recurringId : recurringId // ignore: cast_nullable_to_non_nullable
as String?,merchantName: freezed == merchantName ? _self.merchantName : merchantName // ignore: cast_nullable_to_non_nullable
as String?,merchantId: freezed == merchantId ? _self.merchantId : merchantId // ignore: cast_nullable_to_non_nullable
as String?,recurrenceOccurrenceKey: freezed == recurrenceOccurrenceKey ? _self.recurrenceOccurrenceKey : recurrenceOccurrenceKey // ignore: cast_nullable_to_non_nullable
as String?,sourceMessageId: freezed == sourceMessageId ? _self.sourceMessageId : sourceMessageId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AmountCopyWith<$Res> get amount {
  
  return $AmountCopyWith<$Res>(_self.amount, (value) {
    return _then(_self.copyWith(amount: value));
  });
}
}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transaction value)  $default,){
final _that = this;
switch (_that) {
case _Transaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transaction value)?  $default,){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @AmountConverter()  Amount amount,  DateTime date,  String categoryId,  TransactionType type,  String? note,  String? sourceApp,  PaymentMethod paymentMethod,  String? cardLast4,  String? accountLast4,  String? transactionRef,  String? transferPairId,  bool isRecurring,  String? recurringId,  String? merchantName,  String? merchantId,  String? recurrenceOccurrenceKey,  String? sourceMessageId,  int? createdAt,  int? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.amount,_that.date,_that.categoryId,_that.type,_that.note,_that.sourceApp,_that.paymentMethod,_that.cardLast4,_that.accountLast4,_that.transactionRef,_that.transferPairId,_that.isRecurring,_that.recurringId,_that.merchantName,_that.merchantId,_that.recurrenceOccurrenceKey,_that.sourceMessageId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @AmountConverter()  Amount amount,  DateTime date,  String categoryId,  TransactionType type,  String? note,  String? sourceApp,  PaymentMethod paymentMethod,  String? cardLast4,  String? accountLast4,  String? transactionRef,  String? transferPairId,  bool isRecurring,  String? recurringId,  String? merchantName,  String? merchantId,  String? recurrenceOccurrenceKey,  String? sourceMessageId,  int? createdAt,  int? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Transaction():
return $default(_that.id,_that.amount,_that.date,_that.categoryId,_that.type,_that.note,_that.sourceApp,_that.paymentMethod,_that.cardLast4,_that.accountLast4,_that.transactionRef,_that.transferPairId,_that.isRecurring,_that.recurringId,_that.merchantName,_that.merchantId,_that.recurrenceOccurrenceKey,_that.sourceMessageId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @AmountConverter()  Amount amount,  DateTime date,  String categoryId,  TransactionType type,  String? note,  String? sourceApp,  PaymentMethod paymentMethod,  String? cardLast4,  String? accountLast4,  String? transactionRef,  String? transferPairId,  bool isRecurring,  String? recurringId,  String? merchantName,  String? merchantId,  String? recurrenceOccurrenceKey,  String? sourceMessageId,  int? createdAt,  int? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.amount,_that.date,_that.categoryId,_that.type,_that.note,_that.sourceApp,_that.paymentMethod,_that.cardLast4,_that.accountLast4,_that.transactionRef,_that.transferPairId,_that.isRecurring,_that.recurringId,_that.merchantName,_that.merchantId,_that.recurrenceOccurrenceKey,_that.sourceMessageId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Transaction extends Transaction {
  const _Transaction({required this.id, @AmountConverter() required this.amount, required this.date, required this.categoryId, required this.type, this.note, this.sourceApp, this.paymentMethod = PaymentMethod.unknown, this.cardLast4, this.accountLast4, this.transactionRef, this.transferPairId, this.isRecurring = false, this.recurringId, this.merchantName, this.merchantId, this.recurrenceOccurrenceKey, this.sourceMessageId, this.createdAt, this.updatedAt}): super._();
  factory _Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);

@override final  String id;
@override@AmountConverter() final  Amount amount;
@override final  DateTime date;
@override final  String categoryId;
@override final  TransactionType type;
@override final  String? note;
@override final  String? sourceApp;
@override@JsonKey() final  PaymentMethod paymentMethod;
@override final  String? cardLast4;
@override final  String? accountLast4;
@override final  String? transactionRef;
@override final  String? transferPairId;
@override@JsonKey() final  bool isRecurring;
@override final  String? recurringId;
@override final  String? merchantName;
@override final  String? merchantId;
@override final  String? recurrenceOccurrenceKey;
@override final  String? sourceMessageId;
@override final  int? createdAt;
@override final  int? updatedAt;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCopyWith<_Transaction> get copyWith => __$TransactionCopyWithImpl<_Transaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.type, type) || other.type == type)&&(identical(other.note, note) || other.note == note)&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.cardLast4, cardLast4) || other.cardLast4 == cardLast4)&&(identical(other.accountLast4, accountLast4) || other.accountLast4 == accountLast4)&&(identical(other.transactionRef, transactionRef) || other.transactionRef == transactionRef)&&(identical(other.transferPairId, transferPairId) || other.transferPairId == transferPairId)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurringId, recurringId) || other.recurringId == recurringId)&&(identical(other.merchantName, merchantName) || other.merchantName == merchantName)&&(identical(other.merchantId, merchantId) || other.merchantId == merchantId)&&(identical(other.recurrenceOccurrenceKey, recurrenceOccurrenceKey) || other.recurrenceOccurrenceKey == recurrenceOccurrenceKey)&&(identical(other.sourceMessageId, sourceMessageId) || other.sourceMessageId == sourceMessageId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,amount,date,categoryId,type,note,sourceApp,paymentMethod,cardLast4,accountLast4,transactionRef,transferPairId,isRecurring,recurringId,merchantName,merchantId,recurrenceOccurrenceKey,sourceMessageId,createdAt,updatedAt]);

@override
String toString() {
  return 'Transaction(id: $id, amount: $amount, date: $date, categoryId: $categoryId, type: $type, note: $note, sourceApp: $sourceApp, paymentMethod: $paymentMethod, cardLast4: $cardLast4, accountLast4: $accountLast4, transactionRef: $transactionRef, transferPairId: $transferPairId, isRecurring: $isRecurring, recurringId: $recurringId, merchantName: $merchantName, merchantId: $merchantId, recurrenceOccurrenceKey: $recurrenceOccurrenceKey, sourceMessageId: $sourceMessageId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(_Transaction value, $Res Function(_Transaction) _then) = __$TransactionCopyWithImpl;
@override @useResult
$Res call({
 String id,@AmountConverter() Amount amount, DateTime date, String categoryId, TransactionType type, String? note, String? sourceApp, PaymentMethod paymentMethod, String? cardLast4, String? accountLast4, String? transactionRef, String? transferPairId, bool isRecurring, String? recurringId, String? merchantName, String? merchantId, String? recurrenceOccurrenceKey, String? sourceMessageId, int? createdAt, int? updatedAt
});


@override $AmountCopyWith<$Res> get amount;

}
/// @nodoc
class __$TransactionCopyWithImpl<$Res>
    implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? date = null,Object? categoryId = null,Object? type = null,Object? note = freezed,Object? sourceApp = freezed,Object? paymentMethod = null,Object? cardLast4 = freezed,Object? accountLast4 = freezed,Object? transactionRef = freezed,Object? transferPairId = freezed,Object? isRecurring = null,Object? recurringId = freezed,Object? merchantName = freezed,Object? merchantId = freezed,Object? recurrenceOccurrenceKey = freezed,Object? sourceMessageId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Amount,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,sourceApp: freezed == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,cardLast4: freezed == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String?,accountLast4: freezed == accountLast4 ? _self.accountLast4 : accountLast4 // ignore: cast_nullable_to_non_nullable
as String?,transactionRef: freezed == transactionRef ? _self.transactionRef : transactionRef // ignore: cast_nullable_to_non_nullable
as String?,transferPairId: freezed == transferPairId ? _self.transferPairId : transferPairId // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringId: freezed == recurringId ? _self.recurringId : recurringId // ignore: cast_nullable_to_non_nullable
as String?,merchantName: freezed == merchantName ? _self.merchantName : merchantName // ignore: cast_nullable_to_non_nullable
as String?,merchantId: freezed == merchantId ? _self.merchantId : merchantId // ignore: cast_nullable_to_non_nullable
as String?,recurrenceOccurrenceKey: freezed == recurrenceOccurrenceKey ? _self.recurrenceOccurrenceKey : recurrenceOccurrenceKey // ignore: cast_nullable_to_non_nullable
as String?,sourceMessageId: freezed == sourceMessageId ? _self.sourceMessageId : sourceMessageId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AmountCopyWith<$Res> get amount {
  
  return $AmountCopyWith<$Res>(_self.amount, (value) {
    return _then(_self.copyWith(amount: value));
  });
}
}

// dart format on
