// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guardian_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$guardianRemoteDataSourceHash() =>
    r'01b1c152dca5207d0f6d15a49eebfcca7610050e';

/// See also [guardianRemoteDataSource].
@ProviderFor(guardianRemoteDataSource)
final guardianRemoteDataSourceProvider =
    AutoDisposeProvider<GuardianRemoteDataSource>.internal(
      guardianRemoteDataSource,
      name: r'guardianRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$guardianRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GuardianRemoteDataSourceRef =
    AutoDisposeProviderRef<GuardianRemoteDataSource>;
String _$createPickupRequestUseCaseHash() =>
    r'2720d0dbbfe642769f7c4e2d27f166d596facfbe';

/// See also [createPickupRequestUseCase].
@ProviderFor(createPickupRequestUseCase)
final createPickupRequestUseCaseProvider =
    AutoDisposeProvider<CreatePickupRequestUseCase>.internal(
      createPickupRequestUseCase,
      name: r'createPickupRequestUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createPickupRequestUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreatePickupRequestUseCaseRef =
    AutoDisposeProviderRef<CreatePickupRequestUseCase>;
String _$locationServiceHash() => r'f7b3dbe3e362693a99dbd0c857f576f80a3f5f74';

/// See also [locationService].
@ProviderFor(locationService)
final locationServiceProvider = AutoDisposeProvider<LocationService>.internal(
  locationService,
  name: r'locationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationServiceRef = AutoDisposeProviderRef<LocationService>;
String _$guardianRepositoryHash() =>
    r'28e2f09ef71c719cbbe64a97e93d94fd05d42998';

/// See also [guardianRepository].
@ProviderFor(guardianRepository)
final guardianRepositoryProvider =
    AutoDisposeProvider<GuardianRepository>.internal(
      guardianRepository,
      name: r'guardianRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$guardianRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GuardianRepositoryRef = AutoDisposeProviderRef<GuardianRepository>;
String _$getMySchoolsUseCaseHash() =>
    r'7f91714859ecec05cb7d680b30009c7081ff58ad';

/// See also [getMySchoolsUseCase].
@ProviderFor(getMySchoolsUseCase)
final getMySchoolsUseCaseProvider =
    AutoDisposeProvider<GetMySchoolsUseCase>.internal(
      getMySchoolsUseCase,
      name: r'getMySchoolsUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getMySchoolsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetMySchoolsUseCaseRef = AutoDisposeProviderRef<GetMySchoolsUseCase>;
String _$getStudentsBySchoolUseCaseHash() =>
    r'217f58e39ed7c691c04ea50216057f2e56dc6bbc';

/// See also [getStudentsBySchoolUseCase].
@ProviderFor(getStudentsBySchoolUseCase)
final getStudentsBySchoolUseCaseProvider =
    AutoDisposeProvider<GetStudentsBySchoolUseCase>.internal(
      getStudentsBySchoolUseCase,
      name: r'getStudentsBySchoolUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getStudentsBySchoolUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetStudentsBySchoolUseCaseRef =
    AutoDisposeProviderRef<GetStudentsBySchoolUseCase>;
String _$mySchoolsHash() => r'05f5c3e98d524f7af29891cc50c6c8d326a163bd';

/// See also [mySchools].
@ProviderFor(mySchools)
final mySchoolsProvider = AutoDisposeFutureProvider<List<School>>.internal(
  mySchools,
  name: r'mySchoolsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mySchoolsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MySchoolsRef = AutoDisposeFutureProviderRef<List<School>>;
String _$studentsBySchoolHash() => r'ae40b7b1469f21f645a4254e2fadc4f7fb080521';

/// See also [studentsBySchool].
@ProviderFor(studentsBySchool)
final studentsBySchoolProvider =
    AutoDisposeFutureProvider<List<Student>>.internal(
      studentsBySchool,
      name: r'studentsBySchoolProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentsBySchoolHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentsBySchoolRef = AutoDisposeFutureProviderRef<List<Student>>;
String _$pickupRequestForStudentHash() =>
    r'1bfd61ee0256e0c75cfa893147b8704b58e687c0';

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

abstract class _$PickupRequestForStudent
    extends BuildlessAutoDisposeNotifier<AsyncValue<void>> {
  late final int studentId;

  AsyncValue<void> build(int studentId);
}

/// See also [PickupRequestForStudent].
@ProviderFor(PickupRequestForStudent)
const pickupRequestForStudentProvider = PickupRequestForStudentFamily();

/// See also [PickupRequestForStudent].
class PickupRequestForStudentFamily extends Family<AsyncValue<void>> {
  /// See also [PickupRequestForStudent].
  const PickupRequestForStudentFamily();

  /// See also [PickupRequestForStudent].
  PickupRequestForStudentProvider call(int studentId) {
    return PickupRequestForStudentProvider(studentId);
  }

  @override
  PickupRequestForStudentProvider getProviderOverride(
    covariant PickupRequestForStudentProvider provider,
  ) {
    return call(provider.studentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pickupRequestForStudentProvider';
}

/// See also [PickupRequestForStudent].
class PickupRequestForStudentProvider
    extends
        AutoDisposeNotifierProviderImpl<
          PickupRequestForStudent,
          AsyncValue<void>
        > {
  /// See also [PickupRequestForStudent].
  PickupRequestForStudentProvider(int studentId)
    : this._internal(
        () => PickupRequestForStudent()..studentId = studentId,
        from: pickupRequestForStudentProvider,
        name: r'pickupRequestForStudentProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pickupRequestForStudentHash,
        dependencies: PickupRequestForStudentFamily._dependencies,
        allTransitiveDependencies:
            PickupRequestForStudentFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  PickupRequestForStudentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
  }) : super.internal();

  final int studentId;

  @override
  AsyncValue<void> runNotifierBuild(
    covariant PickupRequestForStudent notifier,
  ) {
    return notifier.build(studentId);
  }

  @override
  Override overrideWith(PickupRequestForStudent Function() create) {
    return ProviderOverride(
      origin: this,
      override: PickupRequestForStudentProvider._internal(
        () => create()..studentId = studentId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<PickupRequestForStudent, AsyncValue<void>>
  createElement() {
    return _PickupRequestForStudentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PickupRequestForStudentProvider &&
        other.studentId == studentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PickupRequestForStudentRef
    on AutoDisposeNotifierProviderRef<AsyncValue<void>> {
  /// The parameter `studentId` of this provider.
  int get studentId;
}

class _PickupRequestForStudentProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          PickupRequestForStudent,
          AsyncValue<void>
        >
    with PickupRequestForStudentRef {
  _PickupRequestForStudentProviderElement(super.provider);

  @override
  int get studentId => (origin as PickupRequestForStudentProvider).studentId;
}

String _$pickupRequestHash() => r'f3fd042cafd5c8e672af0ebad17c3e3e2f8fa000';

/// See also [PickupRequest].
@ProviderFor(PickupRequest)
final pickupRequestProvider =
    AutoDisposeNotifierProvider<PickupRequest, AsyncValue<void>>.internal(
      PickupRequest.new,
      name: r'pickupRequestProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pickupRequestHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PickupRequest = AutoDisposeNotifier<AsyncValue<void>>;
String _$selectedSchoolHash() => r'4ed907ef899132b5a219607e090315332ac5e84d';

/// See also [SelectedSchool].
@ProviderFor(SelectedSchool)
final selectedSchoolProvider =
    AutoDisposeNotifierProvider<SelectedSchool, School?>.internal(
      SelectedSchool.new,
      name: r'selectedSchoolProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedSchoolHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedSchool = AutoDisposeNotifier<School?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
