enum AnimalSpecies {
  dog,
  cat,
  bird,
  rabbit,
  hamster,
  guineaPig,
  ferret,
  reptile,
  fish,
  other,
}

enum AnimalGender {
  male,
  female,
  neuteredMale,
  spayedFemale,
  unknown,
}

enum AnimalSize {
  tiny,    // <2kg
  small,   // 2-10kg
  medium,  // 10-25kg  
  large,   // 25-40kg
  giant,   // >40kg
  unknown,
}

extension AnimalSpeciesExtension on AnimalSpecies {
  String toLowerCase() {
    return toString().split('.').last.toLowerCase();
  }

  String get displayName {
    switch (this) {
      case AnimalSpecies.dog:
        return 'Cachorro';
      case AnimalSpecies.cat:
        return 'Gato';
      case AnimalSpecies.bird:
        return 'Ave';
      case AnimalSpecies.rabbit:
        return 'Coelho';
      case AnimalSpecies.hamster:
        return 'Hamster';
      case AnimalSpecies.guineaPig:
        return 'Porquinho-da-índia';
      case AnimalSpecies.ferret:
        return 'Furão';
      case AnimalSpecies.reptile:
        return 'Réptil';
      case AnimalSpecies.fish:
        return 'Peixe';
      case AnimalSpecies.other:
        return 'Outro';
    }
  }

  static AnimalSpecies fromString(String value) {
    switch (value.toLowerCase()) {
      case 'dog':
      case 'cachorro':
        return AnimalSpecies.dog;
      case 'cat':
      case 'gato':
        return AnimalSpecies.cat;
      case 'bird':
      case 'ave':
        return AnimalSpecies.bird;
      case 'rabbit':
      case 'coelho':
        return AnimalSpecies.rabbit;
      case 'hamster':
        return AnimalSpecies.hamster;
      case 'guinea_pig':
      case 'guineapig':
      case 'porquinho-da-índia':
        return AnimalSpecies.guineaPig;
      case 'ferret':
      case 'furão':
        return AnimalSpecies.ferret;
      case 'reptile':
      case 'réptil':
        return AnimalSpecies.reptile;
      case 'fish':
      case 'peixe':
        return AnimalSpecies.fish;
      default:
        return AnimalSpecies.other;
    }
  }
}

extension AnimalGenderExtension on AnimalGender {
  String toLowerCase() {
    return toString().split('.').last.toLowerCase();
  }

  String get displayName {
    switch (this) {
      case AnimalGender.male:
        return 'Macho';
      case AnimalGender.female:
        return 'Fêmea';
      case AnimalGender.neuteredMale:
        return 'Macho Castrado';
      case AnimalGender.spayedFemale:
        return 'Fêmea Castrada';
      case AnimalGender.unknown:
        return 'Não Informado';
    }
  }

  static AnimalGender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
      case 'macho':
        return AnimalGender.male;
      case 'female':
      case 'fêmea':
        return AnimalGender.female;
      case 'neutered_male':
      case 'neuteredmale':
      case 'macho castrado':
        return AnimalGender.neuteredMale;
      case 'spayed_female':
      case 'spayedfemale':
      case 'fêmea castrada':
        return AnimalGender.spayedFemale;
      default:
        return AnimalGender.unknown;
    }
  }
}

extension AnimalSizeExtension on AnimalSize {
  String get displayName {
    switch (this) {
      case AnimalSize.tiny:
        return 'Mini (< 2kg)';
      case AnimalSize.small:
        return 'Pequeno (2-10kg)';
      case AnimalSize.medium:
        return 'Médio (10-25kg)';
      case AnimalSize.large:
        return 'Grande (25-40kg)';
      case AnimalSize.giant:
        return 'Gigante (> 40kg)';
      case AnimalSize.unknown:
        return 'Não Informado';
    }
  }

  static AnimalSize fromString(String value) {
    switch (value.toLowerCase()) {
      case 'tiny':
      case 'mini':
        return AnimalSize.tiny;
      case 'small':
      case 'pequeno':
        return AnimalSize.small;
      case 'medium':
      case 'médio':
        return AnimalSize.medium;
      case 'large':
      case 'grande':
        return AnimalSize.large;
      case 'giant':
      case 'gigante':
        return AnimalSize.giant;
      default:
        return AnimalSize.unknown;
    }
  }
}