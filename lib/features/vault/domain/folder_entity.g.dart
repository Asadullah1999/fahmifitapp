// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_entity.dart';

class FolderEntityAdapter extends TypeAdapter<FolderEntity> {
  @override
  final int typeId = 2;

  @override
  FolderEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FolderEntity(
      id: fields[0] as String,
      name: fields[1] as String,
      iconEmoji: fields[2] as String,
      colorHex: fields[3] as String,
      documentCount: fields[4] as int,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FolderEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconEmoji)
      ..writeByte(3)
      ..write(obj.colorHex)
      ..writeByte(4)
      ..write(obj.documentCount)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
