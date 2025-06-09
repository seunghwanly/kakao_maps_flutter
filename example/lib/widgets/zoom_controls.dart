part of 'widgets.dart';

/// Zoom controls widget for map
class ZoomControls extends StatelessWidget {
  const ZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onGetCenter,
    required this.enabled,
    super.key,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onGetCenter;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: enabled ? onZoomIn : null,
                icon: const Icon(Icons.add),
                tooltip: 'Zoom In',
              ),
              IconButton(
                onPressed: enabled ? onZoomOut : null,
                icon: const Icon(Icons.remove),
                tooltip: 'Zoom Out',
              ),
              IconButton(
                onPressed: enabled ? onGetCenter : null,
                icon: const Icon(Icons.center_focus_strong),
                tooltip: 'Get Center',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
