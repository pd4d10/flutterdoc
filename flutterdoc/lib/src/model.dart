import 'package:json_annotation/json_annotation.dart';
part 'model.g.dart';

@JsonSerializable()
class DocPayload {
  String name;
  String description;
  List<DocItemPayload> items;
  DocPayload(this.name, this.description, this.items);
  factory DocPayload.fromJson(Map<String, dynamic> map) =>
      _$DocPayloadFromJson(map);
  Map<String, dynamic> toJson() => _$DocPayloadToJson(this);
}

@JsonSerializable()
class DocItemPayload {
  String name;
  String description;
  String source;
  DocItemPayload(this.name, this.description, this.source);
  factory DocItemPayload.fromJson(Map<String, dynamic> map) =>
      _$DocItemPayloadFromJson(map);
  Map<String, dynamic> toJson() => _$DocItemPayloadToJson(this);
}

@JsonSerializable()
class DocConfig {
  @JsonKey(defaultValue: 'flutterdoc')
  String input;
  @JsonKey(defaultValue: 'flutterdoc_gallery')
  String output;
  @JsonKey()
  String ga_id;
  DocConfig({this.input, this.output, this.ga_id});
  factory DocConfig.fromJson(Map<String, dynamic> map) =>
      _$DocConfigFromJson(map);
  Map<String, dynamic> toJson() => _$DocConfigToJson(this);
}
