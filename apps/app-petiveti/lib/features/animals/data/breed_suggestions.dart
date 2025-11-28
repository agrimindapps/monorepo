import '../domain/entities/animal_enums.dart';

/// Blood types commonly used for pets
const bloodTypes = [
  'DEA 1.1+',
  'DEA 1.1-',
  'DEA 1.2+',
  'DEA 1.2-',
  'A',
  'B',
  'AB',
  'Não identificado',
];

/// Dog blood types
const dogBloodTypes = [
  'DEA 1.1+',
  'DEA 1.1-',
  'DEA 1.2+',
  'DEA 1.2-',
  'DEA 3',
  'DEA 4',
  'DEA 5',
  'DEA 7',
  'Não identificado',
];

/// Cat blood types
const catBloodTypes = ['A', 'B', 'AB', 'Não identificado'];

/// Dog breeds - most popular in Brazil
const dogBreeds = [
  'SRD (Sem Raça Definida)',
  'Labrador Retriever',
  'Golden Retriever',
  'Pastor Alemão',
  'Bulldog Francês',
  'Bulldog Inglês',
  'Poodle',
  'Poodle Toy',
  'Yorkshire Terrier',
  'Shih Tzu',
  'Maltês',
  'Lhasa Apso',
  'Pug',
  'Chihuahua',
  'Pinscher Miniatura',
  'Dachshund (Salsicha)',
  'Border Collie',
  'Beagle',
  'Husky Siberiano',
  'Rottweiler',
  'Doberman',
  'Boxer',
  'Pit Bull',
  'American Staffordshire Terrier',
  'American Bully',
  'Cocker Spaniel',
  'Cocker Spaniel Inglês',
  'Cavalier King Charles Spaniel',
  'Schnauzer',
  'Schnauzer Miniatura',
  'Akita Inu',
  'Shiba Inu',
  'Chow Chow',
  'Shar-pei',
  'Dálmata',
  'São Bernardo',
  'Bernese Mountain Dog',
  'Terra Nova',
  'Dogue Alemão',
  'Pastor Belga',
  'Pastor de Shetland',
  'Pastor Australiano',
  'Jack Russell Terrier',
  'Bichon Frisé',
  'Spitz Alemão (Lulu)',
  'Samoieda',
  'Weimaraner',
  'Pointer Inglês',
  'Braco Alemão',
  'Fila Brasileiro',
  'Vira-lata',
  'Mestiço',
  'Outra',
];

/// Cat breeds - most popular in Brazil
const catBreeds = [
  'SRD (Sem Raça Definida)',
  'Persa',
  'Siamês',
  'Maine Coon',
  'Ragdoll',
  'Bengal',
  'Sphynx',
  'British Shorthair',
  'Scottish Fold',
  'Angorá',
  'Himalaia',
  'Exótico',
  'Burmês',
  'Abissínio',
  'Azul Russo',
  'Norueguês da Floresta',
  'Birmanês',
  'Devon Rex',
  'Cornish Rex',
  'Somali',
  'Tonquinês',
  'American Shorthair',
  'Oriental',
  'Chartreux',
  'Manx',
  'Munchkin',
  'Savannah',
  'Egyptian Mau',
  'Ocicat',
  'Balinês',
  'Vira-lata',
  'Mestiço',
  'Outra',
];

/// Bird breeds/species
const birdBreeds = [
  'SRD (Sem Raça Definida)',
  'Calopsita',
  'Periquito Australiano',
  'Canário',
  'Agapornis (Lovebird)',
  'Papagaio',
  'Arara',
  'Cacatua',
  'Ring Neck',
  'Mandarim',
  'Diamante de Gould',
  'Curió',
  'Trinca-ferro',
  'Sabiá',
  'Azulão',
  'Coleiro',
  'Pixoxó',
  'Bicudo',
  'Codorna',
  'Pomba',
  'Galinha D\'Angola',
  'Faisão',
  'Pavão',
  'Maritaca',
  'Jandaia',
  'Outra',
];

/// Rabbit breeds
const rabbitBreeds = [
  'SRD (Sem Raça Definida)',
  'Mini Rex',
  'Holandês',
  'Mini Lop',
  'Holland Lop',
  'Lion Head (Cabeça de Leão)',
  'Angorá',
  'Fuzzy Lop',
  'Netherland Dwarf',
  'Mini Coelho',
  'Gigante de Flandres',
  'Nova Zelândia',
  'Californiano',
  'Rex',
  'Hotot',
  'Polonês',
  'Teddy Dwarf',
  'Outra',
];

