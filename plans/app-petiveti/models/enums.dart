enum AnimalSex {
  male('Macho'),
  female('Fêmea');

  final String description;
  const AnimalSex(this.description);
}

enum AnimalSpecies {
  dog('Cachorro'),
  cat('Gato');

  final String description;
  const AnimalSpecies(this.description);
}

enum ExamType {
  blood('Exame de Sangue'),
  urine('Exame de Urina'),
  feces('Exame de Fezes'),
  ultrasound('Ultrassom'),
  xray('Raio-X'),
  electrocardiogram('Eletrocardiograma');

  final String description;
  const ExamType(this.description);
}

enum PetSize {
  small('Pequeno'),
  medium('Médio'),
  large('Grande');

  final String description;
  const PetSize(this.description);
}

enum VaccinationStatus {
  upToDate('Em dia'),
  pending('Pendente'),
  overdue('Atrasada');

  final String description;
  const VaccinationStatus(this.description);
}

enum AppointmentType {
  routine('Consulta de Rotina'),
  emergency('Emergência'),
  vaccination('Vacinação'),
  surgery('Cirurgia'),
  grooming('Banho e Tosa');

  final String description;
  const AppointmentType(this.description);
}
