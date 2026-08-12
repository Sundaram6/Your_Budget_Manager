import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_metadata.freezed.dart';
part 'backup_metadata.g.dart';

@freezed
abstract class BackupMetadata with _$BackupMetadata {
  const factory BackupMetadata({
    required String formatVersion,
    required String appVersion,
    required DateTime exportedAt,
    required int dbSchemaVersion,
  }) = _BackupMetadata;

  factory BackupMetadata.fromJson(Map<String, dynamic> json) =>
      _$BackupMetadataFromJson(json);
}
