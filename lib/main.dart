import 'package:flutter/material.dart';
void main() {
  runApp(const MiApp());
}
// IA "de mentiritas": simula la espera de internet y devuelve un plan.
// El día de mañana, solo cambiaremos lo de adentro por la llamada real.
Future<String> generarPlanIA(String datosNadador) async {
  await Future.delayed(const Duration(seconds: 4)); // finge 4 s de internet
  return 'Plan para $datosNadador:\n20x50L AL / 1 min';
}
class MiApp extends StatefulWidget {
  const MiApp({super.key});
  @override
  State<MiApp> createState() => _MiAppState();
}
class Nadador {
  String nombre;
  double tiempo100m;
  
  Nadador(this.nombre, this.tiempo100m);
  
  String nivel() {
    if (tiempo100m < 60) {
      return 'Competitivo';
    } else if (tiempo100m < 70) {
      return 'Intermedio';
    } else {
      return 'En desarrollo';
    }
  }
}
 List<Nadador> equipo = [
    Nadador('Ana', 68),
    Nadador('Peter', 55),
    Nadador('Carlos', 75),
  ];
class _MiAppState extends State<MiApp> {
  String plan = 'Aún no hay plan generado';
  bool cargando = false;
  void pedirPlan() async {
    setState(() {
      cargando = true;            // 1) avisamos que empezó la espera
    });
    
    Nadador n = equipo[1];
    String resultado = await generarPlanIA('${n.nombre}, con tiempo de 100 en ${n.tiempo100m}s y nivel ${n.nivel()}:'); // 2) esperamos
    setState(() {
      plan = resultado;           // 3) llegó el plan, lo mostramos
      cargando = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Generador profesional de planes')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(cargando ? 'Generando plan...' : plan),
            ),
            ElevatedButton(
              onPressed: cargando ? null : pedirPlan,
              child: const Text('Generar plan'),
            ),
          ],
        ),
      ),
    );
  }
}
