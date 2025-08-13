/// Base data model
/// [EN]
/// - Common interface for JSON-serializable SDK data models
///
/// [KO]
/// - SDK 데이터 모델의 공통 JSON 직렬화 인터페이스
abstract class Data {
  /// Construct data model
  const Data();

  /// Serialize to JSON
  /// [EN]
  /// - Returns JSON-encodable map
  ///
  /// [KO]
  /// - JSON 직렬화 가능한 맵 반환
  Map<String, Object?> toJson();
}