/// Hamster breeds
const hamsterBreeds = [
  'SRD (Sem Raça Definida)',
  'Sírio (Dourado)',
  'Anão Russo',
  'Anão Russo Campbells',
  'Anão Russo Winter White',
  'Roborovski',
  'Chinês',
  'Outra',
];

/// Guinea pig breeds
const guineaPigBreeds = [
  'SRD (Sem Raça Definida)',
  'Americano (Pelo Curto)',
  'Abissínio',
  'Peruano',
  'Sheltie',
  'Teddy',
  'Rex',
  'Skinny (Sem Pelo)',
  'Baldwin',
  'Coronet',
  'Texel',
  'Merino',
  'Alpaca',
  'Outra',
];

/// Ferret breeds (actually color variations)
const ferretBreeds = [
  'SRD (Sem Raça Definida)',
  'Sable',
  'Albino',
  'Silver',
  'Black Sable',
  'Champagne',
  'Chocolate',
  'Cinnamon',
  'Blaze',
  'Panda',
  'Dark-Eyed White (DEW)',
  'Outra',
];

/// Reptile species
const reptileBreeds = [
  'SRD (Sem Raça Definida)',
  'Tigre d\'água',
  'Jabuti',
  'Cágado',
  'Tartaruga',
  'Iguana',
  'Gecko Leopardo',
  'Dragão Barbudo',
  'Corn Snake',
  'Ball Python',
  'Jiboia',
  'Teiú',
  'Calango',
  'Lagarto Tegu',
  'Camaleão',
  'Pogona',
  'Outra',
];

/// Fish species
const fishBreeds = [
  'SRD (Sem Raça Definida)',
  'Betta',
  'Guppy',
  'Neon',
  'Acará Disco',
  'Acará Bandeira',
  'Tetra',
  'Molinésia',
  'Platy',
  'Espada',
  'Kinguio (Goldfish)',
  'Carpa Koi',
  'Oscar',
  'Ciclídeo',
  'Corydora',
  'Pleco',
  'Paulistinha (Zebrafish)',
  'Barbo',
  'Rasbora',
  'Labeo',
  'Outra',
];

/// Other pets breeds
const otherBreeds = [
  'SRD (Sem Raça Definida)',
  'Chinchila',
  'Esquilo da Mongólia (Gerbil)',
  'Degú',
  'Ratazana',
  'Camundongo',
  'Porco-espinho Africano (Ouriço)',
  'Sugar Glider',
  'Mini Pig',
  'Cabra Anã',
  'Ovelha',
  'Cavalo',
  'Pônei',
  'Burro',
  'Vaca',
  'Outra',
];

/// Get breeds for a specific species
List<String> getBreedsForSpecies(AnimalSpecies species) {
  switch (species) {
    case AnimalSpecies.dog:
      return dogBreeds;
    case AnimalSpecies.cat:
      return catBreeds;
    case AnimalSpecies.bird:
      return birdBreeds;
    case AnimalSpecies.rabbit:
      return rabbitBreeds;
    case AnimalSpecies.hamster:
      return hamsterBreeds;
    case AnimalSpecies.guineaPig:
      return guineaPigBreeds;
    case AnimalSpecies.ferret:
      return ferretBreeds;
    case AnimalSpecies.reptile:
      return reptileBreeds;
    case AnimalSpecies.fish:
      return fishBreeds;
    case AnimalSpecies.other:
      return otherBreeds;
  }
}

/// Get blood types for a specific species
List<String> getBloodTypesForSpecies(AnimalSpecies species) {
  switch (species) {
    case AnimalSpecies.dog:
      return dogBloodTypes;
    case AnimalSpecies.cat:
      return catBloodTypes;
    default:
      return bloodTypes;
  }
}

/// Common allergies for pets
const commonAllergies = [
  'Frango',
  'Carne bovina',
  'Peixe',
  'Ovo',
  'Leite',
  'Trigo',
  'Soja',
  'Milho',
  'Glúten',
  'Pulga',
  'Pólen',
  'Ácaros',
  'Mofo',
  'Picada de inseto',
  'Medicamento',
  'Perfume',
  'Produto de limpeza',
  'Grama',
  'Corante alimentar',
  'Conservantes',
];
