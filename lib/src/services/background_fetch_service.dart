//import 'dart:async';

import 'package:eszaworker/src/pantalla_play_pause.dart';
import 'package:eszaworker/src/services/stoppable_service.dart';
//import 'package:geolocator/geolocator.dart';
PTCerrarRuta playpause = new PTCerrarRuta();
class BackgroundFetchService extends StoppableService {
  @override
  void start() {
    super.start();

    // Start listeneing
    print('BackgroundFetchService Started $serviceStopped');
  }

  @override
  void stop() {
    super.stop();
    //playpause.
    // stop listening
    print('AQUI ESTA FUNCIONANDO EL SERVICIO');
    /*final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
     Timer.periodic(Duration(seconds: 1), (timer){
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) {
            print("LAT: " + position.latitude.toString() + "/ LON: " + position.longitude.toString() + " / SERVICIO:" );
      }).catchError((e) {
        print(e);
      });
    }); */
      
  }
}