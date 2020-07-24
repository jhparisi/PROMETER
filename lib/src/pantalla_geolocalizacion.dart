/* //import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:geolocator/geolocator.dart';

Position _currentPosition;

class PTLocalizacion extends StatefulWidget {
  static const String routeName = "/pantalla_geolocalizacion";
  PTLocalizacion({Key key}) : super(key: key);
  @override
  _PTLocalizacionState createState() => new _PTLocalizacionState();
}

class _PTLocalizacionState extends State<PTLocalizacion> {
  /* bool _enabled;
  String _locationJSON;
  JsonEncoder _encoder = new JsonEncoder.withIndent('  '); */

  @override
  void initState() {
    super.initState();
    ////
    // 1.  Listen to events (See docs for all 12 available events).
    //

    // Fired whenever a location is recorded
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      print('[location] - $location');
      _getCurrentLocation();
    });

    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] - $location');
      _getCurrentLocation();
    });

    // Fired whenever the state of location-services changes.  Always fired at boot
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      print('[providerchange] - $event');
      _getCurrentLocation();
    });

    ////
    // 2.  Configure the plugin
    //
    bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        //distanceFilter: 1.0,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: false,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE
    )).then((bg.State state) {
      bg.BackgroundGeolocation.start();
      /* if (!state.enabled) {
        ////
        // 3.  Start the plugin.
        //
        bg.BackgroundGeolocation.start();
      } */
    });
  }


  _getCurrentLocation() async {
    
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) {
        setState(() {
          _currentPosition = position;
        if (_currentPosition != null){            
            print("LAT: " + _currentPosition.latitude.toString() + "/ LON: " + _currentPosition.longitude.toString() );
          }
          });
      }).catchError((e) {
        print(e);
      });
  }
  
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('BGGeo Firebase Example', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.amberAccent,
          brightness: Brightness.light,
          actions: <Widget>[
            //Switch(value: _enabled, onChanged: _onClickEnable),
          ]
        ),
        body: Text("asdasdasd"),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            padding: EdgeInsets.only(left: 5.0, right:5.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                ]
            )
          )
        ),
      ),
    );
  }
} */