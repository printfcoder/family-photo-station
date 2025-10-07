import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'photo.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class Photo extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String filename;
  
  @HiveField(2)
  final String originalFilename;
  
  @HiveField(3)
  final String mimeType;
  
  @HiveField(4)
  final int fileSize;
  
  @HiveField(5)
  final String hash;
  
  @HiveField(6)
  final int width;
  
  @HiveField(7)
  final int height;
  
  @HiveField(8)
  final String? thumbnailPath;
  
  @HiveField(19)
  final String? thumbnailUrl;
  
  @HiveField(20)
  final String? url;
  
  @HiveField(21)
  final String? originalUrl;
  
  @HiveField(22)
  final String? mediumUrl;
  
  @HiveField(9)
  final ExifData? exifData;
  
  @HiveField(10)
  final LocationData? location;
  
  @HiveField(11)
  final String uploaderId;
  
  @HiveField(12)
  final String? deviceId;
  
  @HiveField(13)
  final bool isProcessed;
  
  @HiveField(14)
  final List<String> tags;
  
  @HiveField(15)
  final double? qualityScore;
  
  @HiveField(16)
  final DateTime createdAt;
  
  @HiveField(17)
  final DateTime updatedAt;
  
  @HiveField(18)
  final DateTime? deletedAt;

  @HiveField(23)
  final DateTime? takenAt;

  @HiveField(24)
  final List<String> albumIds;

  @HiveField(25)
  final Map<String, dynamic>? metadata;

  Photo({
    required this.id,
    required this.filename,
    required this.originalFilename,
    required this.mimeType,
    required this.fileSize,
    required this.hash,
    required this.width,
    required this.height,
    this.thumbnailPath,
    this.thumbnailUrl,
    this.url,
    this.originalUrl,
    this.mediumUrl,
    this.exifData,
    this.location,
    required this.uploaderId,
    this.deviceId,
    required this.isProcessed,
    required this.tags,
    this.qualityScore,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.takenAt,
    this.albumIds = const [],
    this.metadata,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
  Map<String, dynamic> toJson() => _$PhotoToJson(this);

  Photo copyWith({
    String? id,
    String? filename,
    String? originalFilename,
    String? mimeType,
    int? fileSize,
    String? hash,
    int? width,
    int? height,
    String? thumbnailPath,
    String? thumbnailUrl,
    String? url,
    String? originalUrl,
    String? mediumUrl,
    ExifData? exifData,
    LocationData? location,
    String? uploaderId,
    String? deviceId,
    bool? isProcessed,
    List<String>? tags,
    double? qualityScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? takenAt,
    List<String>? albumIds,
    Map<String, dynamic>? metadata,
  }) {
    return Photo(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      originalFilename: originalFilename ?? this.originalFilename,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      hash: hash ?? this.hash,
      width: width ?? this.width,
      height: height ?? this.height,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      url: url ?? this.url,
      originalUrl: originalUrl ?? this.originalUrl,
      mediumUrl: mediumUrl ?? this.mediumUrl,
      exifData: exifData ?? this.exifData,
      location: location ?? this.location,
      uploaderId: uploaderId ?? this.uploaderId,
      deviceId: deviceId ?? this.deviceId,
      isProcessed: isProcessed ?? this.isProcessed,
      tags: tags ?? this.tags,
      qualityScore: qualityScore ?? this.qualityScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      takenAt: takenAt ?? this.takenAt,
      albumIds: albumIds ?? this.albumIds,
      metadata: metadata ?? this.metadata,
    );
  }

  String get aspectRatio {
    if (height == 0) return '1:1';
    final ratio = width / height;
    if (ratio > 1.7) return '16:9';
    if (ratio > 1.4) return '3:2';
    if (ratio > 1.2) return '4:3';
    if (ratio > 0.9) return '1:1';
    if (ratio > 0.7) return '3:4';
    if (ratio > 0.5) return '2:3';
    return '9:16';
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

@JsonSerializable()
@HiveType(typeId: 5)
class ExifData extends HiveObject {
  @HiveField(0)
  final DateTime? takenAt;
  
  @HiveField(1)
  final String? camera;
  
  @HiveField(2)
  final String? lens;
  
  @HiveField(3)
  final int? iso;
  
  @HiveField(4)
  final double? aperture;
  
  @HiveField(5)
  final String? shutterSpeed;
  
  @HiveField(6)
  final double? focalLength;
  
  @HiveField(7)
  final String? orientation;

  ExifData({
    this.takenAt,
    this.camera,
    this.lens,
    this.iso,
    this.aperture,
    this.shutterSpeed,
    this.focalLength,
    this.orientation,
  });

  factory ExifData.fromJson(Map<String, dynamic> json) => _$ExifDataFromJson(json);
  Map<String, dynamic> toJson() => _$ExifDataToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 6)
class LocationData extends HiveObject {
  @HiveField(0)
  final double latitude;
  
  @HiveField(1)
  final double longitude;
  
  @HiveField(2)
  final String? address;
  
  @HiveField(3)
  final String? city;
  
  @HiveField(4)
  final String? country;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) => _$LocationDataFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDataToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 7)
class Album extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final String? coverPhotoId;
  
  @HiveField(4)
  final String creatorId;
  
  @HiveField(5)
  final bool isPublic;
  
  @HiveField(6)
  final int photoCount;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime updatedAt;
  
  @HiveField(9)
  final DateTime? deletedAt;

  Album({
    required this.id,
    required this.name,
    this.description,
    this.coverPhotoId,
    required this.creatorId,
    required this.isPublic,
    required this.photoCount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Album copyWith({
    String? id,
    String? name,
    String? description,
    String? coverPhotoId,
    String? creatorId,
    bool? isPublic,
    int? photoCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverPhotoId: coverPhotoId ?? this.coverPhotoId,
      creatorId: creatorId ?? this.creatorId,
      isPublic: isPublic ?? this.isPublic,
      photoCount: photoCount ?? this.photoCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
  Map<String, dynamic> toJson() => _$AlbumToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 8)
class Tag extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final String? color;
  
  @HiveField(4)
  final bool isSystem;
  
  @HiveField(5)
  final int photoCount;
  
  @HiveField(6)
  final DateTime createdAt;

  Tag({
    required this.id,
    required this.name,
    this.description,
    this.color,
    required this.isSystem,
    required this.photoCount,
    required this.createdAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 9)
class Person extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? avatar;
  
  @HiveField(3)
  final String? description;
  
  @HiveField(4)
  final bool isConfirmed;
  
  @HiveField(5)
  final int photoCount;
  
  @HiveField(6)
  final DateTime createdAt;

  Person({
    required this.id,
    required this.name,
    this.avatar,
    this.description,
    required this.isConfirmed,
    required this.photoCount,
    required this.createdAt,
  });

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}

@JsonSerializable()
class PhotosResponse {
  final List<Photo> photos;
  final PageInfo pageInfo;

  PhotosResponse({
    required this.photos,
    required this.pageInfo,
  });

  factory PhotosResponse.fromJson(Map<String, dynamic> json) => _$PhotosResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PhotosResponseToJson(this);
}

@JsonSerializable()
class PageInfo {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PageInfo({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) => _$PageInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PageInfoToJson(this);
}

@JsonSerializable()
class UploadPhotoRequest {
  final String filename;
  final String mimeType;
  final int fileSize;
  final String? albumId;
  final List<String>? tags;

  UploadPhotoRequest({
    required this.filename,
    required this.mimeType,
    required this.fileSize,
    this.albumId,
    this.tags,
  });

  factory UploadPhotoRequest.fromJson(Map<String, dynamic> json) => _$UploadPhotoRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UploadPhotoRequestToJson(this);
}

@JsonSerializable()
class CreateAlbumRequest {
  final String name;
  final String? description;
  final bool isPublic;

  CreateAlbumRequest({
    required this.name,
    this.description,
    required this.isPublic,
  });

  factory CreateAlbumRequest.fromJson(Map<String, dynamic> json) => _$CreateAlbumRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateAlbumRequestToJson(this);
}