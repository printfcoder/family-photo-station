//
//  Generated code. Do not modify.
//  source: photo.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use photoDescriptor instead')
const Photo$json = {
  '1': 'Photo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'filename', '3': 2, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'original_filename', '3': 3, '4': 1, '5': 9, '10': 'originalFilename'},
    {'1': 'mime_type', '3': 4, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'file_size', '3': 5, '4': 1, '5': 3, '10': 'fileSize'},
    {'1': 'hash', '3': 6, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'width', '3': 7, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 8, '4': 1, '5': 5, '10': 'height'},
    {'1': 'thumbnail_path', '3': 9, '4': 1, '5': 9, '9': 0, '10': 'thumbnailPath', '17': true},
    {'1': 'exif_data', '3': 10, '4': 1, '5': 11, '6': '.family_photo.ExifData', '9': 1, '10': 'exifData', '17': true},
    {'1': 'location', '3': 11, '4': 1, '5': 11, '6': '.family_photo.LocationData', '9': 2, '10': 'location', '17': true},
    {'1': 'uploader_id', '3': 12, '4': 1, '5': 9, '10': 'uploaderId'},
    {'1': 'device_id', '3': 13, '4': 1, '5': 9, '9': 3, '10': 'deviceId', '17': true},
    {'1': 'album_id', '3': 14, '4': 1, '5': 9, '9': 4, '10': 'albumId', '17': true},
    {'1': 'created_at', '3': 15, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'updated_at', '3': 16, '4': 1, '5': 3, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 17, '4': 1, '5': 3, '9': 5, '10': 'deletedAt', '17': true},
    {'1': 'thumbnail_url', '3': 18, '4': 1, '5': 9, '9': 6, '10': 'thumbnailUrl', '17': true},
    {'1': 'url', '3': 19, '4': 1, '5': 9, '9': 7, '10': 'url', '17': true},
    {'1': 'original_url', '3': 20, '4': 1, '5': 9, '9': 8, '10': 'originalUrl', '17': true},
    {'1': 'medium_url', '3': 21, '4': 1, '5': 9, '9': 9, '10': 'mediumUrl', '17': true},
    {'1': 'tags', '3': 22, '4': 3, '5': 9, '10': 'tags'},
  ],
  '8': [
    {'1': '_thumbnail_path'},
    {'1': '_exif_data'},
    {'1': '_location'},
    {'1': '_device_id'},
    {'1': '_album_id'},
    {'1': '_deleted_at'},
    {'1': '_thumbnail_url'},
    {'1': '_url'},
    {'1': '_original_url'},
    {'1': '_medium_url'},
  ],
};

