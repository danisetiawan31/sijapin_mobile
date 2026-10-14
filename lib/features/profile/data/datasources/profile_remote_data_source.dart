import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/json_first.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/family_member.dart';
import '../../domain/entities/user_profile.dart';

/// Kontrak sumber data remote profil pasien dan anggota keluarga SIMRS
abstract class IProfileRemoteDataSource {
  /// Mengambil profil akun pengguna/customer yang sedang login dari backend CI3 (m_customer)
  Future<UserProfile?> fetchProfile();

  /// Menyimpan anggota keluarga baru atau memperbarui data anggota yang sudah ada
  Future<Map<String, dynamic>> saveFamilyMember(
    FamilyMember member, {
    bool isUpdate = false,
  });

  /// Memperbarui informasi akun induk pasien di database RS
  Future<Map<String, dynamic>> updateProfile({
    required String customerId,
    required String fullName,
    required String phoneNumber,
    required String email,
    DateTime? birthDate,
    String? gender,
    String? password,
  });

  /// Mengambil daftar anggota keluarga dari tampilan backend CI3
  Future<List<FamilyMember>?> fetchFamilyMembers();

  /// Detail satu anggota keluarga (`GET /pasien/form_data/{id}`, JSON).
  Future<FamilyMember?> fetchMemberDetails(String id);
}

/// Implementasi pemanggilan HTTP API CodeIgniter 3 untuk profil dan anggota keluarga
class ProfileRemoteDataSource implements IProfileRemoteDataSource {
  final DioClient dioClient;

  /// Klien REST v2 opsional untuk BACA profil (`GET /api/v1/profile`,
  /// Bearer). TULIS (`simpan_akun_pr`, `input_pasien`) selalu cookie-only
  /// via [dioClient] — server menolak Bearer di sana (401).
  final ApiClient? apiClient;

  ProfileRemoteDataSource({required this.dioClient, this.apiClient});

  /// Memetakan peta profil backend ke [UserProfile].
  /// Bentuk nyata dari sumber (bukan karangan):
  /// - `GET /api/v1/profile` → `{id_customer(int), nama, nomor_telepon,
  ///   email, tanggal_lahir: "DD-MM-YYYY", jenis_kelamin, alamat}`.
  /// - `GET /Profile` JSON → sama, bersarang di kunci `profil`
  ///   (`profile_normalize_row` backend) + komponen `tgl/bln/thn_lahir`.
  /// Defensif (`id_customer` bisa int, field boleh null/kosong) dan jujur:
  /// nilai kosong tetap kosong (jangan diisi nama samaran). Null hanya bila
  /// nama DAN telepon sama-sama kosong (payload hampa, bukan profil).
  static UserProfile? userFromRestMap(Map<String, dynamic> map) {
    final Object? nested = map['profil'];
    final Map<String, dynamic> row = nested is Map<String, dynamic>
        ? nested
        : map;
    final String fullName =
        (row['nama'] ?? row['nama_customer'] ?? '')?.toString().trim() ?? '';
    final String phone =
        (row['nomor_telepon'] ?? row['no_telepon'] ?? row['no_contact'] ?? '')
            ?.toString()
            .trim() ??
        '';
    if (fullName.isEmpty && phone.isEmpty) return null;
    DateTime? birthDate = DateFormatter.parseTanggalLahir(
      row['tanggal_lahir'] ?? row['tgl_lahir'] ?? row['birth_date'],
    );
    birthDate ??= _birthFromComponents(
      row['tgl_lahir'],
      row['bln_lahir'],
      row['thn_lahir'],
    );
    final String gender =
        (row['jenis_kelamin'] ?? row['jns_kelamin'] ?? 'L')
            ?.toString()
            .trim() ??
        'L';
    return UserProfile(
      customerId: row['id_customer']?.toString() ?? '',
      fullName: fullName,
      phone: phone,
      email: row['email']?.toString() ?? '',
      birthDate: birthDate,
      gender: gender.isEmpty ? 'L' : gender,
      address: row['alamat']?.toString() ?? '',
    );
  }

