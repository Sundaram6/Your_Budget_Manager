// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BackupMetadataImpl _$$BackupMetadataImplFromJson(Map<String, dynamic> json) =>
    _$BackupMetadataImpl(
      formatVersion: json['formatVersion'] as String,
      appVersion: json['appVersion'] as String,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      dbSchemaVersion: (json['dbSchemaVersion'] as num).toInt(),
    );

Map<String, dynamic> _$$BackupMetadataImplToJson(
  _$BackupMetadataImpl instance,
) => <String, dynamic>{
  'formatVersion': instance.formatVersion,
  'appVersion': instance.appVersion,
  'exportedAt': instance.exportedAt.toIso8601String(),
  'dbSchemaVersion': instance.dbSchemaVersion,
};
