import 'package:myapp/domain/usecases/create_pickup_request_usecase.dart';
import 'package:myapp/domain/usecases/get_my_students_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:myapp/data/datasources/guardian_remote_datasource.dart';
import 'package:myapp/data/repositories/guardian_repository_impl.dart';
import 'package:myapp/domain/entities/school.dart';
import 'package:myapp/domain/entities/student.dart';
import 'package:myapp/domain/repositories/guardian_repository.dart';
import 'package:myapp/domain/usecases/get_my_schools_usecase.dart';
import 'package:myapp/domain/usecases/get_students_by_school_usecase.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';

part 'guardian_provider.g.dart';

// --- Data & Domain Layer Providers ---
@riverpod
GuardianRemoteDataSource guardianRemoteDataSource(GuardianRemoteDataSourceRef ref) {
  return GuardianRemoteDataSourceImpl(ref.watch(apiClientProvider));
}

@riverpod
CreatePickupRequestUseCase createPickupRequestUseCase(CreatePickupRequestUseCaseRef ref) {
  return CreatePickupRequestUseCase(ref.watch(guardianRepositoryProvider));
}
@riverpod
class PickupRequest extends _$PickupRequest {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null); // الحالة الأولية، لا يوجد طلب قيد التنفيذ
  }

  Future<void> sendRequest(String studentId) async {
    state = const AsyncLoading(); // تغيير الحالة إلى "تحميل"
    
    final useCase = ref.read(createPickupRequestUseCaseProvider);
    final result = await useCase(studentId);

    // تحديث الحالة بناءً على نتيجة الطلب
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
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
GetStudentsBySchoolUseCase getStudentsBySchoolUseCase(GetStudentsBySchoolUseCaseRef ref) {
  return GetStudentsBySchoolUseCase(ref.watch(guardianRepositoryProvider));
}

// --- Presentation Layer Providers ---

// Provider لجلب قائمة المدارس
@riverpod
Future<List<School>> mySchools(MySchoolsRef ref) {
  final usecase = ref.watch(getMySchoolsUseCaseProvider);
  return usecase().then((result) => result.fold(
        (failure) => throw failure.message,
        (schools) => schools,
      ));
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

// Provider لجلب قائمة الطلاب بناءً على المدرسة المختارة
@riverpod
Future<List<Student>> studentsBySchool(StudentsBySchoolRef ref) {
  final selectedSchool = ref.watch(selectedSchoolProvider);

  // إذا لم يتم اختيار مدرسة، أرجع قائمة فارغة
  if (selectedSchool == null) {
    return Future.value([]);
  }

  final usecase = ref.watch(getStudentsBySchoolUseCaseProvider);
  return usecase(selectedSchool.id).then((result) => result.fold(
        (failure) => throw failure.message,
        (students) => students,
      ));
}
