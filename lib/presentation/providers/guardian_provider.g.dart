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
String _$studentsBySchoolHash() => r'122295c0b8b63c05bb42fd4de49054fdf86ba803';

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
String _$pickupRequestHash() => r'328fca09cba1cc194c9e50019df00d5aa0dfa681';

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