  /// Merakit tanggal dari komponen hari/bulan/tahun terpisah (varian
  /// `profile_normalize_row`: `tgl/bln/thn_lahir` bisa "3"/"03").
  static DateTime? _birthFromComponents(
    Object? day,
    Object? month,
    Object? year,
  ) {
    final String d = (day ?? '').toString().trim();
    final String m = (month ?? '').toString().trim();
    final String y = (year ?? '').toString().trim();
    if (d.isEmpty || m.isEmpty || y.isEmpty) return null;
    return DateFormatter.parseTanggalLahir(
      '${d.padLeft(2, '0')}-${m.padLeft(2, '0')}-${y.padLeft(4, '0')}',
    );
  }

  @override
  Future<UserProfile?> fetchProfile() async {
    // Tahap 1 — REST-primary: `GET /api/v1/profile` (Bearer via ApiClient).
    // Tahap 2 — CI3 cookie: `GET /Profile` + Accept JSON (dibaca di bawah).
    // Kedua tahap memakai kredensial BERBEDA (Bearer vs cookie sesi), maka
    // 401/gagal definitif tahap 1 TIDAK boleh memveto tahap 2: sesi login
    // CI3 (`Login/cek_login`) tidak punya token Bearer, dan sebaliknya.
    // Hanya galat transport yang diteruskan sebagai fallback; null final
    // berarti tidak ada kredensial yang menghasilkan profil.
    final ApiClient? api = apiClient;
    if (api != null) {
      try {
        final Response<dynamic> rest = await api.get<dynamic>(
          ApiConstants.apiV1Profile,
        );
        final Map<String, dynamic>? map = parseJsonMap(rest.data);
        final Object? payload = map == null
            ? null
            : (isEnvelopeMap(map) ? unwrapEnvelopeData(map) : map);
        if (payload is Map<String, dynamic>) {
          final UserProfile? user = userFromRestMap(payload);
          if (user != null) return user;
        }
      } on ApiException {
        // Definitive tahap Bearer (401/revoked/success:false): lanjut ke
        // tahap CI3 cookie di bawah, jangan return null.
      } on DioException {
        // Baik definitif (401) maupun transport: lanjut ke tahap CI3
        // cookie di bawah, yang memakai kredensial berbeda.
      } catch (_) {
        // Galat tak dikenal → coba CI3 di bawah.
      }
    }
    // Tahap 2 — CI3 cookie: `GET /Profile` JSON murni (nol HTML).
    final response = await dioClient.get<dynamic>(
      'profile',
      options: jsonAcceptOptions(),
    );
    final Map<String, dynamic>? map = parseJsonMap(response.data);
    if (map == null) return null;
    final Object? payload = isEnvelopeMap(map) ? unwrapEnvelopeData(map) : map;
    if (payload is Map<String, dynamic>) return userFromRestMap(payload);
    return null;
  }

