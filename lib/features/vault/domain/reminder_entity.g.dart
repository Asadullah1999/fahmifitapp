// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_entity.dart';

class ReminderEntityAdapter extends TypeAdapter<ReminderEntity> {
  @override
  final int typeId = 3;

  @override
  ReminderEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderEntity(
      id: fields[0] as String,
      documentId: fields[1] as String,
      reminderDate: fields[2] as DateTime,
      message: fields[3] as String,
      isActive: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.documentId)
      ..writeByte(2)
      ..write(obj.reminderDate)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
