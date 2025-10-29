// import 'package:fcalcagro/components/ad/banner.dart';
import 'package:flutter/material.dart';

import '../app-site/const/atualizacao_const.dart';
import '../services/return_service.dart';

class AtualizacaoPage extends StatefulWidget {
  const AtualizacaoPage({super.key});

  @override
  AtualizacaoPageState createState() => AtualizacaoPageState();
}

class AtualizacaoPageState extends State<AtualizacaoPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    returnScope.setContext(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Atualizações',
          style: TextStyle(color: Colors.white, fontSize: 16),
          maxLines: 1,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      atualizacoesText.isNotEmpty
                          ? ListView.separated(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: atualizacoesText.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      atualizacoesText[index]['versao']!,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      atualizacoesText[index]['notas']!.join(
                                        '\n',
                                      ),
                                    ),
                                  ),
                                  visualDensity: VisualDensity.comfortable,
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const Divider();
                              },
                            )
                          : const Text('Sem atualizações'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      //bottomSheet: AdBanner()
    );
  }
}
