import 'package:ecotrack_meta/dominio/consumo.dart';
import 'package:flutter/material.dart';

class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({
    super.key,
    required this.alGuardar,
    required this.error,
    required this.guardando,
  });

  final Future<bool> Function(String laboratorio, String litros) alGuardar;
  final String? error;
  final bool guardando;

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  String _laboratorioSeleccionado = laboratoriosUtez.first;
  final TextEditingController _litrosController = TextEditingController();

  @override
  void dispose() {
    _litrosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _laboratorioSeleccionado,
            items: laboratoriosUtez.map((lab) {
              return DropdownMenuItem<String>(
                value: lab,
                child: Text(lab),
              );
            }).toList(),
            onChanged: widget.guardando
                ? null
                : (val) {
                    if (val != null) {
                      setState(() {
                        _laboratorioSeleccionado = val;
                      });
                    }
                  },
            decoration: const InputDecoration(
              labelText: 'Laboratorio',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('litros'),
            controller: _litrosController,
            enabled: !widget.guardando,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Litros',
              errorText: widget.error,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.guardando
                ? null
                : () async {
                    final ok = await widget.alGuardar(
                      _laboratorioSeleccionado,
                      _litrosController.text,
                    );
                    if (!mounted) return;
                    if (ok) {
                      _litrosController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Consumo guardado')),
                      );
                    }
                  },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class ListaHistorial extends StatelessWidget {
  const ListaHistorial({
    super.key,
    required this.consumos,
    required this.total,
  });

  final List<Consumo> consumos;
  final double total;

  @override
  Widget build(BuildContext context) {
    if (consumos.isEmpty) {
      return const Center(child: Text('Sin consumos'));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'Total: ${total.toStringAsFixed(1)} L',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...consumos.map(
          (c) => ListTile(
            title: Text(c.laboratorio),
            trailing: Text('${c.litros.toStringAsFixed(1)} L'),
          ),
        ),
      ],
    );
  }
}

class PanelMeta extends StatelessWidget {
  const PanelMeta({
    super.key,
    required this.usado,
    required this.meta,
    required this.avance,
    required this.superada,
    required this.alSubir,
    required this.alBajar,
  });

  final double usado;
  final double meta;
  final double avance;
  final bool superada;
  final VoidCallback alSubir;
  final VoidCallback alBajar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Usado: ${usado.toStringAsFixed(1)} de ${meta.toStringAsFixed(1)} L',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: avance),
          const SizedBox(height: 16),
          Text(
            superada ? 'Te pasaste de la meta' : 'Dentro de la meta',
            style: TextStyle(
              color: superada ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                key: const Key('bajarMeta'),
                onPressed: alBajar,
                icon: const Icon(Icons.remove),
              ),
              IconButton(
                key: const Key('subirMeta'),
                onPressed: alSubir,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PantallasEcoTrack extends StatefulWidget {
  const PantallasEcoTrack({
    super.key,
    required this.titulo,
    required this.registro,
    required this.historial,
    required this.meta,
  });

  final String titulo;
  final Widget registro;
  final Widget historial;
  final Widget meta;

  @override
  State<PantallasEcoTrack> createState() => _PantallasEcoTrackState();
}

class _PantallasEcoTrackState extends State<PantallasEcoTrack> {
  int _indicePestana = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
      ),
      body: IndexedStack(
        index: _indicePestana,
        children: [
          widget.registro,
          widget.historial,
          widget.meta,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indicePestana,
        onTap: (index) {
          setState(() {
            _indicePestana = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Registro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Meta',
          ),
        ],
      ),
    );
  }
}
