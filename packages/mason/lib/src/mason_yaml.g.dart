// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mason_yaml.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MasonYaml _$MasonYamlFromJson(Map json) => $checkedCreate(
      'MasonYaml',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['bricks'],
        );
        final val = MasonYaml(
          $checkedConvert(
              'bricks',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, Brick.fromJson(e as Map)),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$MasonYamlToJson(MasonYaml instance) => <String, dynamic>{
      'bricks': instance.bricks.map((k, e) => MapEntry(k, e.toJson())),
    };

Brick _$BrickFromJson(Map json) => $checkedCreate(
      'Brick',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['path', 'git'],
        );
        final val = Brick(
          path: $checkedConvert('path', (v) => v as String?),
          git: $checkedConvert(
              'git', (v) => v == null ? null : GitPath.fromJson(v as Map)),
        );
        return val;
      },
    );

Map<String, dynamic> _$BrickToJson(Brick instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('path', instance.path);
  writeNotNull('git', instance.git?.toJson());
  return val;
}

GitPath _$GitPathFromJson(Map json) => $checkedCreate(
      'GitPath',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['url', 'path', 'ref'],
        );
        final val = GitPath(
          $checkedConvert('url', (v) => v as String),
          path: $checkedConvert('path', (v) => v as String?),
          ref: $checkedConvert('ref', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$GitPathToJson(GitPath instance) {
  final val = <String, dynamic>{
    'url': instance.url,
    'path': instance.path,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('ref', instance.ref);
  return val;
}
