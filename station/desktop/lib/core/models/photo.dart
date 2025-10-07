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

  // 获取文件大小的可读格式
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  // 获取图片尺寸比例
  double get aspectRatio {
    if (height == 0) return 1.0;
    return width / height;
  }

  // 是否为横向图片
  bool get isLandscape => width > height;

  // 是否为竖向图片
  bool get isPortrait => height > width;

  // 是否为正方形图片
  bool get isSquare => width == height;

  // 获取显示用的URL（优先级：mediumUrl > url > originalUrl）
  String? get displayUrl => mediumUrl ?? url ?? originalUrl;

  // 获取缩略图URL
  String? get thumbUrl => thumbnailUrl;

  // 是否有位置信息
  bool get hasLocation => location != null;

  // 是否有EXIF信息
  bool get hasExifData => exifData != null;

  // 获取拍摄时间（优先使用EXIF中的时间）
  DateTime get capturedAt => takenAt ?? exifData?.takenAt ?? createdAt;

  // 获取相机信息
  String? get cameraInfo {
    if (exifData?.camera != null) {
      return exifData!.camera;
    }
    return null;
  }

  // 获取拍摄参数摘要
  String? get shootingParams {
    if (exifData == null) return null;
    
    final params = <String>[];
    if (exifData!.iso != null) params.add('ISO${exifData!.iso}');
    if (exifData!.aperture != null) params.add('f/${exifData!.aperture}');
    if (exifData!.shutterSpeed != null) params.add(exifData!.shutterSpeed!);
    if (exifData!.focalLength != null) params.add('${exifData!.focalLength}mm');
    
    return params.isEmpty ? null : params.join(' ');
  }

  @override
  String toString() {
    return 'Photo(id: $id, filename: $filename, size: $fileSizeFormatted, dimensions: ${width}x$height)';
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

  ExifData copyWith({
    DateTime? takenAt,
    String? camera,
    String? lens,
    int? iso,
    double? aperture,
    String? shutterSpeed,
    double? focalLength,
    String? orientation,
  }) {
    return ExifData(
      takenAt: takenAt ?? this.takenAt,
      camera: camera ?? this.camera,
      lens: lens ?? this.lens,
      iso: iso ?? this.iso,
      aperture: aperture ?? this.aperture,
      shutterSpeed: shutterSpeed ?? this.shutterSpeed,
      focalLength: focalLength ?? this.focalLength,
      orientation: orientation ?? this.orientation,
    );
  }

  @override
  String toString() {
    return 'ExifData(camera: $camera, iso: $iso, aperture: $aperture, shutterSpeed: $shutterSpeed)';
  }
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

  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? country,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }

  // 获取位置摘要
  String get summary {
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    if (city != null && city!.isNotEmpty) {
      return city!;
    }
    if (country != null && country!.isNotEmpty) {
      return country!;
    }
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, address: $address)';
  }
}

@JsonSerializable()
@HiveType(typeId: 7)
class Album extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
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

  Album({
    required this.id,
    required this.name,
    required this.description,
    this.coverPhotoId,
    required this.creatorId,
    required this.isPublic,
    required this.photoCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
  Map<String, dynamic> toJson() => _$AlbumToJson(this);

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
    );
  }

  // 是否为空相册
  bool get isEmpty => photoCount == 0;

  // 是否有封面
  bool get hasCover => coverPhotoId != null;

  @override
  String toString() {
    return 'Album(id: $id, name: $name, photoCount: $photoCount, isPublic: $isPublic)';
  }
}