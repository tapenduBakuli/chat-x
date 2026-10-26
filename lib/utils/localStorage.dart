

import 'Store/HiveStore.dart';

class LocalHiveStorage {
  bool isLoggedIn = false;

  Future<bool> autoLogIn() async {
    final HiveStore prefs = await HiveStore.getInstance();
    final bool? loggedIn = prefs.getBool('logged_in');

    if (loggedIn == true) {
      isLoggedIn = true;
    }
    return isLoggedIn;
  }

  Future<Null> logout() async {
    final HiveStore prefs = await HiveStore.getInstance();
    prefs.remove('logged_in');
    prefs.remove('id');
    prefs.remove('email');
    prefs.remove('first_name');
    prefs.remove('last_name');
    prefs.remove('access_token');
    prefs.remove('payment_account_id');
    prefs.remove('payment_account_address');
    prefs.remove('city');
    prefs.remove('country');
    prefs.remove('email');
    // prefs.remove('indexLang');

    // prefs.clear();
  }

  Future<String> getValue(String key) async {
    final HiveStore prefs = await HiveStore.getInstance();
    final bool? loggedIn = prefs.getBool('logged_in');

    String localValue = "";
    if (loggedIn == true) {
      localValue = prefs.getString(key).toString();
    }
    return localValue;
  }

  Future<bool?> updateValue(String key, String value) async {
    final HiveStore prefs = await HiveStore.getInstance();
    prefs.setString(key, value);
    return null;
  }

  // Future<Null> loginUser(UserModel user) async {
  //   final HiveStore prefs = await HiveStore.getInstance();
  //   prefs.setString('id', user.id.toString());
  //   prefs.setString('email', user.email!);
  //   prefs.setString('first_name', user.firstName!);
  //   prefs.setString('last_name', user.lastName!);
  //   prefs.setString('access_token', user.accessToken!);
  //   prefs.setString('payment_account_id', user.paymentAccountId.toString());
  //   prefs.setString('payment_account_address', user.paymentAccountAddress!);
  //   prefs.setString('city', user.city!);
  //   prefs.setString('country', user.country!);
  //   prefs.setString('email', user.email!);
  //   prefs.setBool('logged_in', true);
  // }

  Future<Null> storeMusic(String musicUrl, String musicId, String musicName,
      String youtubelink) async {
    final HiveStore prefs = await HiveStore.getInstance();
    prefs.setString('musicUrl', musicUrl);
    prefs.setString('musicId', musicId);
    prefs.setString('musicName', musicName);
    prefs.setString('youtubelink', youtubelink);
  }

  Future<Null> storeVideo(String videoUrl, String videoId, String videoName,
      String youtubelink) async {
    final HiveStore prefs = await HiveStore.getInstance();
    prefs.setString('videoUrl', videoUrl);
    prefs.setString('videoId', videoId);
    prefs.setString('videoName', videoName);
    prefs.setString('youtubelinkVideo', youtubelink);
  }

  // Future<Null> updateUserDetails(UserModel user) async {
  //   final HiveStore prefs = await HiveStore.getInstance();
  //
  //   prefs.setString('email', user.email!);
  //   prefs.setString('first_name', user.firstName!);
  //   prefs.setString('last_name', user.lastName!);
  //   prefs.setString('city', user.city!);
  //   prefs.setString('country', user.country!);
  // }
}