/// Descriptor for `Photo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List photoDescriptor = $convert.base64Decode(
    'CgVQaG90bxIOCgJpZBgBIAEoCVICaWQSGgoIZmlsZW5hbWUYAiABKAlSCGZpbGVuYW1lEisKEW'
    '9yaWdpbmFsX2ZpbGVuYW1lGAMgASgJUhBvcmlnaW5hbEZpbGVuYW1lEhsKCW1pbWVfdHlwZRgE'
    'IAEoCVIIbWltZVR5cGUSGwoJZmlsZV9zaXplGAUgASgDUghmaWxlU2l6ZRISCgRoYXNoGAYgAS'
    'gJUgRoYXNoEhQKBXdpZHRoGAcgASgFUgV3aWR0aBIWCgZoZWlnaHQYCCABKAVSBmhlaWdodBIq'
    'Cg50aHVtYm5haWxfcGF0aBgJIAEoCUgAUg10aHVtYm5haWxQYXRoiAEBEjgKCWV4aWZfZGF0YR'
    'gKIAEoCzIWLmZhbWlseV9waG90by5FeGlmRGF0YUgBUghleGlmRGF0YYgBARI7Cghsb2NhdGlv'
    'bhgLIAEoCzIaLmZhbWlseV9waG90by5Mb2NhdGlvbkRhdGFIAlIIbG9jYXRpb26IAQESHwoLdX'
    'Bsb2FkZXJfaWQYDCABKAlSCnVwbG9hZGVySWQSIAoJZGV2aWNlX2lkGA0gASgJSANSCGRldmlj'
    'ZUlkiAEBEh4KCGFsYnVtX2lkGA4gASgJSARSB2FsYnVtSWSIAQESHQoKY3JlYXRlZF9hdBgPIA'
    'EoA1IJY3JlYXRlZEF0Eh0KCnVwZGF0ZWRfYXQYECABKANSCXVwZGF0ZWRBdBIiCgpkZWxldGVk'
    'X2F0GBEgASgDSAVSCWRlbGV0ZWRBdIgBARIoCg10aHVtYm5haWxfdXJsGBIgASgJSAZSDHRodW'
    '1ibmFpbFVybIgBARIVCgN1cmwYEyABKAlIB1IDdXJsiAEBEiYKDG9yaWdpbmFsX3VybBgUIAEo'
    'CUgIUgtvcmlnaW5hbFVybIgBARIiCgptZWRpdW1fdXJsGBUgASgJSAlSCW1lZGl1bVVybIgBAR'
    'ISCgR0YWdzGBYgAygJUgR0YWdzQhEKD190aHVtYm5haWxfcGF0aEIMCgpfZXhpZl9kYXRhQgsK'
    'CV9sb2NhdGlvbkIMCgpfZGV2aWNlX2lkQgsKCV9hbGJ1bV9pZEINCgtfZGVsZXRlZF9hdEIQCg'
    '5fdGh1bWJuYWlsX3VybEIGCgRfdXJsQg8KDV9vcmlnaW5hbF91cmxCDQoLX21lZGl1bV91cmw=');

@$core.Deprecated('Use exifDataDescriptor instead')
const ExifData$json = {
  '1': 'ExifData',
  '2': [
    {'1': 'camera_make', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'cameraMake', '17': true},
    {'1': 'camera_model', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'cameraModel', '17': true},
    {'1': 'lens_model', '3': 3, '4': 1, '5': 9, '9': 2, '10': 'lensModel', '17': true},
    {'1': 'focal_length', '3': 4, '4': 1, '5': 1, '9': 3, '10': 'focalLength', '17': true},
    {'1': 'aperture', '3': 5, '4': 1, '5': 1, '9': 4, '10': 'aperture', '17': true},
    {'1': 'shutter_speed', '3': 6, '4': 1, '5': 1, '9': 5, '10': 'shutterSpeed', '17': true},
    {'1': 'iso', '3': 7, '4': 1, '5': 5, '9': 6, '10': 'iso', '17': true},
    {'1': 'taken_at', '3': 8, '4': 1, '5': 3, '9': 7, '10': 'takenAt', '17': true},
  ],
  '8': [
    {'1': '_camera_make'},
    {'1': '_camera_model'},
    {'1': '_lens_model'},
    {'1': '_focal_length'},
    {'1': '_aperture'},
    {'1': '_shutter_speed'},
    {'1': '_iso'},
    {'1': '_taken_at'},
  ],
};

/// Descriptor for `ExifData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exifDataDescriptor = $convert.base64Decode(
    'CghFeGlmRGF0YRIkCgtjYW1lcmFfbWFrZRgBIAEoCUgAUgpjYW1lcmFNYWtliAEBEiYKDGNhbW'
    'VyYV9tb2RlbBgCIAEoCUgBUgtjYW1lcmFNb2RlbIgBARIiCgpsZW5zX21vZGVsGAMgASgJSAJS'
    'CWxlbnNNb2RlbIgBARImCgxmb2NhbF9sZW5ndGgYBCABKAFIA1ILZm9jYWxMZW5ndGiIAQESHw'
    'oIYXBlcnR1cmUYBSABKAFIBFIIYXBlcnR1cmWIAQESKAoNc2h1dHRlcl9zcGVlZBgGIAEoAUgF'
    'UgxzaHV0dGVyU3BlZWSIAQESFQoDaXNvGAcgASgFSAZSA2lzb4gBARIeCgh0YWtlbl9hdBgIIA'
    'EoA0gHUgd0YWtlbkF0iAEBQg4KDF9jYW1lcmFfbWFrZUIPCg1fY2FtZXJhX21vZGVsQg0KC19s'
    'ZW5zX21vZGVsQg8KDV9mb2NhbF9sZW5ndGhCCwoJX2FwZXJ0dXJlQhAKDl9zaHV0dGVyX3NwZW'
    'VkQgYKBF9pc29CCwoJX3Rha2VuX2F0');

