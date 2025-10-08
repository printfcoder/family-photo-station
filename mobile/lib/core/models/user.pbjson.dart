//
//  Generated code. Do not modify.
//  source: user.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use userRoleDescriptor instead')
const UserRole$json = {
  '1': 'UserRole',
  '2': [
    {'1': 'USER_ROLE_UNSPECIFIED', '2': 0},
    {'1': 'USER_ROLE_USER', '2': 1},
    {'1': 'USER_ROLE_ADMIN', '2': 2},
    {'1': 'USER_ROLE_MODERATOR', '2': 3},
  ],
};

/// Descriptor for `UserRole`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userRoleDescriptor = $convert.base64Decode(
    'CghVc2VyUm9sZRIZChVVU0VSX1JPTEVfVU5TUEVDSUZJRUQQABISCg5VU0VSX1JPTEVfVVNFUh'
    'ABEhMKD1VTRVJfUk9MRV9BRE1JThACEhcKE1VTRVJfUk9MRV9NT0RFUkFUT1IQAw==');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'display_name', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'displayName', '17': true},
    {'1': 'avatar', '3': 5, '4': 1, '5': 9, '9': 1, '10': 'avatar', '17': true},
    {'1': 'bio', '3': 6, '4': 1, '5': 9, '9': 2, '10': 'bio', '17': true},
    {'1': 'role', '3': 7, '4': 1, '5': 14, '6': '.family_photo.UserRole', '10': 'role'},
    {'1': 'is_active', '3': 8, '4': 1, '5': 8, '10': 'isActive'},
    {'1': 'created_at', '3': 9, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'updated_at', '3': 10, '4': 1, '5': 3, '10': 'updatedAt'},
    {'1': 'stats', '3': 11, '4': 1, '5': 11, '6': '.family_photo.UserStats', '9': 3, '10': 'stats', '17': true},
  ],
  '8': [
    {'1': '_display_name'},
    {'1': '_avatar'},
    {'1': '_bio'},
    {'1': '_stats'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEg4KAmlkGAEgASgJUgJpZBIaCgh1c2VybmFtZRgCIAEoCVIIdXNlcm5hbWUSFAoFZW'
    '1haWwYAyABKAlSBWVtYWlsEiYKDGRpc3BsYXlfbmFtZRgEIAEoCUgAUgtkaXNwbGF5TmFtZYgB'
    'ARIbCgZhdmF0YXIYBSABKAlIAVIGYXZhdGFyiAEBEhUKA2JpbxgGIAEoCUgCUgNiaW+IAQESKg'
    'oEcm9sZRgHIAEoDjIWLmZhbWlseV9waG90by5Vc2VyUm9sZVIEcm9sZRIbCglpc19hY3RpdmUY'
    'CCABKAhSCGlzQWN0aXZlEh0KCmNyZWF0ZWRfYXQYCSABKANSCWNyZWF0ZWRBdBIdCgp1cGRhdG'
    'VkX2F0GAogASgDUgl1cGRhdGVkQXQSMgoFc3RhdHMYCyABKAsyFy5mYW1pbHlfcGhvdG8uVXNl'
    'clN0YXRzSANSBXN0YXRziAEBQg8KDV9kaXNwbGF5X25hbWVCCQoHX2F2YXRhckIGCgRfYmlvQg'
    'gKBl9zdGF0cw==');

@$core.Deprecated('Use userStatsDescriptor instead')
const UserStats$json = {
  '1': 'UserStats',
  '2': [
    {'1': 'photo_count', '3': 1, '4': 1, '5': 5, '10': 'photoCount'},
    {'1': 'album_count', '3': 2, '4': 1, '5': 5, '10': 'albumCount'},
    {'1': 'total_storage_used', '3': 3, '4': 1, '5': 3, '10': 'totalStorageUsed'},
  ],
};

/// Descriptor for `UserStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userStatsDescriptor = $convert.base64Decode(
    'CglVc2VyU3RhdHMSHwoLcGhvdG9fY291bnQYASABKAVSCnBob3RvQ291bnQSHwoLYWxidW1fY2'
    '91bnQYAiABKAVSCmFsYnVtQ291bnQSLAoSdG90YWxfc3RvcmFnZV91c2VkGAMgASgDUhB0b3Rh'
    'bFN0b3JhZ2VVc2Vk');

@$core.Deprecated('Use userListDescriptor instead')
const UserList$json = {
  '1': 'UserList',
  '2': [
    {'1': 'users', '3': 1, '4': 3, '5': 11, '6': '.family_photo.User', '10': 'users'},
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
    {'1': 'page', '3': 3, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'has_more', '3': 5, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `UserList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userListDescriptor = $convert.base64Decode(
    'CghVc2VyTGlzdBIoCgV1c2VycxgBIAMoCzISLmZhbWlseV9waG90by5Vc2VyUgV1c2VycxIfCg'
    't0b3RhbF9jb3VudBgCIAEoBVIKdG90YWxDb3VudBISCgRwYWdlGAMgASgFUgRwYWdlEhsKCXBh'
    'Z2Vfc2l6ZRgEIAEoBVIIcGFnZVNpemUSGQoIaGFzX21vcmUYBSABKAhSB2hhc01vcmU=');

