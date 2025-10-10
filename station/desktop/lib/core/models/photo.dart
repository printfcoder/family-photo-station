//
//  Generated code. Do not modify.
//  source: photo.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

/// Photo model
class Photo extends $pb.GeneratedMessage {
  factory Photo({
    $core.String? id,
    $core.String? filename,
    $core.String? originalFilename,
    $core.String? mimeType,
    $fixnum.Int64? fileSize,
    $core.String? hash,
    $core.int? width,
    $core.int? height,
    $core.String? thumbnailPath,
    ExifData? exifData,
    LocationData? location,
    $core.String? uploaderId,
    $core.String? deviceId,
    $core.String? albumId,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? updatedAt,
    $fixnum.Int64? deletedAt,
    $core.String? thumbnailUrl,
    $core.String? url,
    $core.String? originalUrl,
    $core.String? mediumUrl,
    $core.Iterable<$core.String>? tags,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (filename != null) {
      $result.filename = filename;
    }
    if (originalFilename != null) {
      $result.originalFilename = originalFilename;
    }
    if (mimeType != null) {
      $result.mimeType = mimeType;
    }
    if (fileSize != null) {
      $result.fileSize = fileSize;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (width != null) {
      $result.width = width;
    }
    if (height != null) {
      $result.height = height;
    }
    if (thumbnailPath != null) {
      $result.thumbnailPath = thumbnailPath;
    }
    if (exifData != null) {
      $result.exifData = exifData;
    }
    if (location != null) {
      $result.location = location;
    }
    if (uploaderId != null) {
      $result.uploaderId = uploaderId;
    }
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    if (albumId != null) {
      $result.albumId = albumId;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    if (deletedAt != null) {
      $result.deletedAt = deletedAt;
    }
    if (thumbnailUrl != null) {
      $result.thumbnailUrl = thumbnailUrl;
    }
    if (url != null) {
      $result.url = url;
    }
    if (originalUrl != null) {
      $result.originalUrl = originalUrl;
    }
    if (mediumUrl != null) {
      $result.mediumUrl = mediumUrl;
    }
    if (tags != null) {
      $result.tags.addAll(tags);
    }
    return $result;
  }
  Photo._() : super();
  factory Photo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Photo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Photo', package: const $pb.PackageName(_omitMessageNames ? '' : 'family_photo'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..aOS(3, _omitFieldNames ? '' : 'originalFilename')
    ..aOS(4, _omitFieldNames ? '' : 'mimeType')
    ..aInt64(5, _omitFieldNames ? '' : 'fileSize')
    ..aOS(6, _omitFieldNames ? '' : 'hash')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'height', $pb.PbFieldType.O3)
    ..aOS(9, _omitFieldNames ? '' : 'thumbnailPath')
    ..aOM<ExifData>(10, _omitFieldNames ? '' : 'exifData', subBuilder: ExifData.create)
    ..aOM<LocationData>(11, _omitFieldNames ? '' : 'location', subBuilder: LocationData.create)
    ..aOS(12, _omitFieldNames ? '' : 'uploaderId')
    ..aOS(13, _omitFieldNames ? '' : 'deviceId')
    ..aOS(14, _omitFieldNames ? '' : 'albumId')
    ..aInt64(15, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(16, _omitFieldNames ? '' : 'updatedAt')
    ..aInt64(17, _omitFieldNames ? '' : 'deletedAt')
    ..aOS(18, _omitFieldNames ? '' : 'thumbnailUrl')
    ..aOS(19, _omitFieldNames ? '' : 'url')
    ..aOS(20, _omitFieldNames ? '' : 'originalUrl')
    ..aOS(21, _omitFieldNames ? '' : 'mediumUrl')
    ..pPS(22, _omitFieldNames ? '' : 'tags')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Photo clone() => Photo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Photo copyWith(void Function(Photo) updates) => super.copyWith((message) => updates(message as Photo)) as Photo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Photo create() => Photo._();
  Photo createEmptyInstance() => create();
  static $pb.PbList<Photo> createRepeated() => $pb.PbList<Photo>();
  @$core.pragma('dart2js:noInline')
  static Photo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Photo>(create);
  static Photo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get filename => $_getSZ(1);
  @$pb.TagNumber(2)
  set filename($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilename() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get originalFilename => $_getSZ(2);
  @$pb.TagNumber(3)
  set originalFilename($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOriginalFilename() => $_has(2);
  @$pb.TagNumber(3)
  void clearOriginalFilename() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get mimeType => $_getSZ(3);
  @$pb.TagNumber(4)
  set mimeType($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMimeType() => $_has(3);
  @$pb.TagNumber(4)
  void clearMimeType() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get fileSize => $_getI64(4);
  @$pb.TagNumber(5)
  set fileSize($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFileSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearFileSize() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get hash => $_getSZ(5);
  @$pb.TagNumber(6)
  set hash($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasHash() => $_has(5);
  @$pb.TagNumber(6)
  void clearHash() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get width => $_getIZ(6);
  @$pb.TagNumber(7)
  set width($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasWidth() => $_has(6);
  @$pb.TagNumber(7)
  void clearWidth() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get height => $_getIZ(7);
  @$pb.TagNumber(8)
  set height($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasHeight() => $_has(7);
  @$pb.TagNumber(8)
  void clearHeight() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get thumbnailPath => $_getSZ(8);
  @$pb.TagNumber(9)
  set thumbnailPath($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasThumbnailPath() => $_has(8);
  @$pb.TagNumber(9)
  void clearThumbnailPath() => clearField(9);

  @$pb.TagNumber(10)
  ExifData get exifData => $_getN(9);
  @$pb.TagNumber(10)
  set exifData(ExifData v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasExifData() => $_has(9);
  @$pb.TagNumber(10)
  void clearExifData() => clearField(10);
  @$pb.TagNumber(10)
  ExifData ensureExifData() => $_ensure(9);

  @$pb.TagNumber(11)
  LocationData get location => $_getN(10);
  @$pb.TagNumber(11)
  set location(LocationData v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasLocation() => $_has(10);
  @$pb.TagNumber(11)
  void clearLocation() => clearField(11);
  @$pb.TagNumber(11)
  LocationData ensureLocation() => $_ensure(10);

  @$pb.TagNumber(12)
  $core.String get uploaderId => $_getSZ(11);
  @$pb.TagNumber(12)
  set uploaderId($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasUploaderId() => $_has(11);
  @$pb.TagNumber(12)
  void clearUploaderId() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get deviceId => $_getSZ(12);
  @$pb.TagNumber(13)
  set deviceId($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasDeviceId() => $_has(12);
  @$pb.TagNumber(13)
  void clearDeviceId() => clearField(13);

  @$pb.TagNumber(14)
  $core.String get albumId => $_getSZ(13);
  @$pb.TagNumber(14)
  set albumId($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasAlbumId() => $_has(13);
  @$pb.TagNumber(14)
  void clearAlbumId() => clearField(14);

  @$pb.TagNumber(15)
  $fixnum.Int64 get createdAt => $_getI64(14);
  @$pb.TagNumber(15)
  set createdAt($fixnum.Int64 v) { $_setInt64(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearCreatedAt() => clearField(15);

  @$pb.TagNumber(16)
  $fixnum.Int64 get updatedAt => $_getI64(15);
  @$pb.TagNumber(16)
  set updatedAt($fixnum.Int64 v) { $_setInt64(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasUpdatedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearUpdatedAt() => clearField(16);

  @$pb.TagNumber(17)
  $fixnum.Int64 get deletedAt => $_getI64(16);
  @$pb.TagNumber(17)
  set deletedAt($fixnum.Int64 v) { $_setInt64(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasDeletedAt() => $_has(16);
  @$pb.TagNumber(17)
  void clearDeletedAt() => clearField(17);

  @$pb.TagNumber(18)
  $core.String get thumbnailUrl => $_getSZ(17);
  @$pb.TagNumber(18)
  set thumbnailUrl($core.String v) { $_setString(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasThumbnailUrl() => $_has(17);
  @$pb.TagNumber(18)
  void clearThumbnailUrl() => clearField(18);

  @$pb.TagNumber(19)
  $core.String get url => $_getSZ(18);
  @$pb.TagNumber(19)
  set url($core.String v) { $_setString(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasUrl() => $_has(18);
  @$pb.TagNumber(19)
  void clearUrl() => clearField(19);

  @$pb.TagNumber(20)
  $core.String get originalUrl => $_getSZ(19);
  @$pb.TagNumber(20)
  set originalUrl($core.String v) { $_setString(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasOriginalUrl() => $_has(19);
  @$pb.TagNumber(20)
  void clearOriginalUrl() => clearField(20);

  @$pb.TagNumber(21)
  $core.String get mediumUrl => $_getSZ(20);
  @$pb.TagNumber(21)
  set mediumUrl($core.String v) { $_setString(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasMediumUrl() => $_has(20);
  @$pb.TagNumber(21)
  void clearMediumUrl() => clearField(21);

  @$pb.TagNumber(22)
  $core.List<$core.String> get tags => $_getList(21);
}

/// EXIF data
class ExifData extends $pb.GeneratedMessage {
  factory ExifData({
    $core.String? cameraMake,
    $core.String? cameraModel,
    $core.String? lensModel,
    $core.double? focalLength,
    $core.double? aperture,
    $core.double? shutterSpeed,
    $core.int? iso,
    $fixnum.Int64? takenAt,
  }) {
    final $result = create();
    if (cameraMake != null) {
      $result.cameraMake = cameraMake;
    }
    if (cameraModel != null) {
      $result.cameraModel = cameraModel;
    }
    if (lensModel != null) {
      $result.lensModel = lensModel;
    }
    if (focalLength != null) {
      $result.focalLength = focalLength;
    }
    if (aperture != null) {
      $result.aperture = aperture;
    }
    if (shutterSpeed != null) {
      $result.shutterSpeed = shutterSpeed;
    }
    if (iso != null) {
      $result.iso = iso;
    }
    if (takenAt != null) {
      $result.takenAt = takenAt;
    }
    return $result;
  }
  ExifData._() : super();
  factory ExifData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExifData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExifData', package: const $pb.PackageName(_omitMessageNames ? '' : 'family_photo'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cameraMake')
    ..aOS(2, _omitFieldNames ? '' : 'cameraModel')
    ..aOS(3, _omitFieldNames ? '' : 'lensModel')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'focalLength', $pb.PbFieldType.OD)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'aperture', $pb.PbFieldType.OD)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'shutterSpeed', $pb.PbFieldType.OD)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'iso', $pb.PbFieldType.O3)
    ..aInt64(8, _omitFieldNames ? '' : 'takenAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExifData clone() => ExifData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExifData copyWith(void Function(ExifData) updates) => super.copyWith((message) => updates(message as ExifData)) as ExifData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExifData create() => ExifData._();
  ExifData createEmptyInstance() => create();
  static $pb.PbList<ExifData> createRepeated() => $pb.PbList<ExifData>();
  @$core.pragma('dart2js:noInline')
  static ExifData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExifData>(create);
  static ExifData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cameraMake => $_getSZ(0);
  @$pb.TagNumber(1)
  set cameraMake($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCameraMake() => $_has(0);
  @$pb.TagNumber(1)
  void clearCameraMake() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get cameraModel => $_getSZ(1);
  @$pb.TagNumber(2)
  set cameraModel($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCameraModel() => $_has(1);
  @$pb.TagNumber(2)
  void clearCameraModel() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get lensModel => $_getSZ(2);
  @$pb.TagNumber(3)
  set lensModel($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLensModel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLensModel() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get focalLength => $_getN(3);
  @$pb.TagNumber(4)
  set focalLength($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFocalLength() => $_has(3);
  @$pb.TagNumber(4)
  void clearFocalLength() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get aperture => $_getN(4);
  @$pb.TagNumber(5)
  set aperture($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAperture() => $_has(4);
  @$pb.TagNumber(5)
  void clearAperture() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get shutterSpeed => $_getN(5);
  @$pb.TagNumber(6)
  set shutterSpeed($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasShutterSpeed() => $_has(5);
  @$pb.TagNumber(6)
  void clearShutterSpeed() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get iso => $_getIZ(6);
  @$pb.TagNumber(7)
  set iso($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasIso() => $_has(6);
  @$pb.TagNumber(7)
  void clearIso() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get takenAt => $_getI64(7);
  @$pb.TagNumber(8)
  set takenAt($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTakenAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearTakenAt() => clearField(8);
}

/// Location data
class LocationData extends $pb.GeneratedMessage {
  factory LocationData({
    $core.double? latitude,
    $core.double? longitude,
    $core.double? altitude,
    $core.String? placeName,
    $core.String? country,
    $core.String? province,
    $core.String? city,
    $core.String? district,
  }) {
    final $result = create();
    if (latitude != null) {
      $result.latitude = latitude;
    }
    if (longitude != null) {
      $result.longitude = longitude;
    }
    if (altitude != null) {
      $result.altitude = altitude;
    }
    if (placeName != null) {
      $result.placeName = placeName;
    }
    if (country != null) {
      $result.country = country;
    }
    if (province != null) {
      $result.province = province;
    }
    if (city != null) {
      $result.city = city;
    }
    if (district != null) {
      $result.district = district;
    }
    return $result;
  }
  LocationData._() : super();
  factory LocationData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LocationData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LocationData', package: const $pb.PackageName(_omitMessageNames ? '' : 'family_photo'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'latitude', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'longitude', $pb.PbFieldType.OD)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'altitude', $pb.PbFieldType.OD)
    ..aOS(4, _omitFieldNames ? '' : 'placeName')
    ..aOS(5, _omitFieldNames ? '' : 'country')
    ..aOS(6, _omitFieldNames ? '' : 'province')
    ..aOS(7, _omitFieldNames ? '' : 'city')
    ..aOS(8, _omitFieldNames ? '' : 'district')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LocationData clone() => LocationData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LocationData copyWith(void Function(LocationData) updates) => super.copyWith((message) => updates(message as LocationData)) as LocationData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LocationData create() => LocationData._();
  LocationData createEmptyInstance() => create();
  static $pb.PbList<LocationData> createRepeated() => $pb.PbList<LocationData>();
  @$core.pragma('dart2js:noInline')
  static LocationData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LocationData>(create);
  static LocationData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get latitude => $_getN(0);
  @$pb.TagNumber(1)
  set latitude($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLatitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitude() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get longitude => $_getN(1);
  @$pb.TagNumber(2)
  set longitude($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLongitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitude() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get altitude => $_getN(2);
  @$pb.TagNumber(3)
  set altitude($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAltitude() => $_has(2);
  @$pb.TagNumber(3)
  void clearAltitude() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get placeName => $_getSZ(3);
  @$pb.TagNumber(4)
  set placeName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPlaceName() => $_has(3);
  @$pb.TagNumber(4)
  void clearPlaceName() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get country => $_getSZ(4);
  @$pb.TagNumber(5)
  set country($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCountry() => $_has(4);
  @$pb.TagNumber(5)
  void clearCountry() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get province => $_getSZ(5);
  @$pb.TagNumber(6)
  set province($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasProvince() => $_has(5);
  @$pb.TagNumber(6)
  void clearProvince() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get city => $_getSZ(6);
  @$pb.TagNumber(7)
  set city($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCity() => $_has(6);
  @$pb.TagNumber(7)
  void clearCity() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get district => $_getSZ(7);
  @$pb.TagNumber(8)
  set district($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasDistrict() => $_has(7);
  @$pb.TagNumber(8)
  void clearDistrict() => clearField(8);
}

/// Photo list response
class PhotoList extends $pb.GeneratedMessage {
  factory PhotoList({
    $core.Iterable<Photo>? photos,
    $core.int? totalCount,
    $core.int? page,
    $core.int? pageSize,
    $core.bool? hasMore,
  }) {
    final $result = create();
    if (photos != null) {
      $result.photos.addAll(photos);
    }
    if (totalCount != null) {
      $result.totalCount = totalCount;
    }
    if (page != null) {
      $result.page = page;
    }
    if (pageSize != null) {
      $result.pageSize = pageSize;
    }
    if (hasMore != null) {
      $result.hasMore = hasMore;
    }
    return $result;
  }
  PhotoList._() : super();
  factory PhotoList.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PhotoList.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PhotoList', package: const $pb.PackageName(_omitMessageNames ? '' : 'family_photo'), createEmptyInstance: create)
    ..pc<Photo>(1, _omitFieldNames ? '' : 'photos', $pb.PbFieldType.PM, subBuilder: Photo.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'totalCount', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'page', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'pageSize', $pb.PbFieldType.O3)
    ..aOB(5, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PhotoList clone() => PhotoList()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PhotoList copyWith(void Function(PhotoList) updates) => super.copyWith((message) => updates(message as PhotoList)) as PhotoList;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PhotoList create() => PhotoList._();
  PhotoList createEmptyInstance() => create();
  static $pb.PbList<PhotoList> createRepeated() => $pb.PbList<PhotoList>();
  @$core.pragma('dart2js:noInline')
  static PhotoList getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PhotoList>(create);
  static PhotoList? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Photo> get photos => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get page => $_getIZ(2);
  @$pb.TagNumber(3)
  set page($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPage() => $_has(2);
  @$pb.TagNumber(3)
  void clearPage() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get pageSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageSize($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPageSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageSize() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get hasMore => $_getBF(4);
  @$pb.TagNumber(5)
  set hasMore($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHasMore() => $_has(4);
  @$pb.TagNumber(5)
  void clearHasMore() => clearField(5);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
