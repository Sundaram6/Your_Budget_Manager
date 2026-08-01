// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BackupMetadata _$BackupMetadataFromJson(Map<String, dynamic> json) {
  return _BackupMetadata.fromJson(json);
}

/// @nodoc
mixin _$BackupMetadata {
  String get formatVersion => throw _privateConstructorUsedError;
  String get appVersion => throw _privateConstructorUsedError;
  DateTime get exportedAt => throw _privateConstructorUsedError;
  int get dbSchemaVersion => throw _privateConstructorUsedError;

  /// Serializes this BackupMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupMetadataCopyWith<BackupMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupMetadataCopyWith<$Res> {
  factory $BackupMetadataCopyWith(
    BackupMetadata value,
    $Res Function(BackupMetadata) then,
  ) = _$BackupMetadataCopyWithImpl<$Res, BackupMetadata>;
  @useResult
  $Res call({
    String formatVersion,
    String appVersion,
    DateTime exportedAt,
    int dbSchemaVersion,
  });
}

/// @nodoc
class _$BackupMetadataCopyWithImpl<$Res, $Val extends BackupMetadata>
    implements $BackupMetadataCopyWith<$Res> {
  _$BackupMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? formatVersion = null,
    Object? appVersion = null,
    Object? exportedAt = null,
    Object? dbSchemaVersion = null,
  }) {
    return _then(
      _value.copyWith(
            formatVersion: null == formatVersion
                ? _value.formatVersion
                : formatVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            appVersion: null == appVersion
                ? _value.appVersion
                : appVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            exportedAt: null == exportedAt
                ? _value.exportedAt
                : exportedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dbSchemaVersion: null == dbSchemaVersion
                ? _value.dbSchemaVersion
                : dbSchemaVersion // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BackupMetadataImplCopyWith<$Res>
    implements $BackupMetadataCopyWith<$Res> {
  factory _$$BackupMetadataImplCopyWith(
    _$BackupMetadataImpl value,
    $Res Function(_$BackupMetadataImpl) then,
  ) = __$$BackupMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String formatVersion,
    String appVersion,
    DateTime exportedAt,
    int dbSchemaVersion,
  });
}

/// @nodoc
class __$$BackupMetadataImplCopyWithImpl<$Res>
    extends _$BackupMetadataCopyWithImpl<$Res, _$BackupMetadataImpl>
    implements _$$BackupMetadataImplCopyWith<$Res> {
  __$$BackupMetadataImplCopyWithImpl(
    _$BackupMetadataImpl _value,
    $Res Function(_$BackupMetadataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? formatVersion = null,
    Object? appVersion = null,
    Object? exportedAt = null,
    Object? dbSchemaVersion = null,
  }) {
    return _then(
      _$BackupMetadataImpl(
        formatVersion: null == formatVersion
            ? _value.formatVersion
            : formatVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        appVersion: null == appVersion
            ? _value.appVersion
            : appVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        exportedAt: null == exportedAt
            ? _value.exportedAt
            : exportedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dbSchemaVersion: null == dbSchemaVersion
            ? _value.dbSchemaVersion
            : dbSchemaVersion // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BackupMetadataImpl implements _BackupMetadata {
  const _$BackupMetadataImpl({
    required this.formatVersion,
    required this.appVersion,
    required this.exportedAt,
    required this.dbSchemaVersion,
  });

  factory _$BackupMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupMetadataImplFromJson(json);

  @override
  final String formatVersion;
  @override
  final String appVersion;
  @override
  final DateTime exportedAt;
  @override
  final int dbSchemaVersion;

  @override
  String toString() {
    return 'BackupMetadata(formatVersion: $formatVersion, appVersion: $appVersion, exportedAt: $exportedAt, dbSchemaVersion: $dbSchemaVersion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupMetadataImpl &&
            (identical(other.formatVersion, formatVersion) ||
                other.formatVersion == formatVersion) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            (identical(other.exportedAt, exportedAt) ||
                other.exportedAt == exportedAt) &&
            (identical(other.dbSchemaVersion, dbSchemaVersion) ||
                other.dbSchemaVersion == dbSchemaVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    formatVersion,
    appVersion,
    exportedAt,
    dbSchemaVersion,
  );

  /// Create a copy of BackupMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupMetadataImplCopyWith<_$BackupMetadataImpl> get copyWith =>
      __$$BackupMetadataImplCopyWithImpl<_$BackupMetadataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupMetadataImplToJson(this);
  }
}

abstract class _BackupMetadata implements BackupMetadata {
  const factory _BackupMetadata({
    required final String formatVersion,
    required final String appVersion,
    required final DateTime exportedAt,
    required final int dbSchemaVersion,
  }) = _$BackupMetadataImpl;

  factory _BackupMetadata.fromJson(Map<String, dynamic> json) =
      _$BackupMetadataImpl.fromJson;

  @override
  String get formatVersion;
  @override
  String get appVersion;
  @override
  DateTime get exportedAt;
  @override
  int get dbSchemaVersion;

  /// Create a copy of BackupMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupMetadataImplCopyWith<_$BackupMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
