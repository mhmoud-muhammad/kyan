// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wsDerivedActiveRequestsHash() =>
    r'71248244630695437fc025cc3012ada1bae9366a';

/// See also [wsDerivedActiveRequests].
@ProviderFor(wsDerivedActiveRequests)
final wsDerivedActiveRequestsProvider =
    AutoDisposeProvider<List<ActiveRequest>>.internal(
      wsDerivedActiveRequests,
      name: r'wsDerivedActiveRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$wsDerivedActiveRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WsDerivedActiveRequestsRef =
    AutoDisposeProviderRef<List<ActiveRequest>>;
String _$unifiedActiveRequestsHash() =>
    r'3162f6a2126f502a07fc80fa80e164d2e11dddb8';

/// See also [unifiedActiveRequests].
@ProviderFor(unifiedActiveRequests)
final unifiedActiveRequestsProvider =
    AutoDisposeProvider<AsyncValue<List<ActiveRequest>>>.internal(
      unifiedActiveRequests,
      name: r'unifiedActiveRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unifiedActiveRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedActiveRequestsRef =
    AutoDisposeProviderRef<AsyncValue<List<ActiveRequest>>>;
String _$teacherRemoteDataSourceHash() =>
    r'03a39e0fcaaef1d2740407cbdf177ef139ed9cc7';

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
String _$dashboardStatsHash() => r'46845d880f90868b06d55978e2c15fc907494823';

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
String _$wsDashboardStatsHash() => r'f39d242e85a2ff79a2bb297a5b536abd333db07d';

/// See also [wsDashboardStats].
@ProviderFor(wsDashboardStats)
final wsDashboardStatsProvider =
    AutoDisposeProvider<TeacherDashboardStats>.internal(
      wsDashboardStats,
      name: r'wsDashboardStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$wsDashboardStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WsDashboardStatsRef = AutoDisposeProviderRef<TeacherDashboardStats>;
String _$activeRequestsHash() => r'ab560613fa030c660944ec65ded30d271adeb1ac';

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
String _$studentsByStatusHash() => r'73d4b16b01d4dc533927bc8a810fbb9e234c9bf9';

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

String _$webSocketListenerHash() => r'7d817888beb456289988c8717cbe19641365e6a6';

/// See also [webSocketListener].
@ProviderFor(webSocketListener)
final webSocketListenerProvider = Provider<void>.internal(
  webSocketListener,
  name: r'webSocketListenerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$webSocketListenerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WebSocketListenerRef = ProviderRef<void>;
String _$webSocketNotificationsHash() =>
    r'168fca983f9d87959b88915978e172a30ff18054';

/// See also [WebSocketNotifications].
@ProviderFor(WebSocketNotifications)
final webSocketNotificationsProvider =
    AutoDisposeNotifierProvider<
      WebSocketNotifications,
      List<Map<String, dynamic>>
    >.internal(
      WebSocketNotifications.new,
      name: r'webSocketNotificationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$webSocketNotificationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WebSocketNotifications =
    AutoDisposeNotifier<List<Map<String, dynamic>>>;
String _$webSocketActiveRequestsHash() =>
    r'88423cb0dd6ae9286a6e71f73b37dc5da8b70f44';

/// See also [WebSocketActiveRequests].
@ProviderFor(WebSocketActiveRequests)
final webSocketActiveRequestsProvider =
    AutoDisposeNotifierProvider<
      WebSocketActiveRequests,
      List<ActiveRequest>
    >.internal(
      WebSocketActiveRequests.new,
      name: r'webSocketActiveRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$webSocketActiveRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WebSocketActiveRequests = AutoDisposeNotifier<List<ActiveRequest>>;
String _$webSocketStudentsHash() => r'7b7eb2e6efd40dc02c75409459afb883d2a45892';

/// See also [WebSocketStudents].
@ProviderFor(WebSocketStudents)
final webSocketStudentsProvider =
    AutoDisposeNotifierProvider<
      WebSocketStudents,
      Map<String, List<Student>>
    >.internal(
      WebSocketStudents.new,
      name: r'webSocketStudentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$webSocketStudentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WebSocketStudents = AutoDisposeNotifier<Map<String, List<Student>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
