import 'package:flutter/widgets.dart';

///
class ImagenOptim {
  ///
  static int anchoFisico(BuildContext contexto, double anchoLogico) {
    final dpr = MediaQuery.of(contexto).devicePixelRatio;
    return (anchoLogico * dpr).round();
  }

  ///
  static String optimizar(String url, int anchoFisico, {int calidad = 80}) {
    if (!url.contains('images.unsplash.com')) return url;
    final base = url.split('?').first;
    return '$base?w=$anchoFisico&q=$calidad&auto=format&fit=crop';
  }

  static String paraAncho(BuildContext contexto, String url, double anchoLogico) {
    return optimizar(url, anchoFisico(contexto, anchoLogico));
  }
}
