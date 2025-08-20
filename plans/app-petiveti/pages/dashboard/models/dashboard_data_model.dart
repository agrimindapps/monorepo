class Pet {
  final String id;
  final String nome;
  final String especie;
  final String raca;
  final int idade;
  final double peso;
  final String foto;

  const Pet({
    required this.id,
    required this.nome,
    required this.especie,
    required this.raca,
    required this.idade,
    required this.peso,
    required this.foto,
  });

  String get especieIconName {
    switch (especie.toLowerCase()) {
      case 'cachorro':
        return 'pets';
      case 'gato':
        return 'catching_pokemon';
      case 'ave':
        return 'flutter_dash';
      case 'peixe':
        return 'water';
      default:
        return 'pets';
    }
  }
}

class PesoData {
  final DateTime data;
  final double peso;

  const PesoData({
    required this.data,
    required this.peso,
  });
}

class ConsultaData {
  final DateTime data;
  final String veterinario;
  final String motivo;
  final String diagnostico;
  final double valor;

  const ConsultaData({
    required this.data,
    required this.veterinario,
    required this.motivo,
    required this.diagnostico,
    required this.valor,
  });

  String get dataFormatada => '${data.day}/${data.month}/${data.year}';
}

class VacinaData {
  final String nome;
  final DateTime data;
  final DateTime proxima;
  final String status;

  const VacinaData({
    required this.nome,
    required this.data,
    required this.proxima,
    required this.status,
  });

  String get dataFormatada => '${data.day}/${data.month}/${data.year}';
  String get proximaFormatada => '${proxima.day}/${proxima.month}/${proxima.year}';
  
  int get diasRestantes => proxima.difference(DateTime.now()).inDays;
  
  bool get isVencida => diasRestantes < 0;
  bool get isPendente => status == 'Pendente';
}

class DespesaData {
  final String categoria;
  final DateTime data;
  final double valor;

  const DespesaData({
    required this.categoria,
    required this.data,
    required this.valor,
  });
}

class MedicamentoData {
  final String nome;
  final String dosagem;
  final String frequencia;
  final DateTime inicio;
  final DateTime fim;

  const MedicamentoData({
    required this.nome,
    required this.dosagem,
    required this.frequencia,
    required this.inicio,
    required this.fim,
  });

  int get diasRestantes => fim.difference(DateTime.now()).inDays;
  int get totalDias => fim.difference(inicio).inDays;
  int get diasPassados => totalDias - diasRestantes;
  double get progresso => diasPassados / totalDias;

  String get inicioFormatado => '${inicio.day}/${inicio.month}';
  String get fimFormatado => '${fim.day}/${fim.month}';
}

class DashboardRepository {
  static List<Pet> getPets() {
    return const [
      Pet(
        id: '1',
        nome: 'Max',
        especie: 'Cachorro',
        raca: 'Golden Retriever',
        idade: 3,
        peso: 32.5,
        foto: 'https://images.unsplash.com/photo-1552053831-71594a27632d?ixlib=rb-4.0.3',
      ),
      Pet(
        id: '2',
        nome: 'Luna',
        especie: 'Gato',
        raca: 'Siamês',
        idade: 2,
        peso: 4.3,
        foto: 'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?ixlib=rb-4.0.3',
      ),
      Pet(
        id: '3',
        nome: 'Bob',
        especie: 'Cachorro',
        raca: 'Bulldog',
        idade: 5,
        peso: 24.8,
        foto: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?ixlib=rb-4.0.3',
      ),
    ];
  }

  static List<ConsultaData> getConsultas() {
    return [
      ConsultaData(
        data: DateTime(2023, 9, 15),
        veterinario: 'Dr. Carlos Silva',
        motivo: 'Consulta de rotina',
        diagnostico: 'Saúde normal',
        valor: 150.0,
      ),
      ConsultaData(
        data: DateTime(2023, 11, 22),
        veterinario: 'Dra. Marta Gomes',
        motivo: 'Vermifugação',
        diagnostico: 'Tratamento preventivo',
        valor: 180.0,
      ),
      ConsultaData(
        data: DateTime(2024, 2, 5),
        veterinario: 'Dr. Carlos Silva',
        motivo: 'Vacina',
        diagnostico: 'Vacinação V10',
        valor: 220.0,
      ),
    ];
  }

  static List<VacinaData> getVacinas() {
    return [
      VacinaData(
        nome: 'V8',
        data: DateTime(2023, 2, 10),
        proxima: DateTime(2024, 2, 10),
        status: 'Completo',
      ),
      VacinaData(
        nome: 'Raiva',
        data: DateTime(2023, 6, 15),
        proxima: DateTime(2024, 6, 15),
        status: 'Completo',
      ),
      VacinaData(
        nome: 'Giárdia',
        data: DateTime(2023, 8, 20),
        proxima: DateTime(2024, 3, 20),
        status: 'Pendente',
      ),
    ];
  }

  static List<DespesaData> getDespesas() {
    return [
      DespesaData(
        categoria: 'Consulta',
        data: DateTime(2024, 2, 5),
        valor: 220.0,
      ),
      DespesaData(
        categoria: 'Ração',
        data: DateTime(2024, 2, 10),
        valor: 180.0,
      ),
      DespesaData(
        categoria: 'Medicamento',
        data: DateTime(2024, 2, 15),
        valor: 95.0,
      ),
      DespesaData(
        categoria: 'Consulta',
        data: DateTime(2023, 11, 22),
        valor: 180.0,
      ),
      DespesaData(
        categoria: 'Ração',
        data: DateTime(2023, 12, 10),
        valor: 170.0,
      ),
      DespesaData(
        categoria: 'Brinquedos',
        data: DateTime(2024, 1, 5),
        valor: 60.0,
      ),
    ];
  }

  static List<MedicamentoData> getMedicamentos() {
    return [
      MedicamentoData(
        nome: 'Antibiótico Cefadroxil',
        dosagem: '250mg',
        frequencia: '2x ao dia',
        inicio: DateTime(2024, 2, 28),
        fim: DateTime(2024, 3, 10),
      ),
      MedicamentoData(
        nome: 'Anti-inflamatório Rimadyl',
        dosagem: '100mg',
        frequencia: '1x ao dia',
        inicio: DateTime(2024, 3, 1),
        fim: DateTime(2024, 3, 8),
      ),
    ];
  }

  static List<PesoData> getHistoricoPeso() {
    return [
      PesoData(data: DateTime(2023, 9, 10), peso: 31.2),
      PesoData(data: DateTime(2023, 10, 15), peso: 32.8),
      PesoData(data: DateTime(2023, 11, 20), peso: 33.1),
      PesoData(data: DateTime(2023, 12, 25), peso: 32.5),
      PesoData(data: DateTime(2024, 1, 30), peso: 33.2),
      PesoData(data: DateTime(2024, 2, 15), peso: 32.6),
      PesoData(data: DateTime(2024, 3, 5), peso: 32.5),
    ];
  }
}