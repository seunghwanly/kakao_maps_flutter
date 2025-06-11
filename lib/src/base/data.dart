/// Base class for all data models in the Kakao Maps Flutter plugin.
///
/// Provides a common interface for converting data objects to JSON.
abstract class Data {
  /// Creates a new Data instance.
  const Data();

  /// Converts this data object to a JSON map.
  ///
  /// Returns a map that can be serialized to JSON.
  Map<String, Object?> toJson();
}
