# Spray Mix Calculator - Usage Examples

## Example 1: Single Product Application

### Scenario
Farmer needs to apply herbicide on 10 hectares of soybeans.

### Inputs
```
Area: 10 ha
Application Rate: 200 L/ha
Tank Capacity: 2000 L

Product 1:
  Name: Glifosato 480 g/L
  Dose: 2000 mL/ha
  Unit: mL
```

### Calculation Steps
```
1. Total Spray Volume = 10 ha × 200 L/ha = 2000 L

2. Number of Tanks = ceil(2000 L ÷ 2000 L) = 1 tank

3. Product per Tank:
   Herbicida = 2000 mL/ha × (2000 L ÷ 200 L/ha)
             = 2000 mL/ha × 10 ha
             = 20,000 mL (20 L)

4. Water per Tank = 2000 L - 20 L = 1980 L
```

### Results
```
✅ Total Spray Volume: 2000 L
✅ Number of Tanks: 1

Per Tank (2000 L):
  💧 Water: 1980 L
  🧪 Glifosato 480 g/L: 20,000 mL

Total Products:
  🧪 Glifosato 480 g/L: 20,000 mL
```

---

## Example 2: Multiple Products Application

### Scenario
Fungicide + adjuvant application on corn crop.

### Inputs
```
Area: 25 ha
Application Rate: 150 L/ha
Tank Capacity: 2000 L

Product 1:
  Name: Azoxistrobina + Ciproconazol
  Dose: 300 mL/ha
  Unit: mL

Product 2:
  Name: Óleo Mineral (Adjuvante)
  Dose: 500 mL/ha
  Unit: mL
```

### Calculation Steps
```
1. Total Spray Volume = 25 ha × 150 L/ha = 3750 L

2. Number of Tanks = ceil(3750 L ÷ 2000 L) = 2 tanks

3. Product per Tank:
   Fungicida = 300 mL/ha × (2000 L ÷ 150 L/ha)
             = 300 mL/ha × 13.33 ha
             = 4000 mL

   Adjuvante = 500 mL/ha × (2000 L ÷ 150 L/ha)
             = 500 mL/ha × 13.33 ha
             = 6665 mL

4. Water per Tank = 2000 L - 4 L - 6.665 L = 1989.335 L ≈ 1989.3 L

5. Total Water = 1989.3 L × 2 tanks = 3978.6 L
```

### Results
```
✅ Total Spray Volume: 3750 L
✅ Number of Tanks: 2

Per Tank (2000 L):
  💧 Water: 1989.3 L
  🧪 Azoxistrobina + Ciproconazol: 4000 mL
  🧪 Óleo Mineral (Adjuvante): 6665 mL

Total Products:
  🧪 Azoxistrobina + Ciproconazol: 8000 mL
  🧪 Óleo Mineral (Adjuvante): 13330 mL

💡 Application Tips:
  ✓ Volume médio: Uso geral para maioria dos defensivos
  ✓ Ordem de mistura: Pós molháveis → Suspensões → Emulsões → Solúveis
  ✓ Aguarde dissolução completa entre cada produto
  ✓ Complete água até 3/4 do tanque antes de adicionar produtos
  ✓ Mantenha agitação constante durante aplicação
```

---

## Example 3: Foliar Fertilizer (Solid Product)

### Scenario
Foliar fertilizer application with micronutrients.

### Inputs
```
Area: 50 ha
Application Rate: 100 L/ha (low volume)
Tank Capacity: 600 L

Product 1:
  Name: Fertilizante Foliar (Boro + Zinco)
  Dose: 1.5 kg/ha
  Unit: kg

Product 2:
  Name: Espalhante Adesivo
  Dose: 100 mL/ha
  Unit: mL
```

### Calculation Steps
```
1. Total Spray Volume = 50 ha × 100 L/ha = 5000 L

2. Number of Tanks = ceil(5000 L ÷ 600 L) = 9 tanks

3. Product per Tank:
   Fertilizante = 1.5 kg/ha × (600 L ÷ 100 L/ha)
                = 1.5 kg/ha × 6 ha
                = 9 kg

   Espalhante = 100 mL/ha × (600 L ÷ 100 L/ha)
              = 100 mL/ha × 6 ha
              = 600 mL

4. Water per Tank = 600 L - 0.6 L = 599.4 L
   (kg doesn't affect volume calculation)

5. Total Products:
   Fertilizante = 9 kg × 9 tanks = 81 kg
   Espalhante = 600 mL × 9 tanks = 5400 mL
```

### Results
```
✅ Total Spray Volume: 5000 L
✅ Number of Tanks: 9

Per Tank (600 L):
  💧 Water: 599.4 L
  🧪 Fertilizante Foliar (Boro + Zinco): 9 kg
  🧪 Espalhante Adesivo: 600 mL

Total Products:
  🧪 Fertilizante Foliar (Boro + Zinco): 81 kg
  🧪 Espalhante Adesivo: 5400 mL

💡 Application Tips:
  ✓ Volume baixo: Ideal para herbicidas pós-emergentes
  ✓ Use pontas de pulverização adequadas para baixo volume
  ✓ Ordem de mistura: Pós molháveis → Suspensões → Emulsões → Solúveis
  ✓ Aguarde dissolução completa entre cada produto
  ✓ Muitos tanques: Considere aumentar volume de aplicação se possível
```

