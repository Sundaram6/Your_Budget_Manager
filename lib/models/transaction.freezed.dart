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
mixin _$TransactionModel {

 String get id; String? get title;@JsonKey(name: 'amount_paise') int get amountPaise;@JsonKey(name: 'category_id') String get categoryId; String get type;@YyyyMmDdConverter() DateTime get date; String? get notes;@JsonKey(name: 'is_recurring') bool get isRecurring;@JsonKey(name: 'recurring_id') String? get recurringId;@JsonKey(name: 'is_auto_captured') bool get isAutoCaptured;@JsonKey(name: 'source_app') String? get sourceApp;@JsonKey(name: 'payment_method') String? get paymentMethod;@JsonKey(name: 'card_last_4') String? get cardLast4;@Iso8601Converter()@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionModelCopyWith<TransactionModel> get copyWith => _$TransactionModelCopyWithImpl<TransactionModel>(this as TransactionModel, _$identity);

  /// Serializes this TransactionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.type, type) || other.type == type)&&(identical(other.date, date) || other.date == date)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurringId, recurringId) || other.recurringId == recurringId)&&(identical(other.isAutoCaptured, isAutoCaptured) || other.isAutoCaptured == isAutoCaptured)&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.cardLast4, cardLast4) || other.cardLast4 == cardLast4)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,amountPaise,categoryId,type,date,notes,isRecurring,recurringId,isAutoCaptured,sourceApp,paymentMethod,cardLast4,createdAt);

@override
String toString() {
  return 'TransactionModel(id: $id, title: $title, amountPaise: $amountPaise, categoryId: $categoryId, type: $type, date: $date, notes: $notes, isRecurring: $isRecurring, recurringId: $recurringId, isAutoCaptured: $isAutoCaptured, sourceApp: $sourceApp, paymentMethod: $paymentMethod, cardLast4: $cardLast4, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TransactionModelCopyWith<$Res>  {
  factory $TransactionModelCopyWith(TransactionModel value, $Res Function(TransactionModel) _then) = _$TransactionModelCopyWithImpl;
@useResult
$Res call({
 String id, String? title,@JsonKey(name: 'amount_paise') int amountPaise,@JsonKey(name: 'category_id') String categoryId, String type,@YyyyMmDdConverter() DateTime date, String? notes,@JsonKey(name: 'is_recurring') bool isRecurring,@JsonKey(name: 'recurring_id') String? recurringId,@JsonKey(name: 'is_auto_captured') bool isAutoCaptured,@JsonKey(name: 'source_app') String? sourceApp,@JsonKey(name: 'payment_method') String? paymentMethod,@JsonKey(name: 'card_last_4') String? cardLast4,@Iso8601Converter()@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$TransactionModelCopyWithImpl<$Res>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._self, this._then);

  final TransactionModel _self;
  final $Res Function(TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? amountPaise = null,Object? categoryId = null,Object? type = null,Object? date = null,Object? notes = freezed,Object? isRecurring = null,Object? recurringId = freezed,Object? isAutoCaptured = null,Object? sourceApp = freezed,Object? paymentMethod = freezed,Object? cardLast4 = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringId: freezed == recurringId ? _self.recurringId : recurringId // ignore: cast_nullable_to_non_nullable
as String?,isAutoCaptured: null == isAutoCaptured ? _self.isAutoCaptured : isAutoCaptured // ignore: cast_nullable_to_non_nullable
as bool,sourceApp: freezed == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,cardLast4: freezed == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionModel].
extension TransactionModelPatterns on TransactionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionModel value)  $default,){
final _that = this;
switch (_that) {
case _TransactionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title, @JsonKey(name: 'amount_paise')  int amountPaise, @JsonKey(name: 'category_id')  String categoryId,  String type, @YyyyMmDdConverter()  DateTime date,  String? notes, @JsonKey(name: 'is_recurring')  bool isRecurring, @JsonKey(name: 'recurring_id')  String? recurringId, @JsonKey(name: 'is_auto_captured')  bool isAutoCaptured, @JsonKey(name: 'source_app')  String? sourceApp, @JsonKey(name: 'payment_method')  String? paymentMethod, @JsonKey(name: 'card_last_4')  String? cardLast4, @Iso8601Converter()@JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.title,_that.amountPaise,_that.categoryId,_that.type,_that.date,_that.notes,_that.isRecurring,_that.recurringId,_that.isAutoCaptured,_that.sourceApp,_that.paymentMethod,_that.cardLast4,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title, @JsonKey(name: 'amount_paise')  int amountPaise, @JsonKey(name: 'category_id')  String categoryId,  String type, @YyyyMmDdConverter()  DateTime date,  String? notes, @JsonKey(name: 'is_recurring')  bool isRecurring, @JsonKey(name: 'recurring_id')  String? recurringId, @JsonKey(name: 'is_auto_captured')  bool isAutoCaptured, @JsonKey(name: 'source_app')  String? sourceApp, @JsonKey(name: 'payment_method')  String? paymentMethod, @JsonKey(name: 'card_last_4')  String? cardLast4, @Iso8601Converter()@JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _TransactionModel():
return $default(_that.id,_that.title,_that.amountPaise,_that.categoryId,_that.type,_that.date,_that.notes,_that.isRecurring,_that.recurringId,_that.isAutoCaptured,_that.sourceApp,_that.paymentMethod,_that.cardLast4,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title, @JsonKey(name: 'amount_paise')  int amountPaise, @JsonKey(name: 'category_id')  String categoryId,  String type, @YyyyMmDdConverter()  DateTime date,  String? notes, @JsonKey(name: 'is_recurring')  bool isRecurring, @JsonKey(name: 'recurring_id')  String? recurringId, @JsonKey(name: 'is_auto_captured')  bool isAutoCaptured, @JsonKey(name: 'source_app')  String? sourceApp, @JsonKey(name: 'payment_method')  String? paymentMethod, @JsonKey(name: 'card_last_4')  String? cardLast4, @Iso8601Converter()@JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.title,_that.amountPaise,_that.categoryId,_that.type,_that.date,_that.notes,_that.isRecurring,_that.recurringId,_that.isAutoCaptured,_that.sourceApp,_that.paymentMethod,_that.cardLast4,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionModel implements TransactionModel {
  const _TransactionModel({required this.id, this.title, @JsonKey(name: 'amount_paise') required this.amountPaise, @JsonKey(name: 'category_id') required this.categoryId, required this.type, @YyyyMmDdConverter() required this.date, this.notes, @JsonKey(name: 'is_recurring') this.isRecurring = false, @JsonKey(name: 'recurring_id') this.recurringId, @JsonKey(name: 'is_auto_captured') this.isAutoCaptured = false, @JsonKey(name: 'source_app') this.sourceApp, @JsonKey(name: 'payment_method') this.paymentMethod, @JsonKey(name: 'card_last_4') this.cardLast4, @Iso8601Converter()@JsonKey(name: 'created_at') this.createdAt});
  factory _TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);

@override final  String id;
@override final  String? title;
@override@JsonKey(name: 'amount_paise') final  int amountPaise;
@override@JsonKey(name: 'category_id') final  String categoryId;
@override final  String type;
@override@YyyyMmDdConverter() final  DateTime date;
@override final  String? notes;
@override@JsonKey(name: 'is_recurring') final  bool isRecurring;
@override@JsonKey(name: 'recurring_id') final  String? recurringId;
@override@JsonKey(name: 'is_auto_captured') final  bool isAutoCaptured;
@override@JsonKey(name: 'source_app') final  String? sourceApp;
@override@JsonKey(name: 'payment_method') final  String? paymentMethod;
@override@JsonKey(name: 'card_last_4') final  String? cardLast4;
@override@Iso8601Converter()@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionModelCopyWith<_TransactionModel> get copyWith => __$TransactionModelCopyWithImpl<_TransactionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.type, type) || other.type == type)&&(identical(other.date, date) || other.date == date)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurringId, recurringId) || other.recurringId == recurringId)&&(identical(other.isAutoCaptured, isAutoCaptured) || other.isAutoCaptured == isAutoCaptured)&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.cardLast4, cardLast4) || other.cardLast4 == cardLast4)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,amountPaise,categoryId,type,date,notes,isRecurring,recurringId,isAutoCaptured,sourceApp,paymentMethod,cardLast4,createdAt);

