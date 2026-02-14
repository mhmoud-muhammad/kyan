// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teacherRemoteDataSourceHash() =>
    r'aca0519fccdb7b041bdcdfe67329ebc2d0d37bde';

/// See also [teacherRemoteDataSource].
@ProviderFor(teacherRemoteDataSource)
final teacherRemoteDataSourceProvider =
    AutoDisposeProvider<TeacherRemoteDataSource>.internal(
      teacherRemoteDataSource,
      name: r'teacherRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherRemoteDataSourceRef =
    AutoDisposeProviderRef<TeacherRemoteDataSource>;
String _$teacherRepositoryHash() => r'1190b89bf7fff574df1b54d58df651fb40bd8e4e';

/// See also [teacherRepository].
@ProviderFor(teacherRepository)
final teacherRepositoryProvider =
    AutoDisposeProvider<TeacherRepository>.internal(
      teacherRepository,
      name: r'teacherRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherRepositoryRef = AutoDisposeProviderRef<TeacherRepository>;
String _$dashboardStatsHash() => r'5652ffd66e1dbd05fc570963345a6c32d134bf29';

/// See also [dashboardStats].
@ProviderFor(dashboardStats)
final dashboardStatsProvider =
    AutoDisposeFutureProvider<TeacherDashboardStats>.internal(
      dashboardStats,
      name: r'dashboardStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardStatsRef = AutoDisposeFutureProviderRef<TeacherDashboardStats>;
String _$activeRequestsHash() => r'b950529b0aa5c25e0d5e7e9d74d6547fb99d641a';

/// See also [activeRequests].
@ProviderFor(activeRequests)
final activeRequestsProvider =
    AutoDisposeFutureProvider<List<ActiveRequest>>.internal(
      activeRequests,
      name: r'activeRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveRequestsRef = AutoDisposeFutureProviderRef<List<ActiveRequest>>;
String _$studentsByStatusHash() => r'a5d742c7522775b7fd4ef35ce8599c0af2517eae';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [studentsByStatus].
@ProviderFor(studentsByStatus)
const studentsByStatusProvider = StudentsByStatusFamily();

/// See also [studentsByStatus].
class StudentsByStatusFamily extends Family<AsyncValue<List<Student>>> {
  /// See also [studentsByStatus].
  const StudentsByStatusFamily();

  /// See also [studentsByStatus].
  StudentsByStatusProvider call(String statusType) {
    return StudentsByStatusProvider(statusType);
  }

  @override
  StudentsByStatusProvider getProviderOverride(
    covariant StudentsByStatusProvider provider,
  ) {
    return call(provider.statusType);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentsByStatusProvider';
}

/// See also [studentsByStatus].
class StudentsByStatusProvider
    extends AutoDisposeFutureProvider<List<Student>> {
  /// See also [studentsByStatus].
  StudentsByStatusProvider(String statusType)
    : this._internal(
        (ref) => studentsByStatus(ref as StudentsByStatusRef, statusType),
        from: studentsByStatusProvider,
        name: r'studentsByStatusProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentsByStatusHash,
        dependencies: StudentsByStatusFamily._dependencies,
        allTransitiveDependencies:
            StudentsByStatusFamily._allTransitiveDependencies,
        statusType: statusType,
      );

  StudentsByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.statusType,
  }) : super.internal();

  final String statusType;

  @override
  Override overrideWith(
    FutureOr<List<Student>> Function(StudentsByStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentsByStatusProvider._internal(
        (ref) => create(ref as StudentsByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        statusType: statusType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Student>> createElement() {
    return _StudentsByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentsByStatusProvider && other.statusType == statusType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, statusType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentsByStatusRef on AutoDisposeFutureProviderRef<List<Student>> {
  /// The parameter `statusType` of this provider.
  String get statusType;
}

class _StudentsByStatusProviderElement
    extends AutoDisposeFutureProviderElement<List<Student>>
    with StudentsByStatusRef {
  _StudentsByStatusProviderElement(super.provider);

  @override
  String get statusType => (origin as StudentsByStatusProvider).statusType;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
