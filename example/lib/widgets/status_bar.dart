part of 'widgets.dart';

/// Status bar widget showing map state
class StatusBar extends StatelessWidget {
  const StatusBar({
    required this.isMapReady,
    required this.zoomLevel,
    required this.isPoisVisible,
    required this.poiScale,
    super.key,
  });

  final bool isMapReady;
  final int zoomLevel;
  final bool isPoisVisible;
  final int poiScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFEE500),
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isMapReady ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMapReady ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isMapReady ? 'Ready' : 'Loading...',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          Text('Zoom: $zoomLevel'),
          const SizedBox(width: 16),
          Text('POIs: ${isPoisVisible ? 'ON' : 'OFF'}'),
          const SizedBox(width: 16),
          Text('Scale: $poiScale'),
        ],
      ),
    );
  }
}
