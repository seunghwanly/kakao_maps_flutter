import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';

/// Represents a click event on a marker cluster.
class ClusterClickEvent {
  const ClusterClickEvent({
    required this.clustererId,
    required this.position,
    required this.size,
    required this.bounds,
  });

  /// The ID of the clusterer that this cluster belongs to.
  final String clustererId;

  /// The center position of the cluster.
  final LatLng position;

  /// The number of markers in the cluster.
  final int size;

  /// The bounds of the cluster.
  final LatLngBounds bounds;
}
