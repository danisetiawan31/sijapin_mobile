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

/// Provider spesialisasi/poli yang sedang dipilih

@ProviderFor(SelectedDoctorSpecialty)
final selectedDoctorSpecialtyProvider = SelectedDoctorSpecialtyProvider._();

/// Provider spesialisasi/poli yang sedang dipilih
final class SelectedDoctorSpecialtyProvider
    extends $NotifierProvider<SelectedDoctorSpecialty, String> {
  /// Provider spesialisasi/poli yang sedang dipilih
  SelectedDoctorSpecialtyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDoctorSpecialtyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDoctorSpecialtyHash();

  @$internal
  @override
  SelectedDoctorSpecialty create() => SelectedDoctorSpecialty();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedDoctorSpecialtyHash() =>
    r'0d6526d1dce1466650fefb518909e5c6f09e1980';

/// Provider spesialisasi/poli yang sedang dipilih

abstract class _$SelectedDoctorSpecialty extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider teks pencarian jadwal dokter

@ProviderFor(DoctorSearchQuery)
final doctorSearchQueryProvider = DoctorSearchQueryProvider._();

/// Provider teks pencarian jadwal dokter
final class DoctorSearchQueryProvider
    extends $NotifierProvider<DoctorSearchQuery, String> {
  /// Provider teks pencarian jadwal dokter
  DoctorSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'doctorSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$doctorSearchQueryHash();

  @$internal
  @override
  DoctorSearchQuery create() => DoctorSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$doctorSearchQueryHash() => r'09b963420127aff2c9384fcc005ffc80439b159b';

/// Provider teks pencarian jadwal dokter

abstract class _$DoctorSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider daftar jadwal dokter dengan filter & pencarian terpadu

@ProviderFor(DoctorScheduleList)
final doctorScheduleListProvider = DoctorScheduleListProvider._();

/// Provider daftar jadwal dokter dengan filter & pencarian terpadu
final class DoctorScheduleListProvider
    extends $AsyncNotifierProvider<DoctorScheduleList, List<DoctorSchedule>> {
  /// Provider daftar jadwal dokter dengan filter & pencarian terpadu
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
    r'f6e9e37ce626df3f647f5844a096bed1b3e172a2';

/// Provider daftar jadwal dokter dengan filter & pencarian terpadu

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
