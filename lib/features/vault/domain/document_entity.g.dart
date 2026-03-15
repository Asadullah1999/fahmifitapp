// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'document_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentEntityAdapter extends TypeAdapter<DocumentEntity> {
  @override
  final int typeId = 1;

  @override
  DocumentEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentEntity(
      id: fields[0] as String,
      folderId: fields[1] as String,
      title: fields[2] as String,
      type: fields[3] as DocumentType,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      expiryDate: fields[6] as DateTime?,
      encryptedFilePath: fields[7] as String,
      thumbnailPath: fields[8] as String?,
      tags: (fields[9] as List).cast<String>(),
      ocrText: fields[10] as String?,
      extractedFields: (fields[11] as Map).cast<String, String>(),
      hasReminder: fields[12] as bool,
      pageCount: fields[13] as int,
      fileSizeBytes: fields[14] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentEntity obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.folderId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.expiryDate)
      ..writeByte(7)
      ..write(obj.encryptedFilePath)
      ..writeByte(8)
      ..write(obj.thumbnailPath)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.ocrText)
      ..writeByte(11)
      ..write(obj.extractedFields)
      ..writeByte(12)
      ..write(obj.hasReminder)
      ..writeByte(13)
      ..write(obj.pageCount)
      ..writeByte(14)
      ..write(obj.fileSizeBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentTypeAdapter extends TypeAdapter<DocumentType> {
  @override
  final int typeId = 0;

  @override
  DocumentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DocumentType.passport;
      case 1:
        return DocumentType.license;
      case 2:
        return DocumentType.insurance;
      case 3:
        return DocumentType.tax;
      case 4:
        return DocumentType.contract;
      case 5:
        return DocumentType.receipt;
      case 6:
        return DocumentType.medical;
      case 7:
        return DocumentType.certificate;
      case 8:
        return DocumentType.other;
      default:
        return DocumentType.other;
    }
  }

  @override
  void write(BinaryWriter writer, DocumentType obj) {
    switch (obj) {
      case DocumentType.passport:
        writer.writeByte(0);
        break;
      case DocumentType.license:
        writer.writeByte(1);
        break;
      case DocumentType.insurance:
        writer.writeByte(2);
        break;
      case DocumentType.tax:
        writer.writeByte(3);
        break;
      case DocumentType.contract:
        writer.writeByte(4);
        break;
      case DocumentType.receipt:
        writer.writeByte(5);
        break;
      case DocumentType.medical:
        writer.writeByte(6);
        break;
      case DocumentType.certificate:
        writer.writeByte(7);
        break;
      case DocumentType.other:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
