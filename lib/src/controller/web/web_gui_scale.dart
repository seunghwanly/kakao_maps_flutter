/// Converts a custom GUI value to a Web logical pixel value.
///
/// CSS pixels are already density-independent. The legacy renderer treated
/// custom GUI values as physical pixels and divided them by the browser DPR.
/// A null [applyDpScale] preserves that legacy behavior.
double scaleWebGuiValue(
  num value, {
  required bool? applyDpScale,
  required double devicePixelRatio,
}) {
  if (applyDpScale == true) return value.toDouble();
  if (!devicePixelRatio.isFinite || devicePixelRatio <= 0) {
    return value.toDouble();
  }
  return value / devicePixelRatio;
}
