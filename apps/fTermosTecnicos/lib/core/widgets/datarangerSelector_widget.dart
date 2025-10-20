import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeSelector extends StatefulWidget {
  final Function(int dataInicial, int dataFinal) onChange;
  final String initialValue;
  final bool disabled; // Add new property

  const DateRangeSelector({
    super.key,
    required this.onChange,
    this.initialValue = 'ultimos7',
    this.disabled = false, // Default value
  });

  @override
  State<DateRangeSelector> createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  late int _dataInicial;
  late int _dataFinal;
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _initializeDates();
  }

  void _initializeDates() {
    _dataFinal = DateTime.now().millisecondsSinceEpoch;
    _dataInicial =
        DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 200,
          decoration: BoxDecoration(
            color: widget.disabled ? Colors.grey[200] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: widget.initialValue,
            items: const [
              DropdownMenuItem(
                  value: 'ultimos7', child: Text('Últimos 7 dias')),
              DropdownMenuItem(
                  value: 'ultimos14', child: Text('Últimos 14 dias')),
              DropdownMenuItem(
                  value: 'ultimos28', child: Text('Últimos 28 dias')),
              DropdownMenuItem(value: 'mesAtual', child: Text('Mês atual')),
              DropdownMenuItem(value: 'ultimoMes', child: Text('Último mês')),
              DropdownMenuItem(value: 'tresMeses', child: Text('Três meses')),
              DropdownMenuItem(
                  value: 'personalizado', child: Text('Personalizado')),
            ],
            onChanged: widget.disabled
                ? null
                : (String? value) async {
                    if (value == 'personalizado') {
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              dialogBackgroundColor: Colors.white,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 400,
                                height: 500,
                                child: child!,
                              ),
                            ),
                          );
                        },
                        barrierColor: Colors.black54,
                      );

                      if (picked != null) {
                        setState(() {
                          _dataInicial = picked.start.millisecondsSinceEpoch;
                          _dataFinal = picked.end.millisecondsSinceEpoch;
                        });
                        widget.onChange(_dataInicial, _dataFinal);
                      }
                    } else {
                      int dataInicial;
                      int dataFinal = DateTime.now().millisecondsSinceEpoch;

                      switch (value) {
                        case 'ultimos7':
                          dataInicial = DateTime.now()
                              .subtract(const Duration(days: 7))
                              .millisecondsSinceEpoch;
                          break;
                        case 'ultimos14':
                          dataInicial = DateTime.now()
                              .subtract(const Duration(days: 14))
                              .millisecondsSinceEpoch;
                          break;
                        case 'ultimos28':
                          dataInicial = DateTime.now()
                              .subtract(const Duration(days: 28))
                              .millisecondsSinceEpoch;
                          break;
                        case 'mesAtual':
                          dataInicial = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            1,
                          ).millisecondsSinceEpoch;
                          break;
                        case 'ultimoMes':
                          dataInicial = DateTime(
                            DateTime.now().year,
                            DateTime.now().month - 1,
                            1,
                          ).millisecondsSinceEpoch;
                          dataFinal = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            0,
                          ).millisecondsSinceEpoch;
                          break;
                        case 'tresMeses':
                          dataInicial = DateTime.now()
                              .subtract(const Duration(days: 90))
                              .millisecondsSinceEpoch;
                          break;
                        default:
                          return;
                      }

                      setState(() {
                        _dataInicial = dataInicial;
                        _dataFinal = dataFinal;
                      });

                      widget.onChange(dataInicial, dataFinal);
                    }
                  },
            style: TextStyle(
              color: widget.disabled ? Colors.grey[500] : Colors.black,
            ),
            iconEnabledColor: widget.disabled ? Colors.grey[500] : null,
          ),
        ),
        // const SizedBox(width: 16),
        // Text(
        //   '${_dateFormat.format(DateTime.fromMillisecondsSinceEpoch(_dataInicial))} - '
        //   '${_dateFormat.format(DateTime.fromMillisecondsSinceEpoch(_dataFinal))}',
        //   style: const TextStyle(
        //     fontSize: 14,
        //     color: Colors.grey,
        //   ),
        // ),
      ],
    );
  }
}
