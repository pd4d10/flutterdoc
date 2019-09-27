// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocPayload _$DocPayloadFromJson(Map<String, dynamic> json) {
  return DocPayload(
    json['name'] as String,
    json['description'] as String,
    (json['items'] as List)
        ?.map((e) => e == null
            ? null
            : DocItemPayload.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$DocPayloadToJson(DocPayload instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'items': instance.items,
    };

DocItemPayload _$DocItemPayloadFromJson(Map<String, dynamic> json) {
  return DocItemPayload(
    json['name'] as String,
    json['description'] as String,
    json['source'] as String,
  );
}

Map<String, dynamic> _$DocItemPayloadToJson(DocItemPayload instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'source': instance.source,
    };

DocConfig _$DocConfigFromJson(Map<String, dynamic> json) {
  return DocConfig(
    input: json['input'] as String ?? 'flutterdoc',
    output: json['output'] as String ?? 'flutterdoc_gallery',
    ga_id: json['ga_id'] as String,
  );
}

Map<String, dynamic> _$DocConfigToJson(DocConfig instance) => <String, dynamic>{
      'input': instance.input,
      'output': instance.output,
      'ga_id': instance.ga_id,
    };
