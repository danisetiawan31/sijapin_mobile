/// Satu tindakan pemeriksaan dalam rincian paket Medical Check-Up (MCU).
class McuCatalogExamination {
  const McuCatalogExamination({
    required this.tarifId,
    required this.nama,
    required this.harga,
  });

  /// `t_daftar_mcu_tindakan.TARIF_ID` (komponen tindakan).
  final int tarifId;

  /// Nama tindakan pemeriksaan (`nama_tarif`).
  final String nama;

  /// Nilai billing tindakan; pada backend memuat harga paket.
  final int harga;
}

/// Paket Medical Check-Up (MCU) beserta rincian tindakan dan tarifnya.
///
/// Mengacu pada `GET /Pendaftaran_MCU_Paket` (Uniform Envelope
/// `data: {selected_mcu_id, paket: [...], detail: [...]}`): baris `paket`
/// (`t_daftar_mcu`) dipadukan dengan baris `detail`
/// (`t_daftar_mcu_tindakan` + `t_daftar_mcu_billing`) yang dikelompokkan
/// menurut `tarif_id_m`.
class McuCatalogPackage {
  const McuCatalogPackage({
    required this.tarifId,
    required this.kodeTarif,
    required this.name,
    required this.tarifName,
    required this.price,
    required this.examinations,
  });

  /// `tarif_id` paket (`t_daftar_mcu.TARIF_ID`) — unik per paket.
  final int tarifId;

  /// `kode_tarif` paket; dapat berulang antar paket.
  final String kodeTarif;

  /// Nama singkat paket (`nama_paket`).
  final String name;

  /// Nama tarif resmi (`nama_tarif`).
  final String tarifName;

  /// Harga paket (`t_daftar_mcu_billing.JUMLAH_BAYAR`); 0 bila belum tersedia.
  final int price;

  /// Rincian tindakan pemeriksaan paket.
  final List<McuCatalogExamination> examinations;

  /// Membangun daftar paket dari `data` envelope `Pendaftaran_MCU_Paket`.
  static List<McuCatalogPackage> listFromEnvelopeData(Object? data) {
    if (data is List) {
      return data
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> row) => _fromPaketRow(
              _normalize(row),
              const <McuCatalogExamination>[],
              0,
            ),
          )
          .where((McuCatalogPackage pkg) => pkg.name.isNotEmpty)
          .toList();
    }
    if (data is! Map) return const <McuCatalogPackage>[];
    final Object? rawPaket = data['paket'];
    if (rawPaket is! List) return const <McuCatalogPackage>[];
    final Map<String, _DetailGroup> groups = _groupDetail(data['detail']);
    final List<McuCatalogPackage> packages = <McuCatalogPackage>[];
    for (final Object? row in rawPaket) {
      if (row is! Map) continue;
      final Map<String, dynamic> map = _normalize(row);
      final String tarifId = _asText(map['tarif_id']);
      if (tarifId.isEmpty) continue;
      final _DetailGroup? group = groups[tarifId];
      packages.add(
        _fromPaketRow(
          map,
          group?.examinations ?? const <McuCatalogExamination>[],
          group?.harga ?? 0,
        ),
      );
    }
    return packages;
  }

  static McuCatalogPackage _fromPaketRow(
    Map<String, dynamic> map,
    List<McuCatalogExamination> examinations,
    int groupPrice,
  ) {
    final int tarifId = _asInt(map['tarif_id']);
    final int price = groupPrice > 0 ? groupPrice : _asInt(map['harga']);
    return McuCatalogPackage(
      tarifId: tarifId,
      kodeTarif: _asText(map['kode_tarif']),
      name: _asText(map['nama_paket']),
      tarifName: _asText(map['nama_tarif']),
      price: price,
      examinations: examinations,
    );
  }

  static Map<String, _DetailGroup> _groupDetail(Object? raw) {
    if (raw is! List) return const <String, _DetailGroup>{};
    final Map<String, List<McuCatalogExamination>> items =
        <String, List<McuCatalogExamination>>{};
    final Map<String, int> harga = <String, int>{};
    for (final Object? row in raw) {
      if (row is! Map) continue;
      final Map<String, dynamic> map = _normalize(row);
      final String master = _asText(map['tarif_id_m']);
      if (master.isEmpty) continue;
      final int nilai = _asInt(map['harga']);
      items
          .putIfAbsent(master, () => <McuCatalogExamination>[])
          .add(
            McuCatalogExamination(
              tarifId: _asInt(map['tarif_id']),
              nama: _asText(map['nama_tarif']),
              harga: nilai,
            ),
          );
      if (nilai > (harga[master] ?? 0)) harga[master] = nilai;
    }
    return <String, _DetailGroup>{
      for (final MapEntry<String, List<McuCatalogExamination>> entry
          in items.entries)
        entry.key: _DetailGroup(
          harga: harga[entry.key] ?? 0,
          examinations: entry.value,
        ),
    };
  }

  static Map<String, dynamic> _normalize(Map<dynamic, dynamic> row) =>
      row.map((dynamic key, dynamic value) => MapEntry(key.toString(), value));

  static String _asText(Object? value) => value?.toString().trim() ?? '';

  static int _asInt(Object? value) =>
      int.tryParse(_asText(value).replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
}

class _DetailGroup {
  const _DetailGroup({required this.harga, required this.examinations});

  final int harga;
  final List<McuCatalogExamination> examinations;
}
