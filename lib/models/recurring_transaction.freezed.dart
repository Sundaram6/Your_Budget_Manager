// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurringTransactionModel {

 String get id; String get title;@JsonKey(name: 'amount_paise') int get amountPaise;@JsonKey(name: 'category_id') String get categoryId; String get type; String get frequency;@JsonKey(name: 'interval_days') int? get intervalDays;@YyyyMmDdConverter()@JsonKey(name: 'start_date') DateTime get startDate;@NullableYyyyMmDdConverter()@JsonKey(name: 'end_date') DateTime? get endDate;@YyyyMmDdConverter()@JsonKey(name: 'next_due_date') DateTime get nextDueDate;@NullableYyyyMmDdConverter()@JsonKey(name: 'last_generated_date') DateTime? get lastGeneratedDate;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'auto_confirm') bool get autoConfirm; String? get notes;@Iso8601Converter()@JsonKey(name: 'created_at') DateTime get createdAt;@Iso8601Converter()@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of RecurringTransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringTransactionModelCopyWith<RecurringTransactionModel> get copyWith => _$RecurringTransactionModelCopyWithImpl<RecurringTransactionModel>(this as RecurringTransactionModel, _$identity);

  /// Serializes this RecurringTransactionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringTransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.type, type) || other.type == type)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.intervalDays, intervalDays) || other.intervalDays == intervalDays)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.nextDueDate, nextDueDate) || other.nextDueDate == nextDueDate)&&(identical(other.lastGeneratedDate, lastGeneratedDate) || other.lastGeneratedDate == lastGeneratedDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.autoConfirm, autoConfirm) || other.autoConfirm == autoConfirm)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,amountPaise,categoryId,type,frequency,intervalDays,startDate,endDate,nextDueDate,lastGeneratedDate,isActive,autoConfirm,notes,createdAt,updatedAt);

