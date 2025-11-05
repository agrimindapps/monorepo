# Documentação dos Modelos Hive - APP CALCULEI

> Documentação gerada automaticamente em /private/tmp
> Data de geração: $(date +"%d/%m/%Y %H:%M:%S")

## Índice

- [CashVsInstallmentCalculationModel](#cashvsinstallmentcalculationmodel)
- [EmergencyReserveCalculationModel](#emergencyreservecalculationmodel)
- [NetSalaryCalculationModel](#netsalarycalculationmodel)
- [OvertimeCalculationModel](#overtimecalculationmodel)
- [ThirteenthSalaryCalculationModel](#thirteenthsalarycalculationmodel)
- [UnemploymentInsuranceCalculationModel](#unemploymentinsurancecalculationmodel)
- [VacationCalculationModel](#vacationcalculationmodel)

---

## CashVsInstallmentCalculationModel

**TypeId**: `15`  
**Arquivo**: `app-calculei/lib/features/cash_vs_installment_calculator/data/models/cash_vs_installment_calculation_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `cashPrice` | `double` | ✗ |
| 2 | `installmentPrice` | `double` | ✗ |
| 3 | `numberOfInstallments` | `int` | ✗ |
| 4 | `monthlyInterestRate` | `double` | ✗ |
| 5 | `totalInstallmentPrice` | `double` | ✗ |
| 6 | `implicitRate` | `double` | ✗ |
| 7 | `presentValueOfInstallments` | `double` | ✗ |
| 8 | `bestOption` | `String` | ✗ |
| 9 | `savingsOrAdditionalCost` | `double` | ✗ |
| 10 | `calculatedAt` | `DateTime` | ✗ |

---

## EmergencyReserveCalculationModel

**TypeId**: `14`  
**Arquivo**: `app-calculei/lib/features/emergency_reserve_calculator/data/models/emergency_reserve_calculation_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `monthlyExpenses` | `double` | ✗ |
| 2 | `extraExpenses` | `double` | ✗ |
| 3 | `desiredMonths` | `int` | ✗ |
| 4 | `monthlySavings` | `double` | ✗ |
| 5 | `totalMonthlyExpenses` | `double` | ✗ |
| 6 | `totalReserveAmount` | `double` | ✗ |
| 7 | `constructionYears` | `int` | ✗ |
| 8 | `constructionMonths` | `int` | ✗ |
| 9 | `category` | `String` | ✗ |
| 10 | `categoryDescription` | `String` | ✗ |
| 11 | `calculatedAt` | `DateTime` | ✗ |

---

## NetSalaryCalculationModel

**TypeId**: `13`  
**Arquivo**: `app-calculei/lib/features/net_salary_calculator/data/models/net_salary_calculation_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `grossSalary` | `double` | ✗ |
| 2 | `dependents` | `int` | ✗ |
| 3 | `transportationVoucher` | `double` | ✗ |
| 4 | `healthInsurance` | `double` | ✗ |
| 5 | `otherDiscounts` | `double` | ✗ |
| 6 | `inssDiscount` | `double` | ✗ |
| 7 | `irrfDiscount` | `double` | ✗ |
| 8 | `transportationVoucherDiscount` | `double` | ✗ |
| 9 | `totalDiscounts` | `double` | ✗ |
| 10 | `netSalary` | `double` | ✗ |
| 11 | `inssRate` | `double` | ✗ |
| 12 | `irrfRate` | `double` | ✗ |
| 13 | `irrfCalculationBase` | `double` | ✗ |
| 14 | `calculatedAt` | `DateTime` | ✗ |

---

## OvertimeCalculationModel

**TypeId**: `12`  
**Arquivo**: `app-calculei/lib/features/overtime_calculator/data/models/overtime_calculation_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `grossSalary` | `double` | ✗ |
| 2 | `weeklyHours` | `int` | ✗ |
| 3 | `hours50` | `double` | ✗ |
| 4 | `hours100` | `double` | ✗ |
| 5 | `nightHours` | `double` | ✗ |
| 6 | `nightAdditionalPercentage` | `double` | ✗ |
| 7 | `sundayHolidayHours` | `double` | ✗ |
| 8 | `workDaysMonth` | `int` | ✗ |
| 9 | `dependents` | `int` | ✗ |
| 10 | `monthlyWorkedHours` | `double` | ✗ |
| 11 | `normalHourValue` | `double` | ✗ |
| 12 | `hour50Value` | `double` | ✗ |
| 13 | `hour100Value` | `double` | ✗ |
| 14 | `nightHourValue` | `double` | ✗ |
| 15 | `sundayHolidayHourValue` | `double` | ✗ |
| 16 | `total50` | `double` | ✗ |
| 17 | `total100` | `double` | ✗ |
| 18 | `totalNightAdditional` | `double` | ✗ |
| 19 | `totalSundayHoliday` | `double` | ✗ |
| 20 | `dsrOvertime` | `double` | ✗ |
| 21 | `totalOvertime` | `double` | ✗ |
| 22 | `vacationReflection` | `double` | ✗ |
| 23 | `thirteenthReflection` | `double` | ✗ |
| 24 | `grossTotal` | `double` | ✗ |
| 25 | `inssDiscount` | `double` | ✗ |
| 26 | `inssRate` | `double` | ✗ |
| 27 | `irrfDiscount` | `double` | ✗ |
| 28 | `irrfRate` | `double` | ✗ |
| 29 | `netTotal` | `double` | ✗ |
| 30 | `totalOvertimeHours` | `double` | ✗ |
| 31 | `calculatedAt` | `DateTime` | ✗ |

---

## ThirteenthSalaryCalculationModel

**TypeId**: `11`  
**Arquivo**: `app-calculei/lib/features/thirteenth_salary_calculator/data/models/thirteenth_salary_calculation_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `grossSalary` | `double` | ✗ |
| 2 | `monthsWorked` | `int` | ✗ |
| 3 | `admissionDate` | `DateTime` | ✗ |
| 4 | `calculationDate` | `DateTime` | ✗ |
| 5 | `unjustifiedAbsences` | `int` | ✗ |
| 6 | `isAdvancePayment` | `bool` | ✗ |
| 7 | `dependents` | `int` | ✗ |
| 8 | `consideredMonths` | `int` | ✗ |
| 9 | `valuePerMonth` | `double` | ✗ |
| 10 | `grossThirteenthSalary` | `double` | ✗ |
| 11 | `inssDiscount` | `double` | ✗ |
| 12 | `inssRate` | `double` | ✗ |
| 13 | `irrfDiscount` | `double` | ✗ |
| 14 | `irrfRate` | `double` | ✗ |
| 15 | `irrfBaseCalculation` | `double` | ✗ |
| 16 | `netThirteenthSalary` | `double` | ✗ |
| 17 | `firstInstallment` | `double` | ✗ |
| 18 | `secondInstallment` | `double` | ✗ |
| 19 | `calculatedAt` | `DateTime` | ✗ |

---

## UnemploymentInsuranceCalculationModel

**TypeId**: `16`  
**Arquivo**: `app-calculei/lib/features/unemployment_insurance_calculator/data/models/unemployment_insurance_calculation_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `averageSalary` | `double` | ✗ |
| 2 | `workMonths` | `int` | ✗ |
| 3 | `timesReceived` | `int` | ✗ |
| 4 | `dismissalDate` | `DateTime` | ✗ |
| 5 | `installmentValue` | `double` | ✗ |
| 6 | `numberOfInstallments` | `int` | ✗ |
| 7 | `totalValue` | `double` | ✗ |
| 8 | `deadlineToRequest` | `DateTime` | ✗ |
| 9 | `paymentStart` | `DateTime` | ✗ |
| 10 | `paymentEnd` | `DateTime` | ✗ |
| 11 | `paymentSchedule` | `List<DateTime>` | ✗ |
| 12 | `eligible` | `bool` | ✗ |
| 13 | `ineligibilityReason` | `String` | ✗ |
| 14 | `requiredCarencyMonths` | `int` | ✗ |
| 15 | `calculatedAt` | `DateTime` | ✗ |

---

## VacationCalculationModel

**TypeId**: `10`  
**Arquivo**: `app-calculei/lib/features/vacation_calculator/data/models/vacation_calculation_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `grossSalary` | `double` | ✗ |
| 2 | `vacationDays` | `int` | ✗ |
| 3 | `sellVacationDays` | `bool` | ✗ |
| 4 | `baseValue` | `double` | ✗ |
| 5 | `constitutionalBonus` | `double` | ✗ |
| 6 | `soldDaysValue` | `double` | ✗ |
| 7 | `grossTotal` | `double` | ✗ |
| 8 | `inssDiscount` | `double` | ✗ |
| 9 | `irDiscount` | `double` | ✗ |
| 10 | `netTotal` | `double` | ✗ |
| 11 | `calculatedAt` | `DateTime` | ✗ |

---

