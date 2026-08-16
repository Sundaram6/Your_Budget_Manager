// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParsedTransaction {

 String get smsId; int get amount; DateTime get date; TransactionType get type; String get merchantName; String get merchantId; String get categoryId; String get originalSmsBody; String get sourceApp; PaymentMethod get paymentMethod; String? get cardLast4; String? get accountLast4; String? get transactionRef;
/// Create a copy of ParsedTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedTransactionCopyWith<ParsedTransaction> get copyWith => _$ParsedTransactionCopyWithImpl<ParsedTransaction>(this as ParsedTransaction, _$identity);

  /// Serializes this ParsedTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedTransaction&&(identical(other.smsId, smsId) || other.smsId == smsId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.type, type) || other.type == type)&&(identical(other.merchantName, merchantName) || other.merchantName == merchantName)&&(identical(other.merchantId, merchantId) || other.merchantId == merchantId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.originalSmsBody, originalSmsBody) || other.originalSmsBody == originalSmsBody)&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.cardLast4, cardLast4) || other.cardLast4 == cardLast4)&&(identical(other.accountLast4, accountLast4) || other.accountLast4 == accountLast4)&&(identical(other.transactionRef, transactionRef) || other.transactionRef == transactionRef));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,smsId,amount,date,type,merchantName,merchantId,categoryId,originalSmsBody,sourceApp,paymentMethod,cardLast4,accountLast4,transactionRef);

@override
String toString() {
  return 'ParsedTransaction(smsId: $smsId, amount: $amount, date: $date, type: $type, merchantName: $merchantName, merchantId: $merchantId, categoryId: $categoryId, originalSmsBody: $originalSmsBody, sourceApp: $sourceApp, paymentMethod: $paymentMethod, cardLast4: $cardLast4, accountLast4: $accountLast4, transactionRef: $transactionRef)';
}


}

