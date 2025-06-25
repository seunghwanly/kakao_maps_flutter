import 'package:flutter/material.dart';
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';

/// Example screen demonstrating Compass and ScaleBar features.
class CompassScaleBarExampleScreen extends StatefulWidget {
  const CompassScaleBarExampleScreen({super.key});

  @override
  State<CompassScaleBarExampleScreen> createState() =>
      _CompassScaleBarExampleScreenState();
}

class _CompassScaleBarExampleScreenState
    extends State<CompassScaleBarExampleScreen> {
  bool _showCompass = true;
  bool _showScaleBar = true;
  CompassAlignment _compassAlignment = CompassAlignment.topRight;
  KakaoMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass & ScaleBar Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Control panel
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_mapController != null) {
                          if (_showCompass) {
                            await _mapController!.hideCompass();
                          } else {
                            await _mapController!.showCompass();
                          }
                          setState(() {
                            _showCompass = !_showCompass;
                          });
                        }
                      },
                      child:
                          Text(_showCompass ? 'Hide Compass' : 'Show Compass'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_mapController != null) {
                          if (_showScaleBar) {
                            await _mapController!.hideScaleBar();
                          } else {
                            await _mapController!.showScaleBar();
                          }
                          setState(() {
                            _showScaleBar = !_showScaleBar;
                          });
                        }
                      },
                      child: Text(
                        _showScaleBar ? 'Hide ScaleBar' : 'Show ScaleBar',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Compass position controls
                if (_showCompass) ...[
                  const Text(
                    'Compass Position:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current: ${_getAlignmentLabel(_compassAlignment)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: CompassAlignment.values.map((alignment) {
                      return ChoiceChip(
                        label: Text(_getAlignmentLabel(alignment)),
                        selected: _compassAlignment == alignment,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _compassAlignment = alignment;
                            });
                            // Update compass position dynamically
                            _mapController?.setCompassPosition(
                              alignment: alignment,
                              offset: const Offset(20, 20),
                            );
                            // Show a brief snackbar for feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Compass moved to ${_getAlignmentLabel(alignment)}',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          // Map
          Expanded(
            child: KakaoMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialPosition: const LatLng(
                latitude: 37.5665,
                longitude: 126.9780,
              ),
              initialLevel: 15,
              compass: Compass(
                alignment: _compassAlignment,
                offset: const Offset(
                  20,
                  20,
                ), // Add some offset from the corner
              ),
              scaleBar: const ScaleBar(),
            ),
          ),
        ],
      ),
    );
  }

  String _getAlignmentLabel(CompassAlignment alignment) {
    switch (alignment) {
      case CompassAlignment.topLeft:
        return 'Top Left';
      case CompassAlignment.topRight:
        return 'Top Right';
      case CompassAlignment.bottomLeft:
        return 'Bottom Left';
      case CompassAlignment.bottomRight:
        return 'Bottom Right';
      case CompassAlignment.center:
        return 'Center';
      case CompassAlignment.topCenter:
        return 'Top Center';
      case CompassAlignment.bottomCenter:
        return 'Bottom Center';
      case CompassAlignment.leftCenter:
        return 'Left Center';
      case CompassAlignment.rightCenter:
        return 'Right Center';
    }
  }
}
