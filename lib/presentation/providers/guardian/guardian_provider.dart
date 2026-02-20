// lib/presentation/providers/guardian_provider.dart
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/domain/usecases/create_pickup_request_usecase.dart';
import 'package:myapp/domain/usecases/get_my_students_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:myapp/data/datasources/guardian_remote_datasource.dart';
import 'package:myapp/data/repositories/guardian_repository_impl.dart';
import 'package:myapp/domain/entities/school.dart';
import 'package:myapp/domain/entities/student.dart';
import 'package:myapp/domain/repositories/guardian_repository.dart';
import 'package:myapp/domain/usecases/get_my_schools_usecase.dart';
import 'package:myapp/presentation/providers/auth/auth_provider.dart';

part 'guardian_provider.g.dart';

@riverpod
GuardianRemoteDataSource guardianRemoteDataSource(
  GuardianRemoteDataSourceRef ref,
) {
  return GuardianRemoteDataSourceImpl(ref.watch(apiClientProvider));
}

@riverpod
CreatePickupRequestUseCase createPickupRequestUseCase(
  CreatePickupRequestUseCaseRef ref,
) {
  return CreatePickupRequestUseCase(ref.watch(guardianRepositoryProvider));
}

// داخل guardian_provider.dart بعد الـ providers الحالية

// lib/presentation/providers/guardian/guardian_provider.dart

@riverpod
class PickupRequestForStudent extends _$PickupRequestForStudent {
  @override
  AsyncValue<void> build(String studentId) => const AsyncData(null);

  Future<void> sendRequest({double? lat, double? lng}) async {
    state = const AsyncLoading();
    final useCase = ref.read(createPickupRequestUseCaseProvider);
    final result = await useCase(studentId, lat: lat, lng: lng);

    state = result.fold(
      (failure) {
        print(
          '❌ Pickup request failed for student $studentId: ${failure.message}',
        );
        if (failure is UnauthorizedFailure) {
          ref.read(authStateProvider.notifier).logout();
        }
        return AsyncError(failure.message, StackTrace.current);
      },
      (_) {
        print('✅ Pickup request succeeded for student $studentId');
        return const AsyncData(null);
      },
    );
  }
}

@riverpod
class PickupRequest extends _$PickupRequest {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> sendRequest(String studentId) async {
    state = const AsyncLoading();
    final useCase = ref.read(createPickupRequestUseCaseProvider);
    final result = await useCase(studentId);

    state = result.fold(
      (failure) {
        print('❌ Pickup request failed: ${failure.message}');
        if (failure is UnauthorizedFailure) {
          ref.read(authStateProvider.notifier).logout();
        }
        return AsyncError(failure.message, StackTrace.current);
      },
      (_) {
        print('✅ Pickup request succeeded');
        return const AsyncData(null);
      },
    );
  }
}

@riverpod
GuardianRepository guardianRepository(GuardianRepositoryRef ref) {
  return GuardianRepositoryImpl(
    remoteDataSource: ref.watch(guardianRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}

@riverpod
GetMySchoolsUseCase getMySchoolsUseCase(GetMySchoolsUseCaseRef ref) {
  return GetMySchoolsUseCase(ref.watch(guardianRepositoryProvider));
}

@riverpod
GetStudentsBySchoolUseCase getStudentsBySchoolUseCase(
  GetStudentsBySchoolUseCaseRef ref,
) {
  return GetStudentsBySchoolUseCase(ref.watch(guardianRepositoryProvider));
}

@riverpod
Future<List<School>> mySchools(MySchoolsRef ref) {
  final usecase = ref.watch(getMySchoolsUseCaseProvider);
  return usecase().then(
    (result) => result.fold((failure) {
     if (failure is UnauthorizedFailure) {
        ref.read(authStateProvider.notifier).logout();
        throw failure.message;
      } else {
        throw failure.message;
      }
    }, (schools) => schools),
  );
}

// Provider لإدارة حالة المدرسة المختارة حاليًا
@riverpod
class SelectedSchool extends _$SelectedSchool {
  @override
  School? build() {
    return null; // لا توجد مدرسة مختارة في البداية
  }

  void selectSchool(School school) {
    state = school;
  }

  void clearSelection() {
    state = null;
  }
}

@riverpod
Future<List<Student>> studentsBySchool(StudentsBySchoolRef ref) {
  final selectedSchool = ref.watch(selectedSchoolProvider);

  if (selectedSchool == null) {
    return Future.value([]);
  }

  final usecase = ref.watch(getStudentsBySchoolUseCaseProvider);
  return usecase(selectedSchool.id).then(
    (result) => result.fold((failure) {
      // طباعة تفاصيل الخطأ
      print('❌ studentsBySchool failed: ${failure.message}');
      throw failure.message; // هذا سيؤدي إلى AsyncError في الواجهة
    }, (students) => students),
  );
}
