import 'activity.dart';
import 'workout.dart';

enum PlanGoal { strength, muscle, endurance, fatLoss }

enum PlanLevel { beginner, intermediate, expert } // the library's own levels

enum PlanEquipment { gym, dumbbells, bodyweight }

/// What a day trains; each split gives every day a different focus.
enum PlanFocus { push, pull, legs, chestTriceps, backBiceps, shouldersCore, chest, back, shoulders, armsCore }

/// Muscles (the library's names) a day works, one per exercise.
const _slots = <PlanFocus, List<String>>{
  PlanFocus.push: ['chest', 'chest', 'shoulders', 'shoulders', 'triceps'],
  PlanFocus.pull: ['lats', 'middle back', 'lats', 'biceps', 'biceps'],
  PlanFocus.legs: ['quadriceps', 'quadriceps', 'hamstrings', 'glutes', 'calves'],
  PlanFocus.chestTriceps: ['chest', 'chest', 'chest', 'triceps', 'triceps'],
  PlanFocus.backBiceps: ['lats', 'middle back', 'middle back', 'biceps', 'biceps'],
  PlanFocus.shouldersCore: ['shoulders', 'shoulders', 'shoulders', 'traps', 'abdominals', 'abdominals'],
  PlanFocus.chest: ['chest', 'chest', 'chest', 'chest', 'abdominals'],
  PlanFocus.back: ['lats', 'middle back', 'lats', 'middle back', 'lower back'],
  PlanFocus.shoulders: ['shoulders', 'shoulders', 'shoulders', 'shoulders', 'traps'],
  PlanFocus.armsCore: ['biceps', 'biceps', 'triceps', 'triceps', 'abdominals', 'abdominals'],
};

const splits = <int, List<PlanFocus>>{
  3: [PlanFocus.push, PlanFocus.pull, PlanFocus.legs],
  4: [PlanFocus.chestTriceps, PlanFocus.backBiceps, PlanFocus.legs, PlanFocus.shouldersCore],
  5: [PlanFocus.chest, PlanFocus.back, PlanFocus.legs, PlanFocus.shoulders, PlanFocus.armsCore],
};

/// Well-known exercises per muscle, best first; the rest of the library fills in.
const _picks = <String, List<String>>{
  'chest': [
    'Barbell_Bench_Press_-_Medium_Grip', 'Dumbbell_Bench_Press', 'Incline_Dumbbell_Press', 'Leverage_Chest_Press', //
    'Cable_Crossover', 'Dumbbell_Flyes', 'Butterfly', 'Pushups', 'Dips_-_Chest_Version',
  ],
  'lats': ['Wide-Grip_Lat_Pulldown', 'Pullups', 'Chin-Up'],
  'middle back': ['Bent_Over_Barbell_Row', 'Seated_Cable_Rows', 'One-Arm_Dumbbell_Row', 'Bent_Over_Two-Dumbbell_Row'],
  'lower back': ['Barbell_Deadlift', 'Hyperextensions_Back_Extensions', 'Superman'],
  'quadriceps': [
    'Barbell_Squat', 'Leg_Press', 'Dumbbell_Squat', 'Goblet_Squat', 'Dumbbell_Lunges', 'Leg_Extensions', //
    'Bodyweight_Squat', 'Bodyweight_Walking_Lunge',
  ],
  'hamstrings': ['Romanian_Deadlift', 'Lying_Leg_Curls', 'Stiff-Legged_Dumbbell_Deadlift'],
  'glutes': ['Barbell_Hip_Thrust', 'Butt_Lift_Bridge', 'Glute_Kickback'],
  'calves': ['Standing_Calf_Raises', 'Seated_Calf_Raise', 'Calf_Raise_On_A_Dumbbell'],
  'shoulders': [
    'Standing_Military_Press', 'Seated_Dumbbell_Press', 'Machine_Shoulder_Military_Press', 'Side_Lateral_Raise', //
    'Arnold_Dumbbell_Press', 'Face_Pull', 'Reverse_Flyes', 'Front_Dumbbell_Raise', 'Handstand_Push-Ups',
  ],
  'traps': ['Barbell_Shrug', 'Dumbbell_Shrug'],
  'biceps': [
    'Barbell_Curl', 'Dumbbell_Bicep_Curl', 'Hammer_Curls', 'Preacher_Curl', //
    'Cable_Hammer_Curls_-_Rope_Attachment', 'Concentration_Curls',
  ],
  'triceps': [
    'Triceps_Pushdown',
    'Close-Grip_Barbell_Bench_Press',
    'Lying_Triceps_Press',
    'Standing_Dumbbell_Triceps_Extension', //
    'Tricep_Dumbbell_Kickback', 'Bench_Dips', 'Close-Grip_Push-Up_off_of_a_Dumbbell',
  ],
  'abdominals': [
    'Crunches', 'Cable_Crunch', 'Russian_Twist', 'Flat_Bench_Lying_Leg_Raise', 'Dead_Bug', 'Hanging_Leg_Raise', //
    'Ab_Roller',
  ],
};

