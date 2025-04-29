// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart'; // <-- BURAYI Aktivite SINIFININ BULUNDUĞU DOSYA ADIYLA DEĞİŞTİRİN!
// Örneğin, sınıfınız 'models/aktivite.dart' içindeyse, 'models/aktivite.dart' yazın.

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AktiviteAdapter extends TypeAdapter<Aktivite> {
  @override
  final int typeId = 1; // @HiveType(typeId: 1) ile eşleşiyor

  @override
  Aktivite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    // Constructor'daki parametre sırasına göre alanları okuyoruz
    return Aktivite(
      // @HiveField(2) - String
      ID: fields[2] as String,
      // @HiveField(0) - String
      title: fields[0] as String,
      // @HiveField(1) - DateTime
      date: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Aktivite obj) {
    writer
      ..writeByte(3) // Toplam alan sayısı: 3
      // Alan 0: title (String)
      ..writeByte(0)
      ..write(obj.title)
      // Alan 1: date (DateTime)
      ..writeByte(1)
      ..write(obj.date)
      // Alan 2: ID (String)
      ..writeByte(2)
      ..write(obj.ID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AktiviteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
