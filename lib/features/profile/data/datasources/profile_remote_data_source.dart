import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/family_member.dart';

/// Kontrak sumber data remote profil pasien dan anggota keluarga SIMRS
abstract class IProfileRemoteDataSource {
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
      if (memberCards.isEmpty) return null;

      final List<FamilyMember> members = [];
      for (final anchor in memberCards) {
        final href = anchor.attributes['href'] ?? '';
        final idMatch = RegExp(r'pasien/form_data/(\w+)').firstMatch(href);
        final id = idMatch?.group(1) ?? '';
        if (id.isEmpty) continue;

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

      return members.isNotEmpty ? members : null;
    } catch (_) {
      return null;
    }
  }
}
