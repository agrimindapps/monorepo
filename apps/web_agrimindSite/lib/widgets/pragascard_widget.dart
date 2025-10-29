import 'package:flutter/material.dart';

class PragaCard extends StatelessWidget {
  final String nomeComum;
  final String nomeSecundario;
  final String nomeCientifico;
  final String imageUrl;
  final VoidCallback onTap;

  const PragaCard({
    super.key,
    required this.nomeComum,
    required this.nomeSecundario,
    required this.nomeCientifico,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: double.infinity,
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 2,
                        spreadRadius: 2,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              // FutureBuilder(
              //   future: Future.value(Image.asset(imageUrl).image),
              //   builder: (BuildContext context, AsyncSnapshot<ImageProvider<Object>> snapshot) {
              //     if (snapshot.connectionState == ConnectionState.done) {
              //       return Padding(
              //         padding: const EdgeInsets.all(2.0),
              //         child: ,
              //       );
              //     } else {
              //       return const Center(child: CircularProgressIndicator());
              //     }
              //   },
              // ),
            ),
            SizedBox(
              height: 50,
              child: ListTile(
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                dense: true,
                title: Text(nomeComum, overflow: TextOverflow.ellipsis),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (nomeSecundario != '')
                      Text(nomeSecundario.trim(),
                          overflow: TextOverflow.ellipsis),
                    Text(nomeCientifico, overflow: TextOverflow.ellipsis),
                  ],
                ),
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