@override
String toString() {
  return 'RecurringTransactionModel(id: $id, title: $title, amountPaise: $amountPaise, categoryId: $categoryId, type: $type, frequency: $frequency, intervalDays: $intervalDays, startDate: $startDate, endDate: $endDate, nextDueDate: $nextDueDate, lastGeneratedDate: $lastGeneratedDate, isActive: $isActive, autoConfirm: $autoConfirm, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RecurringTransactionModelCopyWith<$Res>  {
  factory $RecurringTransactionModelCopyWith(RecurringTransactionModel value, $Res Function(RecurringTransactionModel) _then) = _$RecurringTransactionModelCopyWithImpl;
@useResult
$Res call({
 String id, String title,@JsonKey(name: 'amount_paise') int amountPaise,@JsonKey(name: 'category_id') String categoryId, String type, String frequency,@JsonKey(name: 'interval_days') int? intervalDays,@YyyyMmDdConverter()@JsonKey(name: 'start_date') DateTime startDate,@NullableYyyyMmDdConverter()@JsonKey(name: 'end_date') DateTime? endDate,@YyyyMmDdConverter()@JsonKey(name: 'next_due_date') DateTime nextDueDate,@NullableYyyyMmDdConverter()@JsonKey(name: 'last_generated_date') DateTime? lastGeneratedDate,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'auto_confirm') bool autoConfirm, String? notes,@Iso8601Converter()@JsonKey(name: 'created_at') DateTime createdAt,@Iso8601Converter()@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$RecurringTransactionModelCopyWithImpl<$Res>
    implements $RecurringTransactionModelCopyWith<$Res> {
  _$RecurringTransactionModelCopyWithImpl(this._self, this._then);

  final RecurringTransactionModel _self;
  final $Res Function(RecurringTransactionModel) _then;

/// Create a copy of RecurringTransactionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? amountPaise = null,Object? categoryId = null,Object? type = null,Object? frequency = null,Object? intervalDays = freezed,Object? startDate = null,Object? endDate = freezed,Object? nextDueDate = null,Object? lastGeneratedDate = freezed,Object? isActive = null,Object? autoConfirm = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,intervalDays: freezed == intervalDays ? _self.intervalDays : intervalDays // ignore: cast_nullable_to_non_nullable
as int?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,nextDueDate: null == nextDueDate ? _self.nextDueDate : nextDueDate // ignore: cast_nullable_to_non_nullable
as DateTime,lastGeneratedDate: freezed == lastGeneratedDate ? _self.lastGeneratedDate : lastGeneratedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,autoConfirm: null == autoConfirm ? _self.autoConfirm : autoConfirm // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringTransactionModel].
extension RecurringTransactionModelPatterns on RecurringTransactionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringTransactionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringTransactionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringTransactionModel value)  $default,){
final _that = this;
switch (_that) {
case _RecurringTransactionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringTransactionModel value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringTransactionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'amount_paise')  int amountPaise, @JsonKey(name: 'category_id')  String categoryId,  String type,  String frequency, @JsonKey(name: 'interval_days')  int? intervalDays, @YyyyMmDdConverter()@JsonKey(name: 'start_date')  DateTime startDate, @NullableYyyyMmDdConverter()@JsonKey(name: 'end_date')  DateTime? endDate, @YyyyMmDdConverter()@JsonKey(name: 'next_due_date')  DateTime nextDueDate, @NullableYyyyMmDdConverter()@JsonKey(name: 'last_generated_date')  DateTime? lastGeneratedDate, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'auto_confirm')  bool autoConfirm,  String? notes, @Iso8601Converter()@JsonKey(name: 'created_at')  DateTime createdAt, @Iso8601Converter()@JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringTransactionModel() when $default != null:
return $default(_that.id,_that.title,_that.amountPaise,_that.categoryId,_that.type,_that.frequency,_that.intervalDays,_that.startDate,_that.endDate,_that.nextDueDate,_that.lastGeneratedDate,_that.isActive,_that.autoConfirm,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'amount_paise')  int amountPaise, @JsonKey(name: 'category_id')  String categoryId,  String type,  String frequency, @JsonKey(name: 'interval_days')  int? intervalDays, @YyyyMmDdConverter()@JsonKey(name: 'start_date')  DateTime startDate, @NullableYyyyMmDdConverter()@JsonKey(name: 'end_date')  DateTime? endDate, @YyyyMmDdConverter()@JsonKey(name: 'next_due_date')  DateTime nextDueDate, @NullableYyyyMmDdConverter()@JsonKey(name: 'last_generated_date')  DateTime? lastGeneratedDate, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'auto_confirm')  bool autoConfirm,  String? notes, @Iso8601Converter()@JsonKey(name: 'created_at')  DateTime createdAt, @Iso8601Converter()@JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RecurringTransactionModel():
return $default(_that.id,_that.title,_that.amountPaise,_that.categoryId,_that.type,_that.frequency,_that.intervalDays,_that.startDate,_that.endDate,_that.nextDueDate,_that.lastGeneratedDate,_that.isActive,_that.autoConfirm,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @JsonKey(name: 'amount_paise')  int amountPaise, @JsonKey(name: 'category_id')  String categoryId,  String type,  String frequency, @JsonKey(name: 'interval_days')  int? intervalDays, @YyyyMmDdConverter()@JsonKey(name: 'start_date')  DateTime startDate, @NullableYyyyMmDdConverter()@JsonKey(name: 'end_date')  DateTime? endDate, @YyyyMmDdConverter()@JsonKey(name: 'next_due_date')  DateTime nextDueDate, @NullableYyyyMmDdConverter()@JsonKey(name: 'last_generated_date')  DateTime? lastGeneratedDate, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'auto_confirm')  bool autoConfirm,  String? notes, @Iso8601Converter()@JsonKey(name: 'created_at')  DateTime createdAt, @Iso8601Converter()@JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RecurringTransactionModel() when $default != null:
return $default(_that.id,_that.title,_that.amountPaise,_that.categoryId,_that.type,_that.frequency,_that.intervalDays,_that.startDate,_that.endDate,_that.nextDueDate,_that.lastGeneratedDate,_that.isActive,_that.autoConfirm,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringTransactionModel implements RecurringTransactionModel {
  const _RecurringTransactionModel({required this.id, required this.title, @JsonKey(name: 'amount_paise') required this.amountPaise, @JsonKey(name: 'category_id') required this.categoryId, required this.type, required this.frequency, @JsonKey(name: 'interval_days') this.intervalDays, @YyyyMmDdConverter()@JsonKey(name: 'start_date') required this.startDate, @NullableYyyyMmDdConverter()@JsonKey(name: 'end_date') this.endDate, @YyyyMmDdConverter()@JsonKey(name: 'next_due_date') required this.nextDueDate, @NullableYyyyMmDdConverter()@JsonKey(name: 'last_generated_date') this.lastGeneratedDate, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'auto_confirm') this.autoConfirm = false, this.notes, @Iso8601Converter()@JsonKey(name: 'created_at') required this.createdAt, @Iso8601Converter()@JsonKey(name: 'updated_at') required this.updatedAt});
  factory _RecurringTransactionModel.fromJson(Map<String, dynamic> json) => _$RecurringTransactionModelFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey(name: 'amount_paise') final  int amountPaise;
@override@JsonKey(name: 'category_id') final  String categoryId;
@override final  String type;
@override final  String frequency;
@override@JsonKey(name: 'interval_days') final  int? intervalDays;
@override@YyyyMmDdConverter()@JsonKey(name: 'start_date') final  DateTime startDate;
@override@NullableYyyyMmDdConverter()@JsonKey(name: 'end_date') final  DateTime? endDate;
@override@YyyyMmDdConverter()@JsonKey(name: 'next_due_date') final  DateTime nextDueDate;
@override@NullableYyyyMmDdConverter()@JsonKey(name: 'last_generated_date') final  DateTime? lastGeneratedDate;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'auto_confirm') final  bool autoConfirm;
@override final  String? notes;
@override@Iso8601Converter()@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@Iso8601Converter()@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of RecurringTransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringTransactionModelCopyWith<_RecurringTransactionModel> get copyWith => __$RecurringTransactionModelCopyWithImpl<_RecurringTransactionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringTransactionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringTransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.type, type) || other.type == type)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.intervalDays, intervalDays) || other.intervalDays == intervalDays)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.nextDueDate, nextDueDate) || other.nextDueDate == nextDueDate)&&(identical(other.lastGeneratedDate, lastGeneratedDate) || other.lastGeneratedDate == lastGeneratedDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.autoConfirm, autoConfirm) || other.autoConfirm == autoConfirm)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,amountPaise,categoryId,type,frequency,intervalDays,startDate,endDate,nextDueDate,lastGeneratedDate,isActive,autoConfirm,notes,createdAt,updatedAt);

