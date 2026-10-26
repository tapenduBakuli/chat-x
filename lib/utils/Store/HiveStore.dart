import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../Store/vm.dart';

class Keys {
  static const String AUTHTOKEN = "authToken";
  static const String STAFFID = "staffId";
  static const String STAFFNAME = "staffName";
  static const String STAFFPROFILEIMAGE = "staffProfileImage";
  static const String STAFFPROFILEADDRESS = "staffProfileAddress";
  static const String POSITION = "position";
  static const String LATITUDE = "latitude";
  static const String LONGITUDE = "longitude";
  static const String ADDRESS = "address";
  static const String PHONE = "phone";
  static const String ISFIRSTTIME = "false";
  static const String INTERNETSTATUS = "internetStatus";
  static const String DEPARTMENTCODE = "departmentCode";
  static const String DEPARTMENTNAME = "departmentName";
  static const String ESTATEID = "estateId";
  static const String WEIGHBRIDGETYPE = "weighbridgeType";
  static const String ALLAPICALLED = "allAPICalled";
  static const String DIVISION = "division";
  static const String CANAPPROVETASK = "canApproveTask";
  static const String ISLATESTBUILD = "isLatestBuild";
  static const String DEVICEMODEL = "DeviceModel";
  static const String DEVICEID = "DeviceID";
}

class HiveStore {
  //Singleton Class
  static final HiveStore _default = new HiveStore._internal();
  static late Box defBox;

  factory HiveStore() {
    return _default;
  }

  HiveStore._internal();

  static getInstance() {
    return _default;
  }

  initBox() async {
    defBox = await (openBox());
  }

  //Object Storage
  put(String key, Object value) async {
    defBox.put(key, value);
    print("HiveStored : Key:$key, Value:$value");
  }

  get(String key) {
    // print("Box is Open? ${defBox.isOpen}");
    print("Hive Retrieve : Key:$key, Value:${defBox.get(key)}");
    return defBox.get(key);
  }

  //String Storage
  setString(String key, String value) async {
    defBox.put(key, value);
    print("HiveStored : Key:$key, Value:$value");
  }

  getString(String key) {
    print("Hive Retrieve : Key:$key, Value:${defBox.get(key)}");
    return defBox.get(key);
  }

  //Bool Storage
  setBool(String key, bool value) async {
    defBox.put(key, value);
    print("HiveStored : Key:$key, Value:$value");
  }

  getBool(String key) {
    print("Hive Retrieve : Key:$key, Value:${defBox.get(key)}");
    return defBox.get(key);
  }

  clear() {
    defBox.clear();
  }

  remove(String key) async {
    defBox.delete(key);
  }

  Future openBox() async {
    if (!isBrowser) {
      var dir = await getApplicationDocumentsDirectory();
      Hive
        ..init(dir
            .path) /*..registerAdapter(ScheduleReminderAdapter(),override: true,internal: true)*/;
    }
    return await Hive.openBox('Store');
  }
}
