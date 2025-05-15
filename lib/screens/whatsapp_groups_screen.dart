// lib/screens/whatsapp_groups_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class WhatsappGroupsScreen extends StatefulWidget {
  @override
  _WhatsappGroupsScreenState createState() => _WhatsappGroupsScreenState();
}

class _WhatsappGroupsScreenState extends State<WhatsappGroupsScreen> {
  final _listsRef = FirebaseFirestore.instance.collection('broadcastLists');
  // Reemplaza esto con la URL base de tus Cloud Functions
  static const _functionsBaseUrl =
      'https://us-central1-<TU_PROYECTO>.cloudfunctions.net';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grupos de difusión WhatsApp'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _listsRef.snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.active) {
            return Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error al cargar listas'));
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text('No hay listas creadas'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final doc = docs[i];
              final data = doc.data()! as Map<String, dynamic>;
              final name = data['name'] as String;
              final recipients = (data['recipients'] as List<dynamic>)
                  .cast<String>();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text('${recipients.length} contactos'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.send),
                        tooltip: 'Enviar mensaje',
                        onPressed: () => _showSendDialog(doc.id),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        tooltip: 'Editar lista',
                        onPressed: () => _showEditDialog(doc),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        tooltip: 'Eliminar lista',
                        onPressed: () => _confirmDelete(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Crear nueva lista',
        onPressed: () => _showCreateDialog(),
      ),
    );
  }

  Future<void> _showCreateDialog() async {
    await _showListDialog();
  }

  Future<void> _showEditDialog(DocumentSnapshot doc) async {
    final data = doc.data()! as Map<String, dynamic>;
    await _showListDialog(
      docId: doc.id,
      initialName: data['name'] as String,
      initialRecipients:
          (data['recipients'] as List<dynamic>).cast<String>(),
    );
  }

  Future<void> _showListDialog({
    String? docId,
    String initialName = '',
    List<String> initialRecipients = const [],
  }) async {
    final _nameCtrl = TextEditingController(text: initialName);
    final _recCtrl = TextEditingController(
      text: initialRecipients.join('\n'),
    );
    final isEditing = docId != null;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Editar lista' : 'Nueva lista'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: 'Nombre de la lista'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _recCtrl,
                decoration: InputDecoration(
                  labelText:
                      'Números (uno por línea, formato +34123456789)',
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text(isEditing ? 'Guardar' : 'Crear'),
            onPressed: () async {
              final name = _nameCtrl.text.trim();
              final recText = _recCtrl.text.trim();
              if (name.isEmpty || recText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rellena todos los campos')),
                );
                return;
              }
              final recipients = recText
                  .split(RegExp(r'[\r\n,;]+'))
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              if (isEditing) {
                await _listsRef.doc(docId).update({
                  'name': name,
                  'recipients': recipients,
                });
              } else {
                await _listsRef.add({
                  'name': name,
                  'recipients': recipients,
                });
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String docId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar lista'),
        content: Text('¿Seguro que quieres eliminar esta lista?'),
        actions: [
          TextButton(
            child: Text('No'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            child: Text('Sí, eliminar'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _listsRef.doc(docId).delete();
    }
  }

  Future<void> _showSendDialog(String listId) async {
    final _msgCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Enviar mensaje'),
        content: TextField(
          controller: _msgCtrl,
          decoration: InputDecoration(labelText: 'Mensaje'),
          maxLines: null,
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: Text('Enviar'),
            onPressed: () async {
              final msg = _msgCtrl.text.trim();
              if (msg.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('El mensaje no puede estar vacío')),
                );
                return;
              }
              Navigator.of(ctx).pop();
              await _sendMessage(listId, msg);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String listId, String message) async {
    final uri = Uri.parse(
      '$_functionsBaseUrl/sendWhatsappBroadcast'
      '?listId=$listId'
      '&message=${Uri.encodeComponent(message)}',
    );
    try {
      final resp = await http.post(uri);
      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mensaje enviado exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al enviar: ${resp.statusCode} ${resp.reasonPhrase}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red: $e')),
      );
    }
  }
}
