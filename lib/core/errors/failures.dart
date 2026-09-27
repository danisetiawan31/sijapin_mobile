/// Functional Result Pattern menggunakan Dart 3 Sealed Classes
sealed class Result<S, F extends Failure> {
  const Result();

  bool get isSuccess => this is Success<S, F>;
  bool get isError => this is Error<S, F>;

  S? get dataOrNull => switch (this) {
    Success(data: final d) => d,
    Error() => null,
  };

  F? get failureOrNull => switch (this) {
    Success() => null,
    Error(failure: final f) => f,
  };
}

final class Success<S, F extends Failure> extends Result<S, F> {
  final S data;
  const Success(this.data);
}

final class Error<S, F extends Failure> extends Result<S, F> {
  final F failure;
  const Error(this.failure);
}

/// Abstraksi dasar kegagalan (Failure) sistem
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Kegagalan koneksi fisik / DNS lookup
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Koneksi internet bermasalah. Periksa jaringan Anda.',
  ]);
}

/// Sesi server CodeIgniter 3 kedaluwarsa (> 30 menit)
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([
    super.message =
        'Sesi Anda telah berakhir. Silakan masukkan kata sandi kembali.',
  ]);
}

/// Token anti-CSRF mismatch / expired
class CsrfMismatchFailure extends Failure {
  const CsrfMismatchFailure([
    super.message = 'Validasi keamanan form gagal. Silakan coba lagi.',
  ]);
}

/// Kuota antrean poliklinik telah habis
class QuotaExceededFailure extends Failure {
  const QuotaExceededFailure([
    super.message = 'Kuota antrean poliklinik pada hari tersebut telah penuh.',
  ]);
}

/// Kesalahan validasi form SIMRS
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Gangguan database SIMRS live (HTTP 500/503)
class ServerMaintenanceFailure extends Failure {
  const ServerMaintenanceFailure([
    super.message =
        'Server rumah sakit sedang pemeliharaan. Coba beberapa saat lagi.',
  ]);
}