@override
String toString() {
  return 'RecurringTransactionModel(id: $id, title: $title, amountPaise: $amountPaise, categoryId: $categoryId, type: $type, frequency: $frequency, intervalDays: $intervalDays, startDate: $startDate, endDate: $endDate, nextDueDate: $nextDueDate, lastGeneratedDate: $lastGeneratedDate, isActive: $isActive, autoConfirm: $autoConfirm, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RecurringTransactionModelCopyWith<$Res> implements $RecurringTransactionModelCopyWith<$Res> {
  factory _$RecurringTransactionModelCopyWith(_RecurringTransactionModel value, $Res Function(_RecurringTransactionModel) _then) = __$RecurringTransactionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@JsonKey(name: 'amount_paise') int amountPaise,@JsonKey(name: 'category_id') String categoryId, String type, String frequency,@JsonKey(name: 'interval_days') int? intervalDays,@YyyyMmDdConverter()@JsonKey(name: 'start_date') DateTime startDate,@NullableYyyyMmDdConverter()@JsonKey(name: 'end_date') DateTime? endDate,@YyyyMmDdConverter()@JsonKey(name: 'next_due_date') DateTime nextDueDate,@NullableYyyyMmDdConverter()@JsonKey(name: 'last_generated_date') DateTime? lastGeneratedDate,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'auto_confirm') bool autoConfirm, String? notes,@Iso8601Converter()@JsonKey(name: 'created_at') DateTime createdAt,@Iso8601Converter()@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$RecurringTransactionModelCopyWithImpl<$Res>
    implements _$RecurringTransactionModelCopyWith<$Res> {
  __$RecurringTransactionModelCopyWithImpl(this._self, this._then);

  final _RecurringTransactionModel _self;
  final $Res Function(_RecurringTransactionModel) _then;

/// Create a copy of RecurringTransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? amountPaise = null,Object? categoryId = null,Object? type = null,Object? frequency = null,Object? intervalDays = freezed,Object? startDate = null,Object? endDate = freezed,Object? nextDueDate = null,Object? lastGeneratedDate = freezed,Object? isActive = null,Object? autoConfirm = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_RecurringTransactionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,intervalDays: freezed == intervalDays ? _self.intervalDays : intervalDays // ignore: cast_nullable_to_non_nullable
as int?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,nextDueDate: null == nextDueDate ? _self.nextDueDate : nextDueDate // ignore: cast_nullable_to_non_nullable
as DateTime,lastGeneratedDate: freezed == lastGeneratedDate ? _self.lastGeneratedDate : lastGeneratedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,autoConfirm: null == autoConfirm ? _self.autoConfirm : autoConfirm // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