---

## Example 4: Large Scale Cotton Application

### Scenario
Insecticide + defoliant application for cotton harvest preparation.

### Inputs
```
Area: 100 ha
Application Rate: 250 L/ha
Tank Capacity: 3000 L

Product 1:
  Name: Inseticida Piretróide
  Dose: 150 mL/ha
  Unit: mL

Product 2:
  Name: Desfolhante (Ethephon)
  Dose: 2 L/ha
  Unit: L

Product 3:
  Name: Adjuvante Não Iônico
  Dose: 200 mL/ha
  Unit: mL
```

### Calculation Steps
```
1. Total Spray Volume = 100 ha × 250 L/ha = 25,000 L

2. Number of Tanks = ceil(25,000 L ÷ 3000 L) = 9 tanks

3. Product per Tank:
   Inseticida = 150 mL/ha × (3000 L ÷ 250 L/ha)
              = 150 mL/ha × 12 ha
              = 1800 mL

   Desfolhante = 2 L/ha × (3000 L ÷ 250 L/ha)
               = 2 L/ha × 12 ha
               = 24 L

   Adjuvante = 200 mL/ha × (3000 L ÷ 250 L/ha)
             = 200 mL/ha × 12 ha
             = 2400 mL

4. Water per Tank = 3000 L - 1.8 L - 24 L - 2.4 L
                  = 2971.8 L

5. Total Products:
   Inseticida = 1800 mL × 9 = 16,200 mL
   Desfolhante = 24 L × 9 = 216 L
   Adjuvante = 2400 mL × 9 = 21,600 mL
```

### Results
```
✅ Total Spray Volume: 25,000 L
✅ Number of Tanks: 9

Per Tank (3000 L):
  💧 Water: 2971.8 L
  🧪 Inseticida Piretróide: 1800 mL
  🧪 Desfolhante (Ethephon): 24 L
  🧪 Adjuvante Não Iônico: 2400 mL

Total Products:
  🧪 Inseticida Piretróide: 16,200 mL (16.2 L)
  🧪 Desfolhante (Ethephon): 216 L
  🧪 Adjuvante Não Iônico: 21,600 mL (21.6 L)

💡 Application Tips:
  ✓ Volume alto: Melhor cobertura, indicado para fungicidas/inseticidas
  ✓ Ordem de mistura: Pós molháveis → Suspensões → Emulsões → Solúveis
  ✓ Aguarde dissolução completa entre cada produto
  ✓ Complete água até 3/4 do tanque antes de adicionar produtos
  ✓ Tanque grande: Verifique calibração de bomba e bicos regularmente
  ✓ Muitos tanques: Considere aumentar volume de aplicação se possível
```

---

## Volume Guidelines

### Application Rate Ranges

| Volume Category | L/ha Range | Typical Use Case |
|----------------|-----------|------------------|
| **Very Low** | 30-80 | Systemic herbicides (post-emergence) |
| **Low** | 80-150 | Contact herbicides, growth regulators |
| **Medium** | 150-250 | General purpose (most pesticides) |
| **High** | 250-400 | Fungicides, contact insecticides |
| **Very High** | 400-600 | Maximum coverage needs |

### Droplet Size Recommendations

- **Fine** (100-200 µm): Systemic products, low volume
- **Medium** (200-300 µm): General purpose applications
- **Coarse** (300-400 µm): Contact products, drift reduction
- **Very Coarse** (>400 µm): Maximum drift control

### Nozzle Color Codes (ISO Standard)

| Color | Flow Rate | Typical Pressure |
|-------|-----------|-----------------|
| 🟠 Orange | 0.4 L/min | 3 bar |
| 🟢 Green | 0.6 L/min | 3 bar |
| 🟡 Yellow | 0.8 L/min | 3 bar |
| 🔴 Red | 1.0 L/min | 3 bar |
| 🔵 Blue | 1.2 L/min | 3 bar |
| ⚫ Black | 1.6 L/min | 3 bar |

---

## Safety and Best Practices

### Pre-Application Checklist
- ✅ Check weather forecast (avoid rain, wind >10 km/h)
- ✅ Calibrate sprayer equipment
- ✅ Clean tank from previous applications
- ✅ Wear proper PPE (gloves, goggles, respirator)
- ✅ Prepare only what you need (avoid leftovers)
- ✅ Have clean water source available

### During Application
- ✅ Maintain constant agitation
- ✅ Monitor pressure and flow rate
- ✅ Check nozzles for clogging
- ✅ Apply in ideal conditions (before 10h or after 16h)
- ✅ Avoid temperature >30°C
- ✅ Avoid relative humidity <50%

### Post-Application
- ✅ Triple rinse tank and system
- ✅ Dispose rinse water in field (diluted)
- ✅ Clean PPE and equipment
- ✅ Store containers properly
- ✅ Record application details
- ✅ Respect re-entry interval (REI)

---

**Note**: All examples use realistic agricultural scenarios and follow industry best practices for pesticide application.