bool _fits(LibraryExercise x, PlanLevel level, PlanEquipment equipment) =>
    PlanLevel.values.indexWhere((l) => l.name == x.level) <= level.index &&
    switch (equipment) {
      PlanEquipment.gym => true,
      PlanEquipment.dumbbells => const {null, 'body only', 'dumbbell'}.contains(x.equipment),
      PlanEquipment.bodyweight => const {null, 'body only'}.contains(x.equipment),
    };

/// Exercises for [muscle] you can do with [equipment] at [level]: the
/// well-known ones first, then the rest of the library's strength moves.
List<LibraryExercise> exercisesFor(
  List<LibraryExercise> library,
  String muscle,
  PlanLevel level,
  PlanEquipment equipment,
) {
  final byId = {for (final x in library) x.id: x};
  final picks = [
    for (final id in _picks[muscle] ?? const <String>[])
      if (byId[id] case final x? when _fits(x, level, equipment)) x,
  ];
  final ids = {for (final x in picks) x.id};
  return [
    ...picks,
    for (final x in library)
      if (!ids.contains(x.id) && x.category == 'strength' && x.primary.contains(muscle) && _fits(x, level, equipment))
        x,
  ];
}

/// Sets × reps and rest for a goal; the day's first exercise is the big one.
({int sets, int reps}) prescription(PlanGoal goal, PlanLevel level, {required bool first}) {
  final (sets, reps) = switch (goal) {
    PlanGoal.strength => first ? (5, 5) : (4, 6),
    PlanGoal.muscle => first ? (4, 8) : (3, 10),
    PlanGoal.endurance => (3, 15),
    PlanGoal.fatLoss => (3, 12),
  };
  return (sets: level == PlanLevel.beginner && sets > 3 ? 3 : sets, reps: reps);
}

int restFor(PlanGoal goal) => switch (goal) {
  PlanGoal.strength => 150,
  PlanGoal.muscle => 90,
  PlanGoal.endurance => 45,
  PlanGoal.fatLoss => 60,
};

class PlanDay {
  const PlanDay(this.focus, this.exercises);
  final PlanFocus focus;
  final List<Exercise> exercises; // planned sets × reps (no weights; those come from last time)

  /// About how long it takes: ~40 s a set plus [rest] after it, to the next 5 minutes.
  int minutes(int rest) {
    final sets = exercises.fold(0, (n, x) => n + x.sets);
    return sets == 0 ? 0 : ((sets * (40 + rest) / 60) / 5).ceil() * 5;
  }

  Map<String, Object?> toJson() => {
    'focus': focus.name,
    'exercises': [for (final x in exercises) x.toJson()],
  };

