//
//  Generated code. Do not modify.
//  source: album.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use albumDescriptor instead')
const Album$json = {
  '1': 'Album',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'description', '17': true},
    {'1': 'cover_photo_id', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'coverPhotoId', '17': true},
    {'1': 'creator_id', '3': 5, '4': 1, '5': 9, '10': 'creatorId'},
    {'1': 'is_public', '3': 6, '4': 1, '5': 8, '10': 'isPublic'},
    {'1': 'photo_count', '3': 7, '4': 1, '5': 5, '10': 'photoCount'},
    {'1': 'created_at', '3': 8, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'updated_at', '3': 9, '4': 1, '5': 3, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 10, '4': 1, '5': 3, '9': 2, '10': 'deletedAt', '17': true},
  ],
  '8': [
    {'1': '_description'},
    {'1': '_cover_photo_id'},
    {'1': '_deleted_at'},
  ],
};

/// Descriptor for `Album`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albumDescriptor = $convert.base64Decode(
    'CgVBbGJ1bRIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIlCgtkZXNjcmlwdG'
    'lvbhgDIAEoCUgAUgtkZXNjcmlwdGlvbogBARIpCg5jb3Zlcl9waG90b19pZBgEIAEoCUgBUgxj'
    'b3ZlclBob3RvSWSIAQESHQoKY3JlYXRvcl9pZBgFIAEoCVIJY3JlYXRvcklkEhsKCWlzX3B1Ym'
    'xpYxgGIAEoCFIIaXNQdWJsaWMSHwoLcGhvdG9fY291bnQYByABKAVSCnBob3RvQ291bnQSHQoK'
    'Y3JlYXRlZF9hdBgIIAEoA1IJY3JlYXRlZEF0Eh0KCnVwZGF0ZWRfYXQYCSABKANSCXVwZGF0ZW'
    'RBdBIiCgpkZWxldGVkX2F0GAogASgDSAJSCWRlbGV0ZWRBdIgBAUIOCgxfZGVzY3JpcHRpb25C'
    'EQoPX2NvdmVyX3Bob3RvX2lkQg0KC19kZWxldGVkX2F0');

@$core.Deprecated('Use albumListDescriptor instead')
const AlbumList$json = {
  '1': 'AlbumList',
  '2': [
    {'1': 'albums', '3': 1, '4': 3, '5': 11, '6': '.family_photo.Album', '10': 'albums'},
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
    {'1': 'page', '3': 3, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'has_more', '3': 5, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `AlbumList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albumListDescriptor = $convert.base64Decode(
    'CglBbGJ1bUxpc3QSKwoGYWxidW1zGAEgAygLMhMuZmFtaWx5X3Bob3RvLkFsYnVtUgZhbGJ1bX'
    'MSHwoLdG90YWxfY291bnQYAiABKAVSCnRvdGFsQ291bnQSEgoEcGFnZRgDIAEoBVIEcGFnZRIb'
    'CglwYWdlX3NpemUYBCABKAVSCHBhZ2VTaXplEhkKCGhhc19tb3JlGAUgASgIUgdoYXNNb3Jl');

