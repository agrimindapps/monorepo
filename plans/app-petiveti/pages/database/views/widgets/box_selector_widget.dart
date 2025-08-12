// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/database_controller.dart';
import '../../models/box_type_model.dart';
import '../../utils/database_helpers.dart';

class BoxSelectorWidget extends StatelessWidget {
  final DatabaseController controller;

  const BoxSelectorWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: DatabaseHelpers.getCardBorderRadius(),
      ),
      child: Padding(
        padding: DatabaseHelpers.getCardPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildSelector(),
            if (controller.hasSelectedBox) ...[
              const SizedBox(height: 12),
              _buildSelectedBoxInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.storage, size: 20),
        const SizedBox(width: 8),
        const Text(
          'Selecione uma Box:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const Spacer(),
        if (controller.availableBoxes.isNotEmpty)
          Text(
            '${controller.availableBoxes.length} boxes disponíveis',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildSelector() {
    if (controller.availableBoxes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600]),
            const SizedBox(width: 8),
            const Text(
              'Nenhuma box encontrada no banco de dados.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<BoxType>(
      decoration: DatabaseHelpers.getDropdownDecoration(),
      value: controller.selectedBox,
      hint: const Text('Selecione uma box para visualizar'),
      isExpanded: true,
      items: controller.availableBoxes.map((boxInfo) {
        return DropdownMenuItem(
          value: boxInfo.type,
          child: _buildDropdownItem(boxInfo),
        );
      }).toList(),
      onChanged: (BoxType? value) {
        if (value != null) {
          controller.selectBox(value);
        }
      },
    );
  }

  Widget _buildDropdownItem(BoxInfo boxInfo) {
    return Row(
      children: [
        Icon(boxInfo.type.icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(boxInfo.type.displayName)),
        if (boxInfo.hasData)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${boxInfo.recordCount}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedBoxInfo() {
    final selectedBox = controller.selectedBox!;
    final boxInfo = controller.getBoxInfo(selectedBox);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(selectedBox.icon, color: Colors.blue[700], size: 18),
              const SizedBox(width: 8),
              Text(
                selectedBox.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const Spacer(),
              if (boxInfo != null)
                Text(
                  boxInfo.recordCountText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            selectedBox.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[600],
            ),
          ),
          if (controller.hasData && controller.tableData.fields.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Campos: ${controller.tableData.sortedFields.take(5).join(', ')}${controller.tableData.fields.length > 5 ? '...' : ''}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