/// @nodoc
abstract mixin class $ParsedTransactionCopyWith<$Res>  {
  factory $ParsedTransactionCopyWith(ParsedTransaction value, $Res Function(ParsedTransaction) _then) = _$ParsedTransactionCopyWithImpl;
@useResult
$Res call({
 String smsId, int amount, DateTime date, TransactionType type, String merchantName, String merchantId, String categoryId, String originalSmsBody, String sourceApp, PaymentMethod paymentMethod, String? cardLast4, String? accountLast4, String? transactionRef
});




}
/// @nodoc
class _$ParsedTransactionCopyWithImpl<$Res>
    implements $ParsedTransactionCopyWith<$Res> {
  _$ParsedTransactionCopyWithImpl(this._self, this._then);

  final ParsedTransaction _self;
  final $Res Function(ParsedTransaction) _then;

/// Create a copy of ParsedTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? smsId = null,Object? amount = null,Object? date = null,Object? type = null,Object? merchantName = null,Object? merchantId = null,Object? categoryId = null,Object? originalSmsBody = null,Object? sourceApp = null,Object? paymentMethod = null,Object? cardLast4 = freezed,Object? accountLast4 = freezed,Object? transactionRef = freezed,}) {
  return _then(_self.copyWith(
smsId: null == smsId ? _self.smsId : smsId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,merchantName: null == merchantName ? _self.merchantName : merchantName // ignore: cast_nullable_to_non_nullable
as String,merchantId: null == merchantId ? _self.merchantId : merchantId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,originalSmsBody: null == originalSmsBody ? _self.originalSmsBody : originalSmsBody // ignore: cast_nullable_to_non_nullable
as String,sourceApp: null == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,cardLast4: freezed == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String?,accountLast4: freezed == accountLast4 ? _self.accountLast4 : accountLast4 // ignore: cast_nullable_to_non_nullable
as String?,transactionRef: freezed == transactionRef ? _self.transactionRef : transactionRef // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedTransaction].
extension ParsedTransactionPatterns on ParsedTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedTransaction value)  $default,){
final _that = this;
switch (_that) {
case _ParsedTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String smsId,  int amount,  DateTime date,  TransactionType type,  String merchantName,  String merchantId,  String categoryId,  String originalSmsBody,  String sourceApp,  PaymentMethod paymentMethod,  String? cardLast4,  String? accountLast4,  String? transactionRef)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedTransaction() when $default != null:
return $default(_that.smsId,_that.amount,_that.date,_that.type,_that.merchantName,_that.merchantId,_that.categoryId,_that.originalSmsBody,_that.sourceApp,_that.paymentMethod,_that.cardLast4,_that.accountLast4,_that.transactionRef);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String smsId,  int amount,  DateTime date,  TransactionType type,  String merchantName,  String merchantId,  String categoryId,  String originalSmsBody,  String sourceApp,  PaymentMethod paymentMethod,  String? cardLast4,  String? accountLast4,  String? transactionRef)  $default,) {final _that = this;
switch (_that) {
case _ParsedTransaction():
return $default(_that.smsId,_that.amount,_that.date,_that.type,_that.merchantName,_that.merchantId,_that.categoryId,_that.originalSmsBody,_that.sourceApp,_that.paymentMethod,_that.cardLast4,_that.accountLast4,_that.transactionRef);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String smsId,  int amount,  DateTime date,  TransactionType type,  String merchantName,  String merchantId,  String categoryId,  String originalSmsBody,  String sourceApp,  PaymentMethod paymentMethod,  String? cardLast4,  String? accountLast4,  String? transactionRef)?  $default,) {final _that = this;
switch (_that) {
case _ParsedTransaction() when $default != null:
return $default(_that.smsId,_that.amount,_that.date,_that.type,_that.merchantName,_that.merchantId,_that.categoryId,_that.originalSmsBody,_that.sourceApp,_that.paymentMethod,_that.cardLast4,_that.accountLast4,_that.transactionRef);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParsedTransaction implements ParsedTransaction {
  const _ParsedTransaction({required this.smsId, required this.amount, required this.date, required this.type, required this.merchantName, required this.merchantId, required this.categoryId, required this.originalSmsBody, required this.sourceApp, this.paymentMethod = PaymentMethod.unknown, this.cardLast4, this.accountLast4, this.transactionRef});
  factory _ParsedTransaction.fromJson(Map<String, dynamic> json) => _$ParsedTransactionFromJson(json);

@override final  String smsId;
@override final  int amount;
@override final  DateTime date;
@override final  TransactionType type;
@override final  String merchantName;
@override final  String merchantId;
@override final  String categoryId;
@override final  String originalSmsBody;
@override final  String sourceApp;
@override@JsonKey() final  PaymentMethod paymentMethod;
@override final  String? cardLast4;
@override final  String? accountLast4;
@override final  String? transactionRef;

/// Create a copy of ParsedTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedTransactionCopyWith<_ParsedTransaction> get copyWith => __$ParsedTransactionCopyWithImpl<_ParsedTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParsedTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedTransaction&&(identical(other.smsId, smsId) || other.smsId == smsId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.type, type) || other.type == type)&&(identical(other.merchantName, merchantName) || other.merchantName == merchantName)&&(identical(other.merchantId, merchantId) || other.merchantId == merchantId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.originalSmsBody, originalSmsBody) || other.originalSmsBody == originalSmsBody)&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.cardLast4, cardLast4) || other.cardLast4 == cardLast4)&&(identical(other.accountLast4, accountLast4) || other.accountLast4 == accountLast4)&&(identical(other.transactionRef, transactionRef) || other.transactionRef == transactionRef));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,smsId,amount,date,type,merchantName,merchantId,categoryId,originalSmsBody,sourceApp,paymentMethod,cardLast4,accountLast4,transactionRef);

@override
String toString() {
  return 'ParsedTransaction(smsId: $smsId, amount: $amount, date: $date, type: $type, merchantName: $merchantName, merchantId: $merchantId, categoryId: $categoryId, originalSmsBody: $originalSmsBody, sourceApp: $sourceApp, paymentMethod: $paymentMethod, cardLast4: $cardLast4, accountLast4: $accountLast4, transactionRef: $transactionRef)';
}


}

/// @nodoc
abstract mixin class _$ParsedTransactionCopyWith<$Res> implements $ParsedTransactionCopyWith<$Res> {
  factory _$ParsedTransactionCopyWith(_ParsedTransaction value, $Res Function(_ParsedTransaction) _then) = __$ParsedTransactionCopyWithImpl;
@override @useResult
$Res call({
 String smsId, int amount, DateTime date, TransactionType type, String merchantName, String merchantId, String categoryId, String originalSmsBody, String sourceApp, PaymentMethod paymentMethod, String? cardLast4, String? accountLast4, String? transactionRef
});




}
/// @nodoc
class __$ParsedTransactionCopyWithImpl<$Res>
    implements _$ParsedTransactionCopyWith<$Res> {
  __$ParsedTransactionCopyWithImpl(this._self, this._then);

  final _ParsedTransaction _self;
  final $Res Function(_ParsedTransaction) _then;

/// Create a copy of ParsedTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? smsId = null,Object? amount = null,Object? date = null,Object? type = null,Object? merchantName = null,Object? merchantId = null,Object? categoryId = null,Object? originalSmsBody = null,Object? sourceApp = null,Object? paymentMethod = null,Object? cardLast4 = freezed,Object? accountLast4 = freezed,Object? transactionRef = freezed,}) {
  return _then(_ParsedTransaction(
smsId: null == smsId ? _self.smsId : smsId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,merchantName: null == merchantName ? _self.merchantName : merchantName // ignore: cast_nullable_to_non_nullable
as String,merchantId: null == merchantId ? _self.merchantId : merchantId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,originalSmsBody: null == originalSmsBody ? _self.originalSmsBody : originalSmsBody // ignore: cast_nullable_to_non_nullable
as String,sourceApp: null == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,cardLast4: freezed == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String?,accountLast4: freezed == accountLast4 ? _self.accountLast4 : accountLast4 // ignore: cast_nullable_to_non_nullable
as String?,transactionRef: freezed == transactionRef ? _self.transactionRef : transactionRef // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
