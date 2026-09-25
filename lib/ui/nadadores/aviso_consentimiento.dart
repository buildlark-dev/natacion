/// Aviso permanente sobre el consentimiento del acudiente.
///
/// El diseño no impide técnicamente cargar datos reales de menores; solo la
/// especificación lo prohíbe por escrito. Este aviso hace visible esa
/// restricción mientras no exista el registro de consentimiento, y cierra la
/// condición del principio V registrada en `plan.md`.
///
/// **Debe retirarse** cuando la feature de cuentas implemente el
/// consentimiento verificable, no antes.
library;

import 'package:flutter/material.dart';

class AvisoConsentimiento extends StatelessWidget {
  const AvisoConsentimiento({super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Card(
      color: esquema.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.shield_outlined, color: esquema.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solo datos de prueba',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: esquema.onErrorContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Esta versión todavía no registra el consentimiento del '
                    'padre, madre o acudiente. Hasta que lo haga, no cargue '
                    'datos reales de nadadores menores de edad: la Ley 1581 '
                    'de 2012 lo exige para almacenarlos, y el principio V de '
                    'la constitución del proyecto también.',
                    style: TextStyle(color: esquema.onErrorContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
