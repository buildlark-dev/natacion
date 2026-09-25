import 'package:flutter_test/flutter_test.dart';
import 'package:natacion_app/dominio/entidades/serie.dart';
import 'package:natacion_app/dominio/metodologia/estilos.dart';
import 'package:natacion_app/dominio/metodologia/zonas.dart';

/// FR-035: la corrección manual prevalece sobre la interpretación automática, y
/// una reinterpretación posterior no puede sobrescribirla.
///
/// Es la garantía de que el entrenador manda sobre la máquina.
void main() {
  group('corrección de un campo', () {
    test('cambia el valor y marca la serie como corregida a mano', () {
      const original = Serie(repeticiones: 4, distancia: 100);
      final corregida = original.corregir('distancia', valorEntero: 150);

      expect(corregida.distancia, 150);
      expect(corregida.origen, OrigenDato.corregidoAMano);
    });

    test('recalcula los metros con el valor corregido', () {
      const original = Serie(repeticiones: 4, distancia: 100);
      expect(original.metros, 400);

      final corregida = original.corregir('distancia', valorEntero: 150);
      expect(corregida.metros, 600);
    });

    test('deja el campo protegido frente a reinterpretaciones', () {
      const original = Serie(repeticiones: 4, distancia: 100);
      final corregida = original.corregir('distancia', valorEntero: 150);

      expect(corregida.estaProtegido('distancia'), isTrue);
      expect(corregida.estaProtegido('repeticiones'), isFalse);
    });

    test('se pueden proteger varios campos', () {
      const original = Serie(repeticiones: 4, distancia: 100);
      final corregida = original
          .corregir('distancia', valorEntero: 150)
          .corregir('repeticiones', valorEntero: 6);

      expect(corregida.estaProtegido('distancia'), isTrue);
      expect(corregida.estaProtegido('repeticiones'), isTrue);
      expect(corregida.metros, 900);
    });

    test('la zona corregida a mano queda protegida', () {
      const original = Serie(distancia: 200);
      final corregida = original.corregir('zona', zona: Zona.at);

      expect(corregida.zona, Zona.at);
      expect(corregida.estaProtegido('zona'), isTrue);
    });

    test('el estilo corregido a mano queda protegido', () {
      const original = Serie(distancia: 200, estilo: Estilo.libre);
      final corregida = original.corregir('estilo', estilo: Estilo.espalda);

      expect(corregida.estilo, Estilo.espalda);
      expect(corregida.estaProtegido('estilo'), isTrue);
    });
  });

  group('una serie sin tocar', () {
    test('figura como interpretada automáticamente', () {
      const serie = Serie(distancia: 200);
      expect(serie.origen, OrigenDato.interpretado);
      expect(serie.camposCorregidos, isEmpty);
    });

    test('no tiene ningún campo protegido', () {
      const serie = Serie(distancia: 200);
      for (final campo in ['distancia', 'repeticiones', 'zona', 'estilo']) {
        expect(serie.estaProtegido(campo), isFalse);
      }
    });
  });
}
