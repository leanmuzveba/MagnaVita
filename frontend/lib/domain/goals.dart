import 'plan.dart';

/// What you mainly want from MagnaVita (asked at setup).
enum MainGoal { loseWeight, maintain, buildMuscle, getFitter, fasting }

/// Your answers from setup; every one is optional.
class UserGoals {
  const UserGoals({this.main, this.mealsPerDay, this.trainingDays, this.level, this.equipment});

  final MainGoal? main;
  final int? mealsPerDay;
  final int? trainingDays; // per week, 0 = none
  final PlanLevel? level;
  final PlanEquipment? equipment;

  UserGoals copyWith({
    MainGoal? main,
    int? mealsPerDay,
    int? trainingDays,
    PlanLevel? level,
    PlanEquipment? equipment,
  }) => UserGoals(
    main: main ?? this.main,
    mealsPerDay: mealsPerDay ?? this.mealsPerDay,
    trainingDays: trainingDays ?? this.trainingDays,
    level: level ?? this.level,
    equipment: equipment ?? this.equipment,
  );

  Map<String, Object?> toJson() => {
    'main': main?.name,
    'mealsPerDay': mealsPerDay,
    'trainingDays': trainingDays,
    'level': level?.name,
    'equipment': equipment?.name,
  };

  factory UserGoals.fromJson(Map<String, dynamic> j) => UserGoals(
    main: MainGoal.values.asNameMap()[j['main']],
    mealsPerDay: (j['mealsPerDay'] as num?)?.toInt(),
    trainingDays: (j['trainingDays'] as num?)?.toInt(),
    level: PlanLevel.values.asNameMap()[j['level']],
    equipment: PlanEquipment.values.asNameMap()[j['equipment']],
  );
}

/// The workout-planner goal that suits your main goal.
PlanGoal planGoalFor(MainGoal? main) => switch (main) {
  MainGoal.loseWeight => PlanGoal.fatLoss,
  MainGoal.buildMuscle => PlanGoal.muscle,
  MainGoal.getFitter => PlanGoal.endurance,
  _ => PlanGoal.strength,
};

/// Planner days (3–5) from how often you said you train.
int planDaysFor(int? trainingDays) => (trainingDays ?? 3).clamp(3, 5);

/// Meals-per-day choices at setup.
const mealsPerDayOptions = [2, 3, 4, 5];

/// Training-days choices at setup.
const trainingDayOptions = [0, 2, 3, 4, 5, 6];
