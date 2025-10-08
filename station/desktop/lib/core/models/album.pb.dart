//
//  Generated code. Do not modify.
//  source: album.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

/// Album model
class Album extends $pb.GeneratedMessage {
  factory Album({
    $core.String? id,
    $core.String? name,
    $core.String? description,
    $core.String? coverPhotoId,
    $core.String? creatorId,
    $core.bool? isPublic,
    $core.int? photoCount,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? updatedAt,
    $fixnum.Int64? deletedAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (coverPhotoId != null) {
      $result.coverPhotoId = coverPhotoId;
    }
    if (creatorId != null) {
      $result.creatorId = creatorId;
    }
    if (isPublic != null) {
      $result.isPublic = isPublic;
    }
    if (photoCount != null) {
      $result.photoCount = photoCount;
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
    return $result;
  }
  Album._() : super();
  factory Album.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Album.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Album', package: const $pb.PackageName(_omitMessageNames ? '' : 'family_photo'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'coverPhotoId')
    ..aOS(5, _omitFieldNames ? '' : 'creatorId')
    ..aOB(6, _omitFieldNames ? '' : 'isPublic')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'photoCount', $pb.PbFieldType.O3)
    ..aInt64(8, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(9, _omitFieldNames ? '' : 'updatedAt')
    ..aInt64(10, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Album clone() => Album()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Album copyWith(void Function(Album) updates) => super.copyWith((message) => updates(message as Album)) as Album;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Album create() => Album._();
  Album createEmptyInstance() => create();
  static $pb.PbList<Album> createRepeated() => $pb.PbList<Album>();
  @$core.pragma('dart2js:noInline')
  static Album getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Album>(create);
  static Album? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get coverPhotoId => $_getSZ(3);
  @$pb.TagNumber(4)
  set coverPhotoId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCoverPhotoId() => $_has(3);
  @$pb.TagNumber(4)
  void clearCoverPhotoId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get creatorId => $_getSZ(4);
  @$pb.TagNumber(5)
  set creatorId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCreatorId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatorId() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isPublic => $_getBF(5);
  @$pb.TagNumber(6)
  set isPublic($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsPublic() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsPublic() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get photoCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set photoCount($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasPhotoCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearPhotoCount() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get createdAt => $_getI64(7);
  @$pb.TagNumber(8)
  set createdAt($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get updatedAt => $_getI64(8);
  @$pb.TagNumber(9)
  set updatedAt($fixnum.Int64 v) { $_setInt64(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasUpdatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearUpdatedAt() => clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get deletedAt => $_getI64(9);
  @$pb.TagNumber(10)
  set deletedAt($fixnum.Int64 v) { $_setInt64(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasDeletedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearDeletedAt() => clearField(10);
}

/// Album list response
class AlbumList extends $pb.GeneratedMessage {
  factory AlbumList({
    $core.Iterable<Album>? albums,
    $core.int? totalCount,
    $core.int? page,
    $core.int? pageSize,
    $core.bool? hasMore,
  }) {
    final $result = create();
    if (albums != null) {
      $result.albums.addAll(albums);
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
  AlbumList._() : super();
  factory AlbumList.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AlbumList.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbumList', package: const $pb.PackageName(_omitMessageNames ? '' : 'family_photo'), createEmptyInstance: create)
    ..pc<Album>(1, _omitFieldNames ? '' : 'albums', $pb.PbFieldType.PM, subBuilder: Album.create)
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
  AlbumList clone() => AlbumList()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AlbumList copyWith(void Function(AlbumList) updates) => super.copyWith((message) => updates(message as AlbumList)) as AlbumList;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbumList create() => AlbumList._();
  AlbumList createEmptyInstance() => create();
  static $pb.PbList<AlbumList> createRepeated() => $pb.PbList<AlbumList>();
  @$core.pragma('dart2js:noInline')
  static AlbumList getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbumList>(create);
  static AlbumList? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Album> get albums => $_getList(0);

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
