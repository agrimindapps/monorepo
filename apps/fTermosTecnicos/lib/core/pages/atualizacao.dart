import 'package:flutter/material.dart';

import '../../intermediate.dart';
import '../widgets/appbar.dart';

class AtualizacaoPage extends StatefulWidget {
  const AtualizacaoPage({super.key});

  @override
  AtualizacaoPageState createState() => AtualizacaoPageState();
}

class AtualizacaoPageState extends State<AtualizacaoPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1020,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    color: const Color(0xFFF5F5F5),
                    child: GlobalEnvironment().atualizacoesText.isNotEmpty
                        ? ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                GlobalEnvironment().atualizacoesText.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    GlobalEnvironment().atualizacoesText[index]
                                        ['versao']!,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    GlobalEnvironment()
                                        .atualizacoesText[index]['notas']!
                                        .join(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
