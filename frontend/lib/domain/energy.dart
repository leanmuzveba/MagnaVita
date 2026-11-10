import 'activity.dart' show bmr;
import 'body.dart';

/// Resting energy (BMR, Mifflin-St Jeor) in kcal a day for an adult with
/// height, age, sex and a weight; null when something is missing or under 18.
double? restingEnergy(BodyProfile profile, double? weightKg, DateTime today) {
  final age = profile.ageOn(today);
  final h = profile.heightCm;
  final sex = profile.sex;
  if (weightKg == null || h == null || sex == null || age == null || age < 18) return null;
  return bmr(weightKg: weightKg, heightCm: h, age: age, sex: sex);
}
