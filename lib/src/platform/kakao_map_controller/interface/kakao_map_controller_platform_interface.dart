part of '../kakao_map_controller.dart';

/// Platform interface for Kakao Map controller functionality.
///
/// This abstract class defines the interface that platform-specific
/// implementations must follow to provide Kakao Map functionality.
abstract class KakaoMapControllerPlatform extends PlatformInterface {
  /// Creates a new KakaoMapControllerPlatform instance.
  KakaoMapControllerPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The current platform instance.
  static KakaoMapControllerPlatform get instance => _instance;

  static KakaoMapControllerPlatform _instance =
      MethodChannelKakaoMapController.instance;

  /// Sets the platform instance.
  ///
  /// Platform implementations should set this to register themselves
  /// as the active platform implementation.
  static set instance(KakaoMapControllerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Stream controller for label click events.
  final StreamController<LabelClickEvent> _onLabelClickController =
      StreamController<LabelClickEvent>.broadcast();

  /// Stream controller for info window click events.
  final StreamController<InfoWindowClickEvent> _onInfoWindowClickController =
      StreamController<InfoWindowClickEvent>.broadcast();

  /// Stream controller for camera move end events.
  final StreamController<CameraMoveEndEvent> _onCameraMoveEndController =
      StreamController<CameraMoveEndEvent>.broadcast();

  /// Stream of label click events.
  Stream<LabelClickEvent> get onLabelClickedStream =>
      _onLabelClickController.stream;

  /// Stream of info window click events.
  Stream<InfoWindowClickEvent> get onInfoWindowClickedStream =>
      _onInfoWindowClickController.stream;

  /// Stream of camera move end events.
  Stream<CameraMoveEndEvent> get onCameraMoveEndStream =>
      _onCameraMoveEndController.stream;

  /// Calls a method on the platform implementation.
  ///
  /// Platform implementations must override this method to handle
  /// method calls from the Dart side.
  Future<T> _callMethod<T>(KakaoMapMethodCall<T> methodCall) async {
    throw UnimplementedError(
      '[Flutter:KakaoMapControllerPlatform] callMethod not implemented',
    );
  }

  /// Notifies listeners of a label click event.
  void onLabelClicked(LabelClickEvent event) =>
      _onLabelClickController.add(event);

  /// Notifies listeners of an info window click event.
  void onInfoWindowClicked(InfoWindowClickEvent event) =>
      _onInfoWindowClickController.add(event);

  /// Notifies listeners of a camera move end event.
  void onCameraMoveEnd(CameraMoveEndEvent event) =>
      _onCameraMoveEndController.add(event);

  /// Disposes of resources used by this platform interface.
  ///
  /// Closes all stream controllers to prevent memory leaks.
  void dispose() {
    _onLabelClickController.close();
    _onInfoWindowClickController.close();
    _onCameraMoveEndController.close();
  }
}
