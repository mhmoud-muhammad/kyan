// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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
String _$dashboardStatsHash() => r'1cfded847f599d571b9f046985a3867ba37e8f76';

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
String _$activeRequestsHash() => r'4224accba768148ec3cbaca3909ddfd3c43aeabe';

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
String _$studentsByStatusHash() => r'c1f0ba1d584343ae72c887905ab9b7f36dbe44fa';

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

String _$webSocketListenerHash() => r'6d2580831975024f8deb8dcd495924e0da77809e';

/// See also [webSocketListener].
@ProviderFor(webSocketListener)
final webSocketListenerProvider = AutoDisposeProvider<void>.internal(
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
typedef WebSocketListenerRef = AutoDisposeProviderRef<void>;
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
    r'16f0d36792f78c22e95864209a620d056e15220a';

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
String _$webSocketStudentsHash() => r'629e700fd1eec17be050a1adfeeb1cd423dce9c4';

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
