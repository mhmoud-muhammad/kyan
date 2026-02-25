import 'package:geolocator/geolocator.dart';
import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/exception_mapper.dart';
import 'package:myapp/core/errors/failures.dart';

class LocationService {
  /// يتحقق من صلاحيات الموقع وخدماته
  Future<Either<Failure, bool>> _handlePermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Left(ServerFailure('خدمة الموقع معطلة'));
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Left(UnauthorizedFailure('صلاحيات الموقع مرفوضة'));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Left(UnauthorizedFailure('تم رفض صلاحيات الموقع بشكل دائم'));
      }

      return const Right(true);
    } catch (e) {
      final failure = mapExceptionToFailure(e is Exception ? e : Exception(e.toString()));
      return Left(failure);
    }
  }

  /// الحصول على الموقع الحالي مع إدارة الأخطاء عبر Mapper
  Future<Either<Failure, Position>> getCurrentLocation() async {
    final permissionResult = await _handlePermission();
    return await permissionResult.fold(
      (failure) => Left(failure),
      (hasPermission) async {
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 0,
            ),
          );
          return Right(position);
        } catch (e) {
          final failure = mapExceptionToFailure(e is Exception ? e : Exception(e.toString()));
          return Left(failure);
        }
      },
    );
  }
}