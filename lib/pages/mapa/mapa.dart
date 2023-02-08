import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/exam.dart';
import 'package:flutter_dandelin/model/unity.dart';
import 'package:flutter_dandelin/utils/gps_utils.dart';
import 'package:flutter_dandelin/utils/image_to_marker.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPage extends StatefulWidget {
  final Function(dynamic) onTapMarker;
  //pode ser uma lista de consulta ou exame
  //ou um exame ou uma consulta que está marcada ou no histórico.
  final Stream stream;
  //controlar se para a posição no mapa começar na lat/lng do exame/consulta ou na posição atual do
  final bool isDetalheConsultaOuExame;
  //se caso for consulta marcada, busca latLng do 'scheduleDoctor' e não da adress do doctor.user
  final bool isConsultaMarcada;

  const MapaPage({
    Key key,
    @required this.stream,
    @required this.onTapMarker,
    this.isDetalheConsultaOuExame = false,
    this.isConsultaMarcada = false,
  }) : super(key: key);
  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  bool latLngIsNull = false;

  Completer<GoogleMapController> _controller = Completer();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  bool temMarkerSelecionado = false;
  LatLng latLngMoveMarker;

  var listener;
  void initState() {
    super.initState();

    if (!widget.isDetalheConsultaOuExame) {
      GPSUtils.getLoc().then((location) {
        if (location != null) {
          setState(() {
            latLngMoveMarker = LatLng(location.latitude, location.longitude);
          });
        }
      });
    }

    listener = widget.stream.listen((v) {
      markers = <MarkerId, Marker>{};
      _initMarker(v);
    });
  }

  _initMarker(data) async {
    //n tem nada
    if (data == null) {
      _setNoMarkers();
    } else if (data is List) {
      if (data.length == 0) {
        _setNoMarkers();
      } else {
        if (data.where((c) => c.markerSelected == true).length > 0) {
          temMarkerSelecionado = true;
        } else {
          temMarkerSelecionado = false;
        }

        data.forEach((value) async {
          _buildMarker(value);
        });
      }
    } else {
      _buildMarker(data);
    }
  }

  _buildMarker(dynamic value) async {
    String id;
    LatLng latLng;

    String selectedMarker;
    String unselectedMarker;

    if (value is Consulta) {
      id = value.id.toString();
      latLng = value.getAdress(widget.isConsultaMarcada);

      selectedMarker = 'assets/images/map-marker.png';
      unselectedMarker = 'assets/images/marker-unselected.png';
    } else if (value is Unity) {
      Unity unity = value;

      id = unity.id.toString();
      latLng = unity.getAdress(unity);

      selectedMarker = 'assets/images/map-marker-unity.png';
      unselectedMarker = 'assets/images/marker-unselected-unity.png';
    } else {
      Exam exam = value;
      id = exam.scheduleExam.id.toString();

      latLng = exam.scheduleExam.address.getLatLng;

      selectedMarker = 'assets/images/map-marker-unity.png';
      unselectedMarker = 'assets/images/marker-unselected-unity.png';
    }

    if (latLng != null) {
      MarkerId markerId = MarkerId(id);

      final Uint8List markerIcon = await getBytesFromAsset(
          temMarkerSelecionado &&
                  (value.markerSelected == null || !value.markerSelected)
              ? unselectedMarker
              : selectedMarker,
          value.markerSelected != null && value.markerSelected
              ? SizeConfig.screenHeight ~/ 2.8
              : SizeConfig.screenHeight ~/ 4.2);

      final Marker marker = Marker(
        icon: BitmapDescriptor.fromBytes(markerIcon),
        markerId: markerId,
        position: latLng,
        onTap: () {
          widget.onTapMarker(value);
          temMarkerSelecionado = true;
        },
      );

      setState(() {
        markers[markerId] = marker;
        if (widget.isDetalheConsultaOuExame) {
          latLngMoveMarker = latLng;
        }
      });
    } else {
      if (widget.isDetalheConsultaOuExame) {
        setState(() {
          latLngIsNull = true;
        });
      }
    }
  }

  _setNoMarkers() {
    setState(() {
      markers = <MarkerId, Marker>{};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      color: Colors.white,
      alignment: Alignment.center,
      child: latLngIsNull
          ? Stack(
              children: <Widget>[
                _map(),
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black54,
                  child: AppText(
                    "Endereço não disponível.",
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          : latLngMoveMarker == null
              ? Center(
                  child: Progress(),
                )
              : _map(),
    );
  }

  _map() {
    return GoogleMap(
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: latLngMoveMarker,
        zoom: 15,
      ),
      onMapCreated: (GoogleMapController controller) async {
        // print(latLngMoveMarker);
        _controller.complete(controller);
        // controller.animateCamera(CameraUpdate.newCameraPosition(
        //     CameraPosition(target: latLngMoveMarker, zoom: 16)));
      },
      markers: Set<Marker>.of(markers.values),
    );
  }

  // moveCamera(LatLng latLng) async {
  //   final GoogleMapController controller = await _controller.future;

  //   controller.animateCamera(CameraUpdate.newCameraPosition(
  //       CameraPosition(target: latLng, zoom: 16)));
  // }

  @override
  void dispose() {
    super.dispose();
    listener?.cancel();
  }
}