  @override
  Future<Map<String, dynamic>> saveFamilyMember(
    FamilyMember member, {
    bool isUpdate = false,
  }) async {
    final birthDate = member.birthDate;
    final formData = FormData.fromMap({
      'id_member': isUpdate ? member.id : '',
      'rd_nomr': member.resolvedRdNomr,
      'nomr': member.medicalRecordNumber ?? '',
      'nama_pasien': member.fullName,
      'tmp_lahir': member.birthPlace,
      'tgl_lahir': birthDate != null
          ? birthDate.day.toString().padLeft(2, '0')
          : '',
      'bln_lahir': birthDate != null
          ? birthDate.month.toString().padLeft(2, '0')
          : '',
      'thn_lahir': birthDate != null ? birthDate.year.toString() : '',
      'agama': member.religion.isNotEmpty ? member.religion : '1',
      'jns_kelamin': member.gender,
      'nama_ibu': member.motherName,
      'nik': member.nik,
      'alamat': member.address,
      'no_kontak': member.phone,
      'email': '',
      'pekerjaan': member.occupation,
    });

    final response = await dioClient.post<dynamic>(
      ApiConstants.inputPasien,
      data: formData,
      options: jsonAcceptOptions(),
    );

    final Map<String, dynamic>? map = parseJsonMap(response.data);
    if (map != null) {
      throwIfDefinitiveFailure(map);
      return normalizeWriteResult(map);
    }
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return <String, dynamic>{
      'ret': 'fail',
      'msg': 'Format respons server SIMRS tidak valid.',
    };
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String customerId,
    required String fullName,
    required String phoneNumber,
    required String email,
    DateTime? birthDate,
    String? gender,
    String? password,
  }) async {
    // Backend membaca $_POST: REST maupun CI3 wajib FormData (bukan JSON).
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'id_customer': customerId,
      'nomor_telepon': phoneNumber,
      'nama': fullName,
      'tgl_lahir': birthDate != null
          ? birthDate.day.toString().padLeft(2, '0')
          : '',
      'bln_lahir': birthDate != null
          ? birthDate.month.toString().padLeft(2, '0')
          : '',
      'thn_lahir': birthDate != null ? birthDate.year.toString() : '',
      'jns_kelamin': gender ?? 'L',
      'email': email,
      'kunci': password ?? '',
      'kunci_conf': password ?? '',
    });

    // Endpoint TULIS cookie-only: `simpan_akun_pr` memeriksa
    // `ses_siijapin_login` sesi (Bearer SELALU 401 → akan memicu wipe
    // sesi terpusat!). Maka JANGAN lewat ApiClient — hanya DioClient
    // (cookie ditanam saat login). Backend menjawab envelope JSON bila
    // Accept JSON (cabang `is_explicit_json`), else `{ret,msg}`.
    final response = await dioClient.post<dynamic>(
      ApiConstants.updateProfile,
      data: formData,
      options: jsonAcceptOptions(),
    );

    final Map<String, dynamic>? map = parseJsonMap(response.data);
    if (map != null) {
      throwIfDefinitiveFailure(map);
      return normalizeWriteResult(map);
    }
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return <String, dynamic>{
      'ret': 'fail',
      'msg': 'Format respons server SIMRS tidak valid.',
    };
  }

  /// Detail satu anggota (`GET /Pasien/form_data/{id}`, JSON murni):
  /// envelope `data: {is_edit, id_member, member: {...}}`
  /// (`pasien_normalize_row` backend, kunci lowercase).
  @override
  Future<FamilyMember?> fetchMemberDetails(String id) async {
    final response = await dioClient.get<dynamic>(
      '${ApiConstants.formPasien}/$id',
      options: jsonAcceptOptions(),
    );
    final Map<String, dynamic>? map = parseJsonMap(response.data);
    if (map == null) return null;
    final Object? payload = isEnvelopeMap(map)
        ? unwrapEnvelopeData(map)
        : map['data'] ?? map;
    final Object? row = payload is Map<String, dynamic>
        ? (payload['member'] ?? payload)
        : null;
    if (row is! Map<String, dynamic>) return null;
    return _memberFromRow(row, fallbackId: id);
  }

  @override
  Future<List<FamilyMember>?> fetchFamilyMembers() async {
    // Tahap 1 — Endpoint resmi Manajemen Anggota Keluarga: `GET /pasien`
    // (Postman folder 03 & Controller Pasien.php: data: {anggota: [...]}).
    try {
      final response = await dioClient.get<dynamic>(
        ApiConstants.listPasien,
        options: jsonAcceptOptions(),
      );
      final Map<String, dynamic>? map = parseJsonMap(response.data);
      if (map != null) {
        final Object? payload = isEnvelopeMap(map)
            ? unwrapEnvelopeData(map)
            : map['data'] ?? map;
        final list = _membersFromJson(payload);
        if (list != null) return list;
      }
    } catch (_) {}

    // Tahap 2 — Fallback ke `GET /Daftar_Kunj_Raja` (data: {member: [...]})
    try {
      final response = await dioClient.get<dynamic>(
        ApiConstants.bookingFamilyList,
        options: jsonAcceptOptions(),
      );
      final Map<String, dynamic>? map = parseJsonMap(response.data);
      if (map == null) return null;
      final Object? payload = isEnvelopeMap(map)
          ? unwrapEnvelopeData(map)
          : map['data'] ?? map;
      return _membersFromJson(payload);
    } catch (_) {
      return null;
    }
  }

  List<FamilyMember>? _membersFromJson(Object? payload) {
    final Map<String, dynamic> root = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};
    final Object? wrapped = root['anggota'] ?? root['member'];
    final List<Object?> raw = <Object?>[
      if (wrapped is List) ...wrapped,
      if (payload is List) ...payload,
    ];
    if (raw.isEmpty) return const [];
    final List<FamilyMember> members = [];
    for (final Object? item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final FamilyMember? member = _memberFromRow(item);
      if (member != null) members.add(member);
    }
    return members;
  }

  /// Baris anggota → [FamilyMember]. Kunci UPPERCASE dulu (daftar
  /// `get_member`), lalu lowercase (`pasien_normalize_row`): backend
  /// memakai keduanya di endpoint berbeda. Nilai kosong tetap kosong.
  static FamilyMember? _memberFromRow(
    Map<String, dynamic> row, {
    String fallbackId = '',
  }) {
    String pick(List<String> keys) {
      for (final String key in keys) {
        final Object? value = row[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return '';
    }

    final String id = pick(const <String>[
      'MEMBER_ID',
      'member_id',
      'id_member',
      'id',
      'ID_MEMBER',
    ]);
    final String name = pick(const <String>[
      'NAMA_PASIEN',
      'nama_pasien',
      'nama',
      'NAMA',
    ]);
    if ((id.isEmpty && fallbackId.isEmpty) || name.isEmpty) return null;
    DateTime? birthDate = DateFormatter.parseTanggalLahir(
      row['TGL_LAHIR'] ??
          row['tanggal_lahir'] ??
          row['tgl_lahir'] ??
          row['birth_date'],
    );
    birthDate ??= DateFormatter.parseTanggalLahir(
      _composeBirth(
        row['TGL_LAHIR_1'] ?? row['tgl_lahir'],
        row['TGL_LAHIR_2'] ?? row['bln_lahir'],
        row['TGL_LAHIR_3'] ?? row['thn_lahir'],
      ),
    );
    final String nomr = pick(const <String>['NOMR', 'nomr', 'no_rm', 'NO_RM']);
    final String rdNomr = pick(const <String>['RD_NOMR', 'rd_nomr']);
    return FamilyMember(
      id: id.isNotEmpty ? id : fallbackId,
      fullName: name,
      relation: FamilyRelation.child,
      gender: _orDefault(
        pick(const <String>[
          'JNS_KELAMIN',
          'jns_kelamin',
          'jenis_kelamin',
          'JENIS_KELAMIN',
        ]),
        'L',
      ),
      nik: pick(const <String>['NIK', 'nik']),
      insurance: FamilyInsurance.umum,
      birthDate: birthDate,
      medicalRecordNumber: nomr.isNotEmpty ? nomr : null,
      birthPlace: pick(const <String>[
        'TMP_LAHIR',
        'tmp_lahir',
        'tempat_lahir',
        'TEMPAT_LAHIR',
      ]),
      motherName: pick(const <String>['NAMA_IBU', 'nama_ibu']),
      address: pick(const <String>['ALAMAT', 'alamat']),
      religion: _orDefault(pick(const <String>['AGAMA', 'agama']), '1'),
      occupation: pick(const <String>['PEKERJAAN', 'pekerjaan', 'occupation']),
      rdNomr: rdNomr,
      phone: pick(const <String>[
        'NO_KONTAK',
        'no_kontak',
        'nomor_telepon',
        'NOMOR_TELEPON',
        'no_contact',
      ]),
    );
  }

  /// Nilai [value] bila tak kosong, jika kosong memakai [fallback] (default
  /// backend `gender 'L'` / `agama '1'` tetap dipertahankan agar kontrak lama utuh).
  static String _orDefault(String value, String fallback) =>
      value.isEmpty ? fallback : value;

  static String? _composeBirth(Object? day, Object? month, Object? year) {
    final String d = (day ?? '').toString().trim();
    final String m = (month ?? '').toString().trim();
    final String y = (year ?? '').toString().trim();
    if (d.isEmpty || m.isEmpty || y.isEmpty) return null;
    return '${d.padLeft(2, '0')}-${m.padLeft(2, '0')}-${y.padLeft(4, '0')}';
  }
}
