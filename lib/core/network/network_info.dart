  //lib/core/network/network_info.dart
  import 'package:connectivity_plus/connectivity_plus.dart';

  /// Abstract Network Info
  abstract class NetworkInfo {
    Future<bool> get isConnected;
  }

  /// Implementation using connectivity_plus
  class NetworkInfoImpl implements NetworkInfo {
    final Connectivity _connectivity;

    NetworkInfoImpl({Connectivity? connectivity})
        : _connectivity = connectivity ?? Connectivity();

    @override
    Future<bool> get isConnected async {
      try {
        final result = await _connectivity.checkConnectivity();
        // ignore: unrelated_type_equality_checks
        return result != ConnectivityResult.none;
      } catch (e) {
        // إذا فشل الفحص، افترض أن الاتصال غير متاح
        
        return false;
      }
    }
  }
