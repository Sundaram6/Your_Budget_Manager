// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavingsGoalModel {

 String get id; String get name; double get targetAmount; double get currentAmount; String? get categoryId; DateTime? get targetDate; DateTime get startDate; SavingsGoalStatus get status; String get iconName; String get colorHex; String? get note; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SavingsGoalModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingsGoalModelCopyWith<SavingsGoalModel> get copyWith => _$SavingsGoalModelCopyWithImpl<SavingsGoalModel>(this as SavingsGoalModel, _$identity);

  /// Serializes this SavingsGoalModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingsGoalModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,targetAmount,currentAmount,categoryId,targetDate,startDate,status,iconName,colorHex,note,createdAt,updatedAt);

@override
String toString() {
  return 'SavingsGoalModel(id: $id, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, categoryId: $categoryId, targetDate: $targetDate, startDate: $startDate, status: $status, iconName: $iconName, colorHex: $colorHex, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SavingsGoalModelCopyWith<$Res>  {
  factory $SavingsGoalModelCopyWith(SavingsGoalModel value, $Res Function(SavingsGoalModel) _then) = _$SavingsGoalModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, double targetAmount, double currentAmount, String? categoryId, DateTime? targetDate, DateTime startDate, SavingsGoalStatus status, String iconName, String colorHex, String? note, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SavingsGoalModelCopyWithImpl<$Res>
    implements $SavingsGoalModelCopyWith<$Res> {
  _$SavingsGoalModelCopyWithImpl(this._self, this._then);

  final SavingsGoalModel _self;
  final $Res Function(SavingsGoalModel) _then;

/// Create a copy of SavingsGoalModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? targetAmount = null,Object? currentAmount = null,Object? categoryId = freezed,Object? targetDate = freezed,Object? startDate = null,Object? status = null,Object? iconName = null,Object? colorHex = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double,currentAmount: null == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as double,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SavingsGoalStatus,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingsGoalModel].
extension SavingsGoalModelPatterns on SavingsGoalModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingsGoalModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingsGoalModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingsGoalModel value)  $default,){
final _that = this;
switch (_that) {
case _SavingsGoalModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingsGoalModel value)?  $default,){
final _that = this;
switch (_that) {
case _SavingsGoalModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double targetAmount,  double currentAmount,  String? categoryId,  DateTime? targetDate,  DateTime startDate,  SavingsGoalStatus status,  String iconName,  String colorHex,  String? note,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingsGoalModel() when $default != null:
return $default(_that.id,_that.name,_that.targetAmount,_that.currentAmount,_that.categoryId,_that.targetDate,_that.startDate,_that.status,_that.iconName,_that.colorHex,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double targetAmount,  double currentAmount,  String? categoryId,  DateTime? targetDate,  DateTime startDate,  SavingsGoalStatus status,  String iconName,  String colorHex,  String? note,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SavingsGoalModel():
return $default(_that.id,_that.name,_that.targetAmount,_that.currentAmount,_that.categoryId,_that.targetDate,_that.startDate,_that.status,_that.iconName,_that.colorHex,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double targetAmount,  double currentAmount,  String? categoryId,  DateTime? targetDate,  DateTime startDate,  SavingsGoalStatus status,  String iconName,  String colorHex,  String? note,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SavingsGoalModel() when $default != null:
return $default(_that.id,_that.name,_that.targetAmount,_that.currentAmount,_that.categoryId,_that.targetDate,_that.startDate,_that.status,_that.iconName,_that.colorHex,_that.note,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingsGoalModel extends SavingsGoalModel {
  const _SavingsGoalModel({required this.id, required this.name, required this.targetAmount, required this.currentAmount, this.categoryId, this.targetDate, required this.startDate, required this.status, required this.iconName, required this.colorHex, this.note, required this.createdAt, required this.updatedAt}): super._();
  factory _SavingsGoalModel.fromJson(Map<String, dynamic> json) => _$SavingsGoalModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  double targetAmount;
@override final  double currentAmount;
@override final  String? categoryId;
@override final  DateTime? targetDate;
@override final  DateTime startDate;
@override final  SavingsGoalStatus status;
@override final  String iconName;
@override final  String colorHex;
@override final  String? note;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SavingsGoalModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingsGoalModelCopyWith<_SavingsGoalModel> get copyWith => __$SavingsGoalModelCopyWithImpl<_SavingsGoalModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingsGoalModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingsGoalModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,targetAmount,currentAmount,categoryId,targetDate,startDate,status,iconName,colorHex,note,createdAt,updatedAt);

@override
String toString() {
  return 'SavingsGoalModel(id: $id, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, categoryId: $categoryId, targetDate: $targetDate, startDate: $startDate, status: $status, iconName: $iconName, colorHex: $colorHex, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SavingsGoalModelCopyWith<$Res> implements $SavingsGoalModelCopyWith<$Res> {
  factory _$SavingsGoalModelCopyWith(_SavingsGoalModel value, $Res Function(_SavingsGoalModel) _then) = __$SavingsGoalModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double targetAmount, double currentAmount, String? categoryId, DateTime? targetDate, DateTime startDate, SavingsGoalStatus status, String iconName, String colorHex, String? note, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SavingsGoalModelCopyWithImpl<$Res>
    implements _$SavingsGoalModelCopyWith<$Res> {
  __$SavingsGoalModelCopyWithImpl(this._self, this._then);

  final _SavingsGoalModel _self;
  final $Res Function(_SavingsGoalModel) _then;

/// Create a copy of SavingsGoalModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? targetAmount = null,Object? currentAmount = null,Object? categoryId = freezed,Object? targetDate = freezed,Object? startDate = null,Object? status = null,Object? iconName = null,Object? colorHex = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SavingsGoalModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double,currentAmount: null == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as double,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SavingsGoalStatus,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
