// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 3;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      hour: fields[2] as int,
      minute: fields[3] as int,
      iconPath: fields[4] as String,
      daysOfWeek: (fields[5] as List).cast<int>(),
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.hour)
      ..writeByte(3)
      ..write(obj.minute)
      ..writeByte(4)
      ..write(obj.iconPath)
      ..writeByte(5)
      ..write(obj.daysOfWeek)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitLogAdapter extends TypeAdapter<HabitLog> {
  @override
  final int typeId = 4;

  @override
  HabitLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitLog(
      id: fields[0] as String,
      habitId: fields[1] as String,
      date: fields[2] as DateTime,
      status: fields[3] as HabitStatus,
      loggedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HabitLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.loggedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitStatusAdapter extends TypeAdapter<HabitStatus> {
  @override
  final int typeId = 2;

  @override
  HabitStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitStatus.pending;
      case 1:
        return HabitStatus.completed;
      case 2:
        return HabitStatus.skipped;
      default:
        return HabitStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, HabitStatus obj) {
    switch (obj) {
      case HabitStatus.pending:
        writer.writeByte(0);
        break;
      case HabitStatus.completed:
        writer.writeByte(1);
        break;
      case HabitStatus.skipped:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
