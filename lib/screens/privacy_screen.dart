// lib/screens/privacy_screen.dart

import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  // Colores compartidos del estilo de la app
  static const Color _kGreen      = Color(0xFF2E7D32);
  static const Color _kLightGreen = Color(0xFFE8F5E9);
  static const Color _kYellow     = Color(0xFFFFEE58);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kLightGreen,
      appBar: AppBar(
        backgroundColor: _kGreen,
        iconTheme: IconThemeData(color: _kYellow),
        title: Text(
          'Tratamiento de Datos',
          style: TextStyle(color: _kYellow),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Text(
              'Aquí explicas cómo recoges, almacenas y tratas los datos de los usuarios. '
              'Aquí explicas cómo recoges, almacenas y tratas los datos de los usuarios. '
              'Aquí explicas cómo recoges, almacenas y tratas los datos de los usuarios. '
              'Aquí explicas cómo recoges, almacenas y tratas los datos de los usuarios. '
              'Aquí explicas cómo recoges, almacenas y tratas los datos de los usuarios. '
              'Aquí explicas cómo recoges, almacenas y tratas los datos de los usuarios. '
              'Aquí explicas cómo recoges, almacenas y tratas los datos de los usuarios. '
              'Aquí explicas cómo recoges, almacenas y tratas los datos de los usuarios. '
              'Aquí explicas cómo recoges, almacenas y tratas los datos de los usuarios. '
              'Aquí explicas cómo recoges, almacenas y tratas los datos de los usuarios. '
              'Qué terceros pueden tener acceso, cuánto tiempo los guardas, derechos ARCO, etc.',
              style: TextStyle(
                fontSize: 16,
                color: _kGreen,
              ),
            ),
          ),

          // Botón casi invisible en la esquina inferior derecha
          Positioned(
            bottom: 16,
            right: 16,
            child: Opacity(
              opacity: 0.05,  // casi invisible pero pulsable
              child: IconButton(
                icon: Icon(Icons.admin_panel_settings, size: 36),
                onPressed: () {
                  Navigator.of(context).pushNamed('/login');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
