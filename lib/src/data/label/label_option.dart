import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kakao_maps_flutter/src/base/data.dart';

import '../lat_lng/lat_lng.dart';

class LabelOption extends Data {
  const LabelOption({
    required this.id,
    required this.latLng,
    required this.base64EncodedImage,
  });

  factory LabelOption.fromImageBytes({
    required String id,
    required LatLng latLng,
    required Uint8List imageBytes,
  }) =>
      LabelOption(
        id: id,
        latLng: latLng,
        base64EncodedImage: base64.encode(imageBytes),
      );

  final String id;

  final LatLng latLng;

  final String? base64EncodedImage;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'latLng': latLng.toJson(),
        'base64EncodedImage': base64EncodedImage,
      };
}
