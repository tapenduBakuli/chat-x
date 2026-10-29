import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../Store/vm.dart';

class Keys {
  static const String AUTHTOKEN = "authToken";
  static const String LATITUDE = "latitude";
  static const String LONGITUDE = "longitude";

  // Remember-me (login) credentials.
  static const String REMEMBERME = "rememberMe";
  static const String SAVEDEMAIL = "savedEmail";
  static const String SAVEDNAME = "savedName";
  static const String SAVEDPROFILENAME = "savedProfileName";
  static const String SAVEDAVATAR = "savedAvatar";
  static const String SAVEDPASSWORD = "savedPassword";

  // Auth session.
  static const String ACCESSTOKEN = "accessToken";
  static const String REFRESHTOKEN = "refreshToken";
  static const String USERID = "userId";
  static const String LOGGEDIN = "logged_in";

  // Session identity (set ONLY on a real login, not on register).
  static const String SESSIONEMAIL = "sessionEmail";
  static const String SESSIONDISPLAYNAME = "sessionDisplayName";

  // Token saved after register so onboarding calls can authenticate without
  // establishing a logged-in session.
  static const String REGISTRATIONTOKEN = "registrationToken";
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

  /// Clears the auth session + onboarding keys on logout, but PRESERVES the
  /// remember-me credentials (REMEMBERME / SAVEDEMAIL / SAVEDPASSWORD) so the
  /// login screen can still prefill them next time.
  clearSession() {
    defBox.delete(Keys.AUTHTOKEN);
    defBox.delete(Keys.ACCESSTOKEN);
    defBox.delete(Keys.REFRESHTOKEN);
    defBox.delete(Keys.USERID);
    defBox.delete(Keys.LOGGEDIN);
    defBox.delete(Keys.SESSIONEMAIL);
    defBox.delete(Keys.SESSIONDISPLAYNAME);
    defBox.delete(Keys.REGISTRATIONTOKEN);
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
