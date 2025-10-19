import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../themes/manager.dart';

class FeedBackService {
  int stepActive = 0;

  Future<Map<String, String>> getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, String> deviceData;

    if (GetPlatform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceData = {
        'platform': 'Android',
        'brand': androidInfo.brand,
        'model': androidInfo.model,
        'version': androidInfo.version.release,
      };
    } else if (GetPlatform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceData = {
        'platform': 'iOS',
        'brand': iosInfo.systemName,
        'model': iosInfo.utsname.machine,
        'version': iosInfo.systemVersion,
      };
    } else {
      deviceData = {
        'platform': 'Unknown',
        'brand': 'Unknown',
        'model': 'Unknown',
        'version': 'Unknown',
      };
    }

    return deviceData;
  }

  Future<void> sendComment(String type, String comment) async {
    Map<String, String> deviceDetails = await getDeviceDetails();

    await FirebaseFirestore.instance.collection('comments').add({
      'type': type,
      'comment': comment,
      'device': deviceDetails,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future dialogComentariosLocais(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.all(0),
        contentPadding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
        titlePadding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Card(
              elevation: 0,
              child: stepActive == 0
                  ? _stepInicial(context, setState)
                  : stepActive == 1
                      ? _stepBug(context, setState)
                      : stepActive == 2
                          ? _stepIdeias(context, setState)
                          : stepActive == 3
                              ? _stepComentarios(context, setState)
                              : _stepAgradecimento(context, setState),
            );
          },
        ),
      ),
    );
  }

  Widget _stepInicial(BuildContext context, StateSetter setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 320),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text('FeedBack', style: TextStyle(fontSize: 18)),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
                stepActive = 0;
                setState(() {});
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 100,
              height: 120,
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
                color: Colors.grey.shade200,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                title: Image.asset(
                  'lib/core/assets/icons/problema.png',
                  width: 40,
                  height: 40,
                ),
                subtitle: const Text(
                  'Problema',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                onTap: () {
                  stepActive = 1;
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 100,
              height: 120,
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
                color: Colors.grey.shade200,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                title: Image.asset(
                  'lib/core/assets/icons/ideia.png',
                  width: 50,
                  height: 50,
                ),
                subtitle: const Text(
                  'Ideia',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                onTap: () {
                  stepActive = 2;
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 100,
              height: 120,
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
                color: Colors.grey.shade200,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                title: Image.asset(
                  'lib/core/assets/icons/comment.png',
                  width: 40,
                  height: 40,
                ),
                subtitle: const Text(
                  'Outro',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                onTap: () {
                  stepActive = 3;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepBug(BuildContext context, StateSetter setState) {
    String description = '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('FeedBack'),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
                stepActive = 0;
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 320,
          child: TextField(
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'Descreva o problema',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => description = value,
            maxLines: 5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                sendComment('BUG', description);
                stepActive = 4;
                setState(() {});
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepComentarios(BuildContext context, StateSetter setState) {
    String description = '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 320),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('FeedBack'),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
                stepActive = 0;
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 320,
          child: TextField(
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'Deixe seu comentário',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => description = value,
            maxLines: 5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                sendComment('COMMENT', description);
                stepActive = 4;
                setState(() {});
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepIdeias(BuildContext context, StateSetter setState) {
    String description = '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('FeedBack'),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
                stepActive = 0;
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 320,
          child: TextField(
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'Deixe sua sugestão',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => description = value,
            maxLines: 5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                sendComment('IDEA', description);
                // Navigator.of(context).pop();
                stepActive = 4;
                setState(() {});
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepAgradecimento(BuildContext context, StateSetter setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('FeedBack'),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
                stepActive = 0;
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        const SizedBox(
          width: 320,
          child: Text(
            'Obrigado por enviar seu feedback, ele é muito importante para nós.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                stepActive = 0;
              },
              child: const Text('Fechar'),
            ),
          ],
        ),
      ],
    );
  }
}

Widget configOptionFeedback(BuildContext context) {
  return ListTile(
    title: const Text('FeedBack'),
    subtitle: const Text(
        'está gostando do app? Envie-nos um comentário, problema ou sugestão.'),
    trailing: Icon(Icons.comment,
        color: ThemeManager().isDark.value
            ? Colors.grey.shade300
            : Colors.grey.shade600),
    onTap: () => FeedBackService().dialogComentariosLocais(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
  );
}
