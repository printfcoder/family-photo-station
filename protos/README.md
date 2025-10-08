# Protocol Buffers for Family Photo Station

This directory contains Protocol Buffer definitions for shared data models between mobile and desktop applications.

## Models

- `album.proto`: Defines Album model and related structures
- `photo.proto`: Defines Photo model and related structures including EXIF and location data

## Usage

### Generate Dart Code

To generate Dart code for Flutter applications, use the following commands:

#### For Mobile App

```bash
protoc --dart_out=e:\Projects\family-photo-station\mobile\lib\core\models\generated -Ie:\Projects\family-photo-station\protos e:\Projects\family-photo-station\protos\*.proto
```

#### For Desktop App

```bash
protoc --dart_out=e:\Projects\family-photo-station\station\desktop\lib\core\models\generated -Ie:\Projects\family-photo-station\protos e:\Projects\family-photo-station\protos\*.proto
```

### Requirements

- Protocol Buffers compiler (`protoc`)
- Dart protoc plugin (`protoc_plugin`)

## Integration

After generating the Dart code, you can use the models in your Flutter applications by importing them from the generated directory using absolute paths.