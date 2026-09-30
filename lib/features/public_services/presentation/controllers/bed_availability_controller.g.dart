// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bed_availability_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider repository ketersediaan kamar

@ProviderFor(bedAvailabilityRepository)
final bedAvailabilityRepositoryProvider = BedAvailabilityRepositoryProvider._();

/// Provider repository ketersediaan kamar

final class BedAvailabilityRepositoryProvider
    extends
        $FunctionalProvider<
          BedAvailabilityRepository,
          BedAvailabilityRepository,
          BedAvailabilityRepository
        >
    with $Provider<BedAvailabilityRepository> {
  /// Provider repository ketersediaan kamar
  BedAvailabilityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bedAvailabilityRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bedAvailabilityRepositoryHash();

  @$internal
  @override
  $ProviderElement<BedAvailabilityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BedAvailabilityRepository create(Ref ref) {
    return bedAvailabilityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BedAvailabilityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BedAvailabilityRepository>(value),
    );
  }
}

String _$bedAvailabilityRepositoryHash() =>
    r'b4d2ca09cc16eec535a6a745dddbe1a37f425535';

/// Provider ringkasan ketersediaan kamar dengan filter kelas

@ProviderFor(BedAvailabilityList)
final bedAvailabilityListProvider = BedAvailabilityListProvider._();

/// Provider ringkasan ketersediaan kamar dengan filter kelas
final class BedAvailabilityListProvider
    extends $NotifierProvider<BedAvailabilityList, BedAvailabilityState> {
  /// Provider ringkasan ketersediaan kamar dengan filter kelas
  BedAvailabilityListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bedAvailabilityListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bedAvailabilityListHash();

  @$internal
  @override
  BedAvailabilityList create() => BedAvailabilityList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BedAvailabilityState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BedAvailabilityState>(value),
    );
  }
}

String _$bedAvailabilityListHash() =>
    r'63c68e120066aeebb2986a76c847e2f56d37aa8d';

/// Provider ringkasan ketersediaan kamar dengan filter kelas

abstract class _$BedAvailabilityList extends $Notifier<BedAvailabilityState> {
  BedAvailabilityState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BedAvailabilityState, BedAvailabilityState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BedAvailabilityState, BedAvailabilityState>,
              BedAvailabilityState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
