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
  KakaoMapController? _mapController;
  bool _showCompass = true;
  bool _showScaleBar = true;
  bool _showLogo = true;
  CompassAlignment _compassAlignment = CompassAlignment.topRight;
  LogoAlignment _logoAlignment = LogoAlignment.bottomLeft;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass & ScaleBar & Logo Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: _buildDrawer(),
      body: KakaoMap(
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
        logo: Logo(
          alignment: _logoAlignment,
          offset: const Offset(20, 20),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            child: const Icon(Icons.settings),
          );
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60), // Space for app bar
              const Text(
                'Map Controls',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Compass Controls
              const Text(
                'Compass:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Switch(
                    value: _showCompass,
                    onChanged: (value) {
                      setState(() {
                        _showCompass = value;
                      });
                      if (value) {
                        _mapController?.showCompass();
                      } else {
                        _mapController?.hideCompass();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(_showCompass ? 'Show' : 'Hide'),
                ],
              ),
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
              const SizedBox(height: 20),
              // ScaleBar Controls
              const Text(
                'ScaleBar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Switch(
                    value: _showScaleBar,
                    onChanged: (value) {
                      setState(() {
                        _showScaleBar = value;
                      });
                      if (value) {
                        _mapController?.showScaleBar();
                      } else {
                        _mapController?.hideScaleBar();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(_showScaleBar ? 'Show' : 'Hide'),
                ],
              ),
              const SizedBox(height: 20),
              // Logo Controls
              const Text(
                'Logo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Switch(
                    value: _showLogo,
                    onChanged: (value) {
                      setState(() {
                        _showLogo = value;
                      });
                      if (value) {
                        _mapController?.showLogo();
                      } else {
                        _mapController?.hideLogo();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(_showLogo ? 'Show' : 'Hide'),
                ],
              ),
              if (_showLogo) ...[
                const Text(
                  'Logo Position:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current: ${_getLogoAlignmentLabel(_logoAlignment)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: LogoAlignment.values.map((alignment) {
                    return ChoiceChip(
                      label: Text(_getLogoAlignmentLabel(alignment)),
                      selected: _logoAlignment == alignment,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _logoAlignment = alignment;
                          });
                          // Update logo position dynamically
                          _mapController?.setLogoPosition(
                            alignment: alignment,
                            offset: const Offset(20, 20),
                          );
                          // Show a brief snackbar for feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Logo moved to ${_getLogoAlignmentLabel(alignment)}',
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

  String _getLogoAlignmentLabel(LogoAlignment alignment) {
    switch (alignment) {
      case LogoAlignment.topLeft:
        return 'Top Left';
      case LogoAlignment.topRight:
        return 'Top Right';
      case LogoAlignment.bottomLeft:
        return 'Bottom Left';
      case LogoAlignment.bottomRight:
        return 'Bottom Right';
      case LogoAlignment.center:
        return 'Center';
      case LogoAlignment.topCenter:
        return 'Top Center';
      case LogoAlignment.bottomCenter:
        return 'Bottom Center';
      case LogoAlignment.leftCenter:
        return 'Left Center';
      case LogoAlignment.rightCenter:
        return 'Right Center';
    }
  }
}
