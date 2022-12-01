import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_esp32/MainPage.dart';

bool requestbluetoothScanB = false;
bool requestbluetoothConnectB = false;

class Permissionl {
  void requestbluetoothScan() async {
    var status = await Permission.bluetoothScan.status;
    if (status.isGranted) {
      requestbluetoothScanB = true;
      print('這可以');
    } else if (status.isDenied) {
      requestbluetoothScanB = false;
      if (await Permission.bluetoothScan.request().isGranted) {
        allpermissiomb = true;
        requestbluetoothScanB = true;
        print('幹我成功了');
      }
    }
  }

  void requestbluetoothConnect() async {
    var status = await Permission.bluetoothConnect.status;
    if (status.isGranted) {
      requestbluetoothConnectB = true;
      print('這可以');
    } else if (status.isDenied) {
      requestbluetoothConnectB = false;
      if (await Permission.bluetoothConnect.request().isGranted) {
        allpermissiomb = true;
        requestbluetoothConnectB = true;
        print('幹我成功了');
      }
    }
  }
}