@override
String toString() {
  return 'TransactionModel(id: $id, title: $title, amountPaise: $amountPaise, categoryId: $categoryId, type: $type, date: $date, notes: $notes, isRecurring: $isRecurring, recurringId: $recurringId, isAutoCaptured: $isAutoCaptured, sourceApp: $sourceApp, paymentMethod: $paymentMethod, cardLast4: $cardLast4, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionModelCopyWith<$Res> implements $TransactionModelCopyWith<$Res> {
  factory _$TransactionModelCopyWith(_TransactionModel value, $Res Function(_TransactionModel) _then) = __$TransactionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title,@JsonKey(name: 'amount_paise') int amountPaise,@JsonKey(name: 'category_id') String categoryId, String type,@YyyyMmDdConverter() DateTime date, String? notes,@JsonKey(name: 'is_recurring') bool isRecurring,@JsonKey(name: 'recurring_id') String? recurringId,@JsonKey(name: 'is_auto_captured') bool isAutoCaptured,@JsonKey(name: 'source_app') String? sourceApp,@JsonKey(name: 'payment_method') String? paymentMethod,@JsonKey(name: 'card_last_4') String? cardLast4,@Iso8601Converter()@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$TransactionModelCopyWithImpl<$Res>
    implements _$TransactionModelCopyWith<$Res> {
  __$TransactionModelCopyWithImpl(this._self, this._then);

  final _TransactionModel _self;
  final $Res Function(_TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? amountPaise = null,Object? categoryId = null,Object? type = null,Object? date = null,Object? notes = freezed,Object? isRecurring = null,Object? recurringId = freezed,Object? isAutoCaptured = null,Object? sourceApp = freezed,Object? paymentMethod = freezed,Object? cardLast4 = freezed,Object? createdAt = freezed,}) {
  return _then(_TransactionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringId: freezed == recurringId ? _self.recurringId : recurringId // ignore: cast_nullable_to_non_nullable
as String?,isAutoCaptured: null == isAutoCaptured ? _self.isAutoCaptured : isAutoCaptured // ignore: cast_nullable_to_non_nullable
as bool,sourceApp: freezed == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,cardLast4: freezed == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
