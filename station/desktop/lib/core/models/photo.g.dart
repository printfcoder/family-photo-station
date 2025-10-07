// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhotoAdapter extends TypeAdapter<Photo> {
  @override
  final int typeId = 4;

  @override
  Photo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Photo(
      id: fields[0] as String,
      filename: fields[1] as String,
      originalFilename: fields[2] as String,
      mimeType: fields[3] as String,
      fileSize: fields[4] as int,
      hash: fields[5] as String,
      width: fields[6] as int,
      height: fields[7] as int,
      thumbnailPath: fields[8] as String?,
      thumbnailUrl: fields[19] as String?,
      url: fields[20] as String?,
      originalUrl: fields[21] as String?,
      mediumUrl: fields[22] as String?,
      exifData: fields[9] as ExifData?,
      location: fields[10] as LocationData?,
      uploaderId: fields[11] as String,
      deviceId: fields[12] as String?,
      isProcessed: fields[13] as bool,
      tags: (fields[14] as List).cast<String>(),
      qualityScore: fields[15] as double?,
      createdAt: fields[16] as DateTime,
      updatedAt: fields[17] as DateTime,
      deletedAt: fields[18] as DateTime?,
      takenAt: fields[23] as DateTime?,
      albumIds: (fields[24] as List).cast<String>(),
      metadata: (fields[25] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Photo obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.filename)
      ..writeByte(2)
      ..write(obj.originalFilename)
      ..writeByte(3)
      ..write(obj.mimeType)
      ..writeByte(4)
      ..write(obj.fileSize)
      ..writeByte(5)
      ..write(obj.hash)
      ..writeByte(6)
      ..write(obj.width)
      ..writeByte(7)
      ..write(obj.height)
      ..writeByte(8)
      ..write(obj.thumbnailPath)
      ..writeByte(19)
      ..write(obj.thumbnailUrl)
      ..writeByte(20)
      ..write(obj.url)
      ..writeByte(21)
      ..write(obj.originalUrl)
      ..writeByte(22)
      ..write(obj.mediumUrl)
      ..writeByte(9)
      ..write(obj.exifData)
      ..writeByte(10)
      ..write(obj.location)
      ..writeByte(11)
      ..write(obj.uploaderId)
      ..writeByte(12)
      ..write(obj.deviceId)
      ..writeByte(13)
      ..write(obj.isProcessed)
      ..writeByte(14)
      ..write(obj.tags)
      ..writeByte(15)
      ..write(obj.qualityScore)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt)
      ..writeByte(18)
      ..write(obj.deletedAt)
      ..writeByte(23)
      ..write(obj.takenAt)
      ..writeByte(24)
      ..write(obj.albumIds)
      ..writeByte(25)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExifDataAdapter extends TypeAdapter<ExifData> {
  @override
  final int typeId = 5;

  @override
  ExifData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExifData(
      takenAt: fields[0] as DateTime?,
      camera: fields[1] as String?,
      lens: fields[2] as String?,
      iso: fields[3] as int?,
      aperture: fields[4] as double?,
      shutterSpeed: fields[5] as String?,
      focalLength: fields[6] as double?,
      orientation: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExifData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.takenAt)
      ..writeByte(1)
      ..write(obj.camera)
      ..writeByte(2)
      ..write(obj.lens)
      ..writeByte(3)
      ..write(obj.iso)
      ..writeByte(4)
      ..write(obj.aperture)
      ..writeByte(5)
      ..write(obj.shutterSpeed)
      ..writeByte(6)
      ..write(obj.focalLength)
      ..writeByte(7)
      ..write(obj.orientation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExifDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationDataAdapter extends TypeAdapter<LocationData> {
  @override
  final int typeId = 6;

  @override
  LocationData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationData(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      address: fields[2] as String?,
      city: fields[3] as String?,
      country: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.country);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlbumAdapter extends TypeAdapter<Album> {
  @override
  final int typeId = 7;

  @override
  Album read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Album(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      coverPhotoId: fields[3] as String?,
      creatorId: fields[4] as String,
      isPublic: fields[5] as bool,
      photoCount: fields[6] as int,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Album obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.coverPhotoId)
      ..writeByte(4)
      ..write(obj.creatorId)
      ..writeByte(5)
      ..write(obj.isPublic)
      ..writeByte(6)
      ..write(obj.photoCount)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
      id: json['id'] as String,
      filename: json['filename'] as String,
      originalFilename: json['originalFilename'] as String,
      mimeType: json['mimeType'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      hash: json['hash'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      thumbnailPath: json['thumbnailPath'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      url: json['url'] as String?,
      originalUrl: json['originalUrl'] as String?,
      mediumUrl: json['mediumUrl'] as String?,
      exifData: json['exifData'] == null
          ? null
          : ExifData.fromJson(json['exifData'] as Map<String, dynamic>),
      location: json['location'] == null
          ? null
          : LocationData.fromJson(json['location'] as Map<String, dynamic>),
      uploaderId: json['uploaderId'] as String,
      deviceId: json['deviceId'] as String?,
      isProcessed: json['isProcessed'] as bool,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      qualityScore: (json['qualityScore'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      takenAt: json['takenAt'] == null
          ? null
          : DateTime.parse(json['takenAt'] as String),
      albumIds: (json['albumIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
      'id': instance.id,
      'filename': instance.filename,
      'originalFilename': instance.originalFilename,
      'mimeType': instance.mimeType,
      'fileSize': instance.fileSize,
      'hash': instance.hash,
      'width': instance.width,
      'height': instance.height,
      'thumbnailPath': instance.thumbnailPath,
      'thumbnailUrl': instance.thumbnailUrl,
      'url': instance.url,
      'originalUrl': instance.originalUrl,
      'mediumUrl': instance.mediumUrl,
      'exifData': instance.exifData,
      'location': instance.location,
      'uploaderId': instance.uploaderId,
      'deviceId': instance.deviceId,
      'isProcessed': instance.isProcessed,
      'tags': instance.tags,
      'qualityScore': instance.qualityScore,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'takenAt': instance.takenAt?.toIso8601String(),
      'albumIds': instance.albumIds,
      'metadata': instance.metadata,
    };

ExifData _$ExifDataFromJson(Map<String, dynamic> json) => ExifData(
      takenAt: json['takenAt'] == null
          ? null
          : DateTime.parse(json['takenAt'] as String),
      camera: json['camera'] as String?,
      lens: json['lens'] as String?,
      iso: (json['iso'] as num?)?.toInt(),
      aperture: (json['aperture'] as num?)?.toDouble(),
      shutterSpeed: json['shutterSpeed'] as String?,
      focalLength: (json['focalLength'] as num?)?.toDouble(),
      orientation: json['orientation'] as String?,
    );

Map<String, dynamic> _$ExifDataToJson(ExifData instance) => <String, dynamic>{
      'takenAt': instance.takenAt?.toIso8601String(),
      'camera': instance.camera,
      'lens': instance.lens,
      'iso': instance.iso,
      'aperture': instance.aperture,
      'shutterSpeed': instance.shutterSpeed,
      'focalLength': instance.focalLength,
      'orientation': instance.orientation,
    };

LocationData _$LocationDataFromJson(Map<String, dynamic> json) => LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
    );

Map<String, dynamic> _$LocationDataToJson(LocationData instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
    };

Album _$AlbumFromJson(Map<String, dynamic> json) => Album(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      coverPhotoId: json['coverPhotoId'] as String?,
      creatorId: json['creatorId'] as String,
      isPublic: json['isPublic'] as bool,
      photoCount: (json['photoCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'coverPhotoId': instance.coverPhotoId,
      'creatorId': instance.creatorId,
      'isPublic': instance.isPublic,
      'photoCount': instance.photoCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
