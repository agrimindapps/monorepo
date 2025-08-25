// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

// Project imports:
import '../core/navigation/route_manager.dart';
import '../models/11_animal_model.dart';
import '../widgets/page_header_widget.dart';
import 'meupet/animal_page/controllers/animal_page_controller.dart';
import 'meupet/animal_page/views/animal_page_view.dart';
import 'meupet/consulta_page/index.dart';
import 'meupet/despesas_page/index.dart';
import 'meupet/lembretes_page/index.dart';
import 'meupet/medicamentos_page/index.dart';
import 'meupet/peso_page/peso_page_view.dart';
import 'meupet/vacina_page/views/vacina_page_view.dart';

class HomeVetPage extends StatefulWidget {
  const HomeVetPage({super.key});

  @override
  State<HomeVetPage> createState() => _HomeVetPageState();
}

class _HomeVetPageState extends State<HomeVetPage> {
  final _animalController = Get.find<AnimalPageController>();
  Animal? selectedAnimal;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _animalController.getSelectedAnimalId();
    await _animalController.loadAnimals();
    _updateSelectedAnimal();
  }

  void _updateSelectedAnimal() {
    if (_animalController.selectedAnimalId.isNotEmpty &&
        _animalController.animals.isNotEmpty) {
      selectedAnimal = _animalController.animals.firstWhereOrNull(
          (animal) => animal.id == _animalController.selectedAnimalId);
      setState(() {});
    }
  }

  void _navigateToPage(Widget page) {
    // Usa RouteManager para navegação consistente
    RouteManager.instance.to(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 1020,
              child: Column(
                children: [
                  // Header
                  const PageHeaderWidget(
                    title: 'VetApp',
                    subtitle: 'Dashboard do seu veterinário',
                    icon: Icons.pets,
                    showBackButton: false,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Avatar Section
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: selectedAnimal?.foto != null
                              ? NetworkImage(selectedAnimal!.foto!)
                              : null,
                          child: selectedAnimal?.foto == null
                              ? const Icon(Icons.pets,
                                  size: 60, color: Colors.grey)
                              : null,
                        ),

                        const SizedBox(height: 20),

                        // Animal Selector
                        SizedBox(
                          width: 300,
                          child: GetBuilder<AnimalPageController>(
                            builder: (controller) {
                              if (controller.isLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              return DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Selecione um Animal',
                                  border: OutlineInputBorder(),
                                ),
                                value: controller.selectedAnimalId.isEmpty
                                    ? null
                                    : controller.selectedAnimalId,
                                items: controller.animals.map((Animal animal) {
                                  return DropdownMenuItem<String>(
                                    value: animal.id,
                                    child: Text(animal.nome),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.setSelectedAnimalId(value);
                                    setState(() {
                                      selectedAnimal = controller.animals
                                          .firstWhere(
                                              (animal) => animal.id == value);
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 30),
                        AlignedGridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount:
                              MediaQuery.of(context).size.width < 600
                                  ? 2
                                  : MediaQuery.of(context).size.width < 900
                                      ? 3
                                      : 4,
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 16.0,
                          itemCount: 7, // Number of menu items
                          itemBuilder: (context, index) {
                            // No futuro, considerar usar as constantes: AppRoutes.animais, etc.
                            final menuItems = [
                              (_MenuButton(
                                icon: Icons.pets,
                                label: 'Animais',
                                onTap: () =>
                                    _navigateToPage(const AnimalPageView()),
                                color: Colors.blue,
                              )),
                              (_MenuButton(
                                icon: Icons.fitness_center,
                                label: 'Peso',
                                onTap: () =>
                                    _navigateToPage(const PesoPageView()),
                                color: Colors.indigo,
                              )),
                              (_MenuButton(
                                icon: Icons.calendar_today,
                                label: 'Consultas',
                                onTap: () =>
                                    _navigateToPage(const ConsultaPageView()),
                                color: Colors.green,
                              )),
                              (_MenuButton(
                                icon: Icons.attach_money,
                                label: 'Despesas',
                                onTap: () =>
                                    _navigateToPage(const DespesasPageView()),
                                color: Colors.red,
                              )),
                              (_MenuButton(
                                icon: Icons.notifications,
                                label: 'Lembretes',
                                onTap: () =>
                                    _navigateToPage(const LembretesPageView()),
                                color: Colors.orange,
                              )),
                              (_MenuButton(
                                icon: Icons.medical_services,
                                label: 'Medicamentos',
                                onTap: () => _navigateToPage(
                                    const MedicamentosPageView()),
                                color: Colors.purple,
                              )),
                              (_MenuButton(
                                icon: Icons.vaccines,
                                label: 'Vacinas',
                                onTap: () =>
                                    _navigateToPage(const VacinaPageView()),
                                color: Colors.teal,
                              )),
                            ];
                            return menuItems[index];
                          },
                        ),
                      ],
                    ),
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

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
