import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Widget crearMapa(
  LatLng punto, {
  MapController? controlador,
  TapCallback? alTocar,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10.0),
    child: SizedBox(
      height: 220,
      child: FlutterMap(
        mapController: controlador,
        options: MapOptions(
          initialCenter: punto,
          initialZoom: 17,
          onTap: alTocar,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.fixly',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: punto,
                width: 40,
                height: 40,
                alignment: Alignment.topCenter,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
          const SimpleAttributionWidget(source: Text('OpenStreetMap')),
        ],
      ),
    ),
  );
}
