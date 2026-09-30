// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/.gitkeep
  String get aGitkeep => 'assets/fonts/.gitkeep';

  /// List of all assets
  List<String> get values => [aGitkeep];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/.gitkeep
  String get aGitkeep => 'assets/icons/.gitkeep';

  /// File path: assets/icons/ic_doctor_stethoscope.svg
  String get icDoctorStethoscope => 'assets/icons/ic_doctor_stethoscope.svg';

  /// File path: assets/icons/ic_hospital_bed.svg
  String get icHospitalBed => 'assets/icons/ic_hospital_bed.svg';

  /// List of all assets
  List<String> get values => [aGitkeep, icDoctorStethoscope, icHospitalBed];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/.gitkeep
  String get aGitkeep => 'assets/images/.gitkeep';

  /// File path: assets/images/bento_bed.png
  AssetGenImage get bentoBed =>
      const AssetGenImage('assets/images/bento_bed.png');

  /// File path: assets/images/bento_doctor.png
  AssetGenImage get bentoDoctor =>
      const AssetGenImage('assets/images/bento_doctor.png');

  /// File path: assets/images/doctor_avatar.png
  AssetGenImage get doctorAvatar =>
      const AssetGenImage('assets/images/doctor_avatar.png');

  /// File path: assets/images/leaves_bl.png
  AssetGenImage get leavesBl =>
      const AssetGenImage('assets/images/leaves_bl.png');

  /// File path: assets/images/leaves_tr.png
  AssetGenImage get leavesTr =>
      const AssetGenImage('assets/images/leaves_tr.png');

  /// File path: assets/images/mcu_illustration.png
  AssetGenImage get mcuIllustration =>
      const AssetGenImage('assets/images/mcu_illustration.png');

  /// File path: assets/images/vector_booking_success.svg
  String get vectorBookingSuccess => 'assets/images/vector_booking_success.svg';

  /// File path: assets/images/vector_bpjs_card.svg
  String get vectorBpjsCard => 'assets/images/vector_bpjs_card.svg';

  /// File path: assets/images/vector_doctor_search_empty.svg
  String get vectorDoctorSearchEmpty =>
      'assets/images/vector_doctor_search_empty.svg';

  /// File path: assets/images/vector_empty_appointment.svg
  String get vectorEmptyAppointment =>
      'assets/images/vector_empty_appointment.svg';

  /// File path: assets/images/vector_network_offline.svg
  String get vectorNetworkOffline => 'assets/images/vector_network_offline.svg';

  /// File path: assets/images/vector_outpatient_registration.svg
  String get vectorOutpatientRegistration =>
      'assets/images/vector_outpatient_registration.svg';

  /// List of all assets
  List<dynamic> get values => [
    aGitkeep,
    bentoBed,
    bentoDoctor,
    doctorAvatar,
    leavesBl,
    leavesTr,
    mcuIllustration,
    vectorBookingSuccess,
    vectorBpjsCard,
    vectorDoctorSearchEmpty,
    vectorEmptyAppointment,
    vectorNetworkOffline,
    vectorOutpatientRegistration,
  ];
}

abstract final class Assets {
  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
