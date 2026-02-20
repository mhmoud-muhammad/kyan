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
String _$mySchoolsHash() => r'af352b225e33baea8b9f327af05a0be0f75cdc65';

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
String _$studentsBySchoolHash() => r'd0f03d40e864074d3552c6137aced82fafc4ab75';

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
    r'6b7303fdd63ca66e9e2c5ed6376c9d770af7ca5f';

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
  late final String studentId;

  AsyncValue<void> build(String studentId);
}

/// See also [PickupRequestForStudent].
@ProviderFor(PickupRequestForStudent)
const pickupRequestForStudentProvider = PickupRequestForStudentFamily();

/// See also [PickupRequestForStudent].
class PickupRequestForStudentFamily extends Family<AsyncValue<void>> {
  /// See also [PickupRequestForStudent].
  const PickupRequestForStudentFamily();

  /// See also [PickupRequestForStudent].
  PickupRequestForStudentProvider call(String studentId) {
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
  PickupRequestForStudentProvider(String studentId)
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

  final String studentId;

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
  String get studentId;
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
  String get studentId => (origin as PickupRequestForStudentProvider).studentId;
}

String _$pickupRequestHash() => r'd71488f183fa0391011dcba75799c54645d65a70';

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
