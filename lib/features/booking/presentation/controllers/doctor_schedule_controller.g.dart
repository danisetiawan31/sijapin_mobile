// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_schedule_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider repository jadwal dokter

@ProviderFor(doctorScheduleRepository)
final doctorScheduleRepositoryProvider = DoctorScheduleRepositoryProvider._();

/// Provider repository jadwal dokter

final class DoctorScheduleRepositoryProvider
    extends
        $FunctionalProvider<
          DoctorScheduleRepository,
          DoctorScheduleRepository,
          DoctorScheduleRepository
        >
    with $Provider<DoctorScheduleRepository> {
  /// Provider repository jadwal dokter
  DoctorScheduleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'doctorScheduleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$doctorScheduleRepositoryHash();

  @$internal
  @override
  $ProviderElement<DoctorScheduleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DoctorScheduleRepository create(Ref ref) {
    return doctorScheduleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DoctorScheduleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DoctorScheduleRepository>(value),
    );
  }
}

String _$doctorScheduleRepositoryHash() =>
    r'1629f99cccc4db591e013b166a8c8c4438a87907';

/// Provider daftar jadwal dokter dengan filter & pencarian

@ProviderFor(DoctorScheduleList)
final doctorScheduleListProvider = DoctorScheduleListProvider._();

/// Provider daftar jadwal dokter dengan filter & pencarian
final class DoctorScheduleListProvider
    extends $AsyncNotifierProvider<DoctorScheduleList, List<DoctorSchedule>> {
  /// Provider daftar jadwal dokter dengan filter & pencarian
  DoctorScheduleListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'doctorScheduleListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$doctorScheduleListHash();

  @$internal
  @override
  DoctorScheduleList create() => DoctorScheduleList();
}

String _$doctorScheduleListHash() =>
    r'aeef2e75c28b0d65fafd2c14c74bd26ddcbbec92';

/// Provider daftar jadwal dokter dengan filter & pencarian

abstract class _$DoctorScheduleList
    extends $AsyncNotifier<List<DoctorSchedule>> {
  FutureOr<List<DoctorSchedule>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<DoctorSchedule>>, List<DoctorSchedule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<DoctorSchedule>>,
                List<DoctorSchedule>
              >,
              AsyncValue<List<DoctorSchedule>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
