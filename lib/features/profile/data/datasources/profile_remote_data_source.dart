import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
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
}

/// Implementasi pemanggilan HTTP API CodeIgniter 3 untuk profil dan anggota keluarga
class ProfileRemoteDataSource implements IProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSource({required this.dioClient});

  @override
  Future<UserProfile?> fetchProfile() async {
    try {
      final response = await dioClient.get<dynamic>('profile');
      final htmlContent = response.data?.toString() ?? '';
      if (htmlContent.isEmpty) return null;

      final document = html_parser.parse(htmlContent);

      final idCustomerEl = document.querySelector('input[name="id_customer"]');
      final customerId = idCustomerEl?.attributes['value']?.trim() ?? '';

      final nameEl = document.querySelector('input[name="nama"]');
      final fullName = nameEl?.attributes['value']?.trim() ?? '';

      final phoneEl = document.querySelector('input[name="nomor_telepon"]');
      final phone = phoneEl?.attributes['value']?.trim() ?? '';

      final emailEl = document.querySelector('input[name="email"]');
      final email = emailEl?.attributes['value']?.trim() ?? '';

      final tglEl = document.querySelector('input[name="tgl_lahir"]');
      final tgl = int.tryParse(tglEl?.attributes['value']?.trim() ?? '');

      final blnEl = document.querySelector(
        'select[name="bln_lahir"] option[selected]',
      );
      final bln = int.tryParse(blnEl?.attributes['value']?.trim() ?? '');

      final thnEl = document.querySelector('input[name="thn_lahir"]');
      final thn = int.tryParse(thnEl?.attributes['value']?.trim() ?? '');

      DateTime? birthDate;
      if (tgl != null && bln != null && thn != null) {
        birthDate = DateTime(thn, bln, tgl);
      }

      final genderEl = document.querySelector(
        'select[name="jns_kelamin"] option[selected]',
      );
      final gender = genderEl?.attributes['value']?.trim() ?? 'L';

      if (fullName.isEmpty && phone.isEmpty) return null;

      return UserProfile(
        customerId: customerId,
        fullName: fullName.isNotEmpty ? fullName : 'Pasien Terdaftar',
        phone: phone,
        email: email,
        birthDate: birthDate,
        gender: gender,
      );
    } catch (_) {
      return null;
    }
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
    );

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
    final formData = FormData.fromMap({
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

    final response = await dioClient.post<dynamic>(
      ApiConstants.updateProfile,
      data: formData,
    );

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return <String, dynamic>{
      'ret': 'fail',
      'msg': 'Format respons server SIMRS tidak valid.',
    };
  }

  Future<FamilyMember?> _fetchMemberDetails(String id) async {
    try {
      final response = await dioClient.get<dynamic>('pasien/form_data/$id');
      final html = response.data?.toString() ?? '';
      if (html.isEmpty) return null;

      final doc = html_parser.parse(html);

      final name =
          doc
              .querySelector('input[name="nama_pasien"]')
              ?.attributes['value']
              ?.trim() ??
          '';
      if (name.isEmpty) return null;

      final tmpLahir =
          doc
              .querySelector('input[name="tmp_lahir"]')
              ?.attributes['value']
              ?.trim() ??
          '';

      final tglStr =
          doc
              .querySelector('input[name="tgl_lahir"]')
              ?.attributes['value']
              ?.trim() ??
          '';
      final blnStr =
          doc
              .querySelector('select[name="bln_lahir"] option[selected]')
              ?.attributes['value']
              ?.trim() ??
          '';
      final thnStr =
          doc
              .querySelector('input[name="thn_lahir"]')
              ?.attributes['value']
              ?.trim() ??
          '';

      DateTime? birthDate;
      final tgl = int.tryParse(tglStr);
      final bln = int.tryParse(blnStr);
      final thn = int.tryParse(thnStr);
      if (tgl != null && bln != null && thn != null) {
        birthDate = DateTime(thn, bln, tgl);
      }

      final gender =
          doc
              .querySelector('select[name="jns_kelamin"] option[selected]')
              ?.attributes['value']
              ?.trim() ??
          'L';
      final religion =
          doc
              .querySelector('select[name="agama"] option[selected]')
              ?.attributes['value']
              ?.trim() ??
          '1';
      final motherName =
          doc
              .querySelector('input[name="nama_ibu"]')
              ?.attributes['value']
              ?.trim() ??
          '';
      final address =
          doc.querySelector('textarea[name="alamat"]')?.text.trim() ?? '';
      final occupation =
          doc
              .querySelector('input[name="pekerjaan"]')
              ?.attributes['value']
              ?.trim() ??
          '';
      final phone =
          doc
              .querySelector('input[name="no_kontak"]')
              ?.attributes['value']
              ?.trim() ??
          '';
      final nik =
          doc.querySelector('input[name="nik"]')?.attributes['value']?.trim() ??
          '';
      final nomr =
          doc
              .querySelector('input[name="nomr"]')
              ?.attributes['value']
              ?.trim() ??
          '';
      final rdNomr =
          doc
              .querySelector('select[name="rd_nomr"] option[selected]')
              ?.attributes['value']
              ?.trim() ??
          doc
              .querySelector('input[name="rd_nomr"]')
              ?.attributes['value']
              ?.trim() ??
          (nomr.isNotEmpty ? '1' : '3');

      return FamilyMember(
        id: id,
        fullName: name,
        relation: FamilyRelation.child,
        gender: gender,
        nik: nik,
        insurance: FamilyInsurance.umum,
        birthDate: birthDate,
        medicalRecordNumber: nomr.isNotEmpty ? nomr : null,
        birthPlace: tmpLahir,
        motherName: motherName,
        address: address,
        religion: religion,
        occupation: occupation,
        rdNomr: rdNomr,
        phone: phone,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FamilyMember>?> fetchFamilyMembers() async {
    try {
      final response = await dioClient.get<dynamic>(ApiConstants.listPasien);
      final htmlContent = response.data?.toString() ?? '';
      if (htmlContent.isEmpty) return null;

      final document = html_parser.parse(htmlContent);
      final memberCards = document.querySelectorAll(
        'a[href*="pasien/form_data"]',
      );
      if (memberCards.isEmpty) return <FamilyMember>[];

      final List<FamilyMember> members = [];
      for (final anchor in memberCards) {
        final href = anchor.attributes['href'] ?? '';
        final idMatch = RegExp(r'pasien/form_data/(\w+)').firstMatch(href);
        final id = idMatch?.group(1) ?? '';
        if (id.isEmpty) continue;

        // Ambil data detail pasien dari form_data
        final detailed = await _fetchMemberDetails(id);
        if (detailed != null) {
          members.add(detailed);
        } else {
          final titleEl =
              anchor.querySelector('.card-title') ??
              anchor.querySelector('h5') ??
              anchor.querySelector('h4') ??
              anchor.querySelector('strong') ??
              anchor.querySelector('b');
          final name = titleEl != null && titleEl.text.trim().isNotEmpty
              ? titleEl.text.trim()
              : (anchor.text.trim().isNotEmpty
                    ? anchor.text.trim()
                    : 'Anggota Keluarga');

          members.add(
            FamilyMember(
              id: id,
              fullName: name,
              relation: FamilyRelation.child,
              nik: '',
              gender: 'L',
              insurance: FamilyInsurance.umum,
            ),
          );
        }
      }

      return members;
    } catch (_) {
      return null;
    }
  }
}