@$core.Deprecated('Use locationDataDescriptor instead')
const LocationData$json = {
  '1': 'LocationData',
  '2': [
    {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'altitude', '3': 3, '4': 1, '5': 1, '9': 0, '10': 'altitude', '17': true},
    {'1': 'place_name', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'placeName', '17': true},
    {'1': 'country', '3': 5, '4': 1, '5': 9, '9': 2, '10': 'country', '17': true},
    {'1': 'province', '3': 6, '4': 1, '5': 9, '9': 3, '10': 'province', '17': true},
    {'1': 'city', '3': 7, '4': 1, '5': 9, '9': 4, '10': 'city', '17': true},
    {'1': 'district', '3': 8, '4': 1, '5': 9, '9': 5, '10': 'district', '17': true},
  ],
  '8': [
    {'1': '_altitude'},
    {'1': '_place_name'},
    {'1': '_country'},
    {'1': '_province'},
    {'1': '_city'},
    {'1': '_district'},
  ],
};

/// Descriptor for `LocationData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationDataDescriptor = $convert.base64Decode(
    'CgxMb2NhdGlvbkRhdGESGgoIbGF0aXR1ZGUYASABKAFSCGxhdGl0dWRlEhwKCWxvbmdpdHVkZR'
    'gCIAEoAVIJbG9uZ2l0dWRlEh8KCGFsdGl0dWRlGAMgASgBSABSCGFsdGl0dWRliAEBEiIKCnBs'
    'YWNlX25hbWUYBCABKAlIAVIJcGxhY2VOYW1liAEBEh0KB2NvdW50cnkYBSABKAlIAlIHY291bn'
    'RyeYgBARIfCghwcm92aW5jZRgGIAEoCUgDUghwcm92aW5jZYgBARIXCgRjaXR5GAcgASgJSARS'
    'BGNpdHmIAQESHwoIZGlzdHJpY3QYCCABKAlIBVIIZGlzdHJpY3SIAQFCCwoJX2FsdGl0dWRlQg'
    '0KC19wbGFjZV9uYW1lQgoKCF9jb3VudHJ5QgsKCV9wcm92aW5jZUIHCgVfY2l0eUILCglfZGlz'
    'dHJpY3Q=');

@$core.Deprecated('Use photoListDescriptor instead')
const PhotoList$json = {
  '1': 'PhotoList',
  '2': [
    {'1': 'photos', '3': 1, '4': 3, '5': 11, '6': '.family_photo.Photo', '10': 'photos'},
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
    {'1': 'page', '3': 3, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'has_more', '3': 5, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `PhotoList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List photoListDescriptor = $convert.base64Decode(
    'CglQaG90b0xpc3QSKwoGcGhvdG9zGAEgAygLMhMuZmFtaWx5X3Bob3RvLlBob3RvUgZwaG90b3'
    'MSHwoLdG90YWxfY291bnQYAiABKAVSCnRvdGFsQ291bnQSEgoEcGFnZRgDIAEoBVIEcGFnZRIb'
    'CglwYWdlX3NpemUYBCABKAVSCHBhZ2VTaXplEhkKCGhhc19tb3JlGAUgASgIUgdoYXNNb3Jl');

