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
              '''En WinoWin nos tomamos muy en serio la privacidad de tus datos. A continuación te explicamos de forma detallada cómo recopilamos, almacenamos y empleamos la información que nos facilitas:

1. Campañas de Marketing
Utilizamos tus datos (nombre, dirección de correo electrónico, preferencias e historial de interacción con nuestros contenidos) para diseñar campañas de marketing personalizadas. Gracias a esta segmentación, podemos enviarte solo aquellas comunicaciones que realmente te resulten relevantes y evitar el envío de mensajes genéricos. Por ejemplo, si te has suscrito a categorías concretas (tecnología, moda, hogar…), recibirás ofertas y novedades ajustadas a tus intereses. Toda la información se procesa de manera agregada y anónima siempre que sea posible, y empleamos proveedores de servicios externos que cumplen con estrictas normas de confidencialidad y seguridad.

2. Alertas de productos nuevos
Cada vez que lancemos un producto o servicio nuevo, te enviaremos una notificación por correo electrónico para que seas de los primeros en conocerlo. Para ello, guardamos tu dirección de email y, opcionalmente, tus preferencias de categoría o línea de producto. Solo recibirás estas alertas si has manifestado tu interés en recibir novedades. Podrás darte de baja de estas alertas en cualquier momento mediante el enlace de “Darme de baja” incluido en cada email.

3. Alertas para eventos
Organizamos eventos presenciales y virtuales (webinars, talleres, presentaciones de producto, etc.) y, si estás suscrito, te enviaremos invitaciones y recordatorios. Para ello, además de tu email, podemos usar tu nombre para personalizar las invitaciones, así como tu zona geográfica si deseas recibir información de eventos locales. Esta información solo se comparte con nuestros socios organizadores cuando es estrictamente necesario para la realización del evento, y siempre bajo acuerdos de protección de datos.

4. Envío de correos comerciales, publicitarios y promocionales
Con tu consentimiento, podemos enviarte correos de todo tipo relacionados con nuestra actividad:
- Publicidad: ofertas especiales, descuentos exclusivos, cupones y promociones temporales.
- Productos: catálogos digitales, demostraciones de producto, casos de éxito y comparativas.
- Promociones: sorteos, concursos, packs de lanzamiento y promociones por temporada.

En cada envío encontrarás un enlace para gestionar tus preferencias de suscripción y, si lo deseas, darte de baja de forma inmediata y sencilla.

Transferencia y conservación de datos
Tus datos se almacenan en servidores ubicados dentro de la Unión Europea y sólo los conservamos mientras sean necesarios para cumplir con los fines descritos. Una vez alcanzado el propósito (por ejemplo, si te das de baja de todas las comunicaciones), quedarán bloqueados durante el tiempo legalmente exigido para atender posibles responsabilidades y, posteriormente, eliminados de forma segura.

Tus derechos
Como titular de los datos, tienes derecho a acceder, rectificar y suprimir tu información, así como a limitar u oponerte a su tratamiento y solicitar la portabilidad a otro responsable. Para ejercitar cualquiera de estos derechos, puedes escribirnos a privacidad@tudominio.com o utilizar los formularios disponibles en nuestra web.

Contacto
Si tienes cualquier duda sobre cómo usamos tus datos o quieres más información, no dudes en ponerte en contacto con nuestro delegado de protección de datos en dpo@tudominio.com.
''' ,
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