  factory PlanDay.fromJson(Map<String, dynamic> j) => PlanDay(PlanFocus.values.byName(j['focus'] as String), [
    for (final x in j['exercises'] as List) Exercise.fromJson(x as Map<String, dynamic>),
  ]);
}

/// A weekly plan: one day per session, done in order, round and round.
class WorkoutPlan {
  const WorkoutPlan({
    required this.goal,
    required this.level,
    required this.equipment,
    required this.days,
    this.next = 0,
    this.weekdays = const [1, 3, 5],
    this.remindAt,
  });

  final PlanGoal goal;
  final PlanLevel level;
  final PlanEquipment equipment;
  final List<PlanDay> days;
  final int next; // the day to do next
  final List<int> weekdays; // when you train: 1 = Monday … 7 = Sunday, sorted
  final int? remindAt; // minutes after midnight to remind you on those days; null = off

  int get rest => restFor(goal);

  WorkoutPlan copyWith({List<PlanDay>? days, int? next, List<int>? weekdays, int? Function()? remindAt}) => WorkoutPlan(
    goal: goal,
    level: level,
    equipment: equipment,
    days: days ?? this.days,
    next: next ?? this.next,
    weekdays: weekdays ?? this.weekdays,
    remindAt: remindAt != null ? remindAt() : this.remindAt,
  );

  /// The next day you train, from [now]'s date on (today counts); null with no days set.
  DateTime? nextSession(DateTime now) {
    final d = now.toLocal();
    for (var i = 0; i < 7; i++) {
      final day = DateTime(d.year, d.month, d.day + i);
      if (weekdays.contains(day.weekday)) return day;
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'goal': goal.name,
    'level': level.name,
    'equipment': equipment.name,
    'days': [for (final d in days) d.toJson()],
    'next': next,
    'weekdays': weekdays,
    'remindAt': ?remindAt,
  };

  factory WorkoutPlan.fromJson(Map<String, dynamic> j) => WorkoutPlan(
    goal: PlanGoal.values.byName(j['goal'] as String),
    level: PlanLevel.values.byName(j['level'] as String),
    equipment: PlanEquipment.values.byName(j['equipment'] as String),
    days: [for (final d in j['days'] as List) PlanDay.fromJson(d as Map<String, dynamic>)],
    next: j['next'] as int? ?? 0,
    weekdays: [for (final w in (j['weekdays'] as List?) ?? defaultWeekdays((j['days'] as List).length)) w as int],
    remindAt: j['remindAt'] as int?,
  );
}

/// Training days spread over the week, with rest days between where they fit.
List<int> defaultWeekdays(int days) => switch (days) {
  <= 3 => const [1, 3, 5], // Mon, Wed, Fri
  4 => const [1, 2, 4, 5],
  _ => const [1, 2, 3, 4, 5],
};

/// A plan of [daysPerWeek] (3–5) sessions, each on different muscles.
WorkoutPlan buildPlan(
  List<LibraryExercise> library, {
  required PlanGoal goal,
  required int daysPerWeek,
  required PlanLevel level,
  required PlanEquipment equipment,
}) => WorkoutPlan(
  goal: goal,
  level: level,
  equipment: equipment,
  weekdays: defaultWeekdays(daysPerWeek),
  days: [
    for (final focus in splits[daysPerWeek.clamp(3, 5)]!)
      () {
        final used = <String>{};
        final exercises = <Exercise>[];
        for (final muscle in _slots[focus]!) {
          final x = exercisesFor(library, muscle, level, equipment).where((x) => !used.contains(x.id)).firstOrNull;
          if (x == null) continue; // nothing for this muscle with this equipment
          used.add(x.id);
          final p = prescription(goal, level, first: exercises.isEmpty);
          exercises.add(Exercise(x.name, sets: p.sets, reps: p.reps, libraryId: x.id));
        }
        return PlanDay(focus, exercises);
      }(),
  ],
);
