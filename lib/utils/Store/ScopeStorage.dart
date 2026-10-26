import 'package:flutter/material.dart';

import 'ShareStore.dart';

class ScopeStorage {
  var scopeData = Map<KeyStore, Object>();
  var scopeContext = Map<KeyStore, BuildContext>();

  void saveData({required KeyStore store, required Object object}) {
    scopeData[store] = object;
    debugPrint('Successfully saved');
  }

  void saveContext({required BuildContext object}) {
    scopeContext[KeyStore.BuildContext] = object;
    debugPrint('Context Successfully saved');
  }

  BuildContext? getContext() {
    debugPrint(scopeData[KeyStore.BuildContext].toString());
    return scopeContext[KeyStore.BuildContext];
  }

  void deleteData({required KeyStore scope}) {
    scopeData.remove(scope);
    debugPrint('deleteData Success');
  }

  Object? getData({required KeyStore store}) {
    debugPrint(scopeData[store].toString());
    return scopeData[store];
  }

  void updateDataWhileNotPresent(
      {required KeyStore store, required Object object}) {
    scopeData.putIfAbsent(store, () => object);
    debugPrint('updateDataWhileNotPresent Success');
  }

  void replaceData({required KeyStore store, required Object object}) {
    scopeData.update(store, (e) => object);
    debugPrint('replaceData Success');
  }

  void clear() {
    scopeData.clear();
    debugPrint('clear Success');
  }
}
