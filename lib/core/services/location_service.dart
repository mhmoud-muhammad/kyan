// lib/core/services/location_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/core/errors/exception_mapper.dart';

class LocationService {
  Position? _cachedHigh;
  DateTime? _cachedAt;

  Future<Either<Failure, bool>> _handlePermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Left(
          PermissionFailure(
            'خدمة الموقع (GPS) معطلة\nفعّلها من إعدادات الجهاز ثم أعد المحاولة',
            requiresSettings: true,
          ),
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Left(
            PermissionFailure(
              'يجب السماح للتطبيق بالوصول إلى موقعك لإرسال طلب الاستلام',
            ),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Left(
          PermissionFailure(
            'صلاحية الموقع مرفوضة\nفعّلها من إعدادات التطبيق لإرسال طلب الاستلام',
            requiresSettings: true,
          ),
        );
      }

      return const Right(true);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  /// ✅ تشغيل GPS عالي الدقة مسبقاً (بدون تعطيل UI)
  Future<void> warmUpHighAccuracy() async {
    final perm = await _handlePermission();
    await perm.fold((_) async {}, (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            timeLimit: Duration(seconds: 10),
          ),
        );
        _cachedHigh = pos;
        _cachedAt = DateTime.now();
      } catch (_) {
        // تجاهل هنا: لأن هذا Warmup فقط
      }
    });
  }

  /// ✅ موقع High accuracy “حديث” لو موجود، وإلا يجيب جديد
  Future<Either<Failure, Position>> getHighAccuracyFresh({
    Duration maxAge = const Duration(seconds: 25),
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    final perm = await _handlePermission();
    return await perm.fold(
      (failure) async => Left(failure),
      (_) async {
        // 1) لو عندنا cached حديث
        if (_cachedHigh != null && _cachedAt != null) {
          final age = DateTime.now().difference(_cachedAt!);
          if (age <= maxAge) return Right(_cachedHigh!);
        }

        try {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 0,
              timeLimit: timeLimit,
            ),
          );
          _cachedHigh = pos;
          _cachedAt = DateTime.now();
          return Right(pos);
        } catch (e) {
          // GPS أخذ وقت طويل أو فشل في تحديد الموقع
          return Left(
            PermissionFailure(
              'تعذر تحديد موقعك بدقة.\n'
              'فعّل GPS، وانتظر قليلاً، وتأكد أنك في مكان مفتوح.',
            ),
          );
        }
      },
    );
  }
}