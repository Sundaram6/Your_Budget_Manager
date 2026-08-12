// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BackupMetadata _$BackupMetadataFromJson(Map<String, dynamic> json) =>
    _BackupMetadata(
      formatVersion: json['formatVersion'] as String,
      appVersion: json['appVersion'] as String,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      dbSchemaVersion: (json['dbSchemaVersion'] as num).toInt(),
    );

Map<String, dynamic> _$BackupMetadataToJson(_BackupMetadata instance) =>
    <String, dynamic>{
      'formatVersion': instance.formatVersion,
      'appVersion': instance.appVersion,
      'exportedAt': instance.exportedAt.toIso8601String(),
      'dbSchemaVersion': instance.dbSchemaVersion,
    };
