import Foundation

enum MuscleGroup: String, Codable {
    case arms = "Arms"
    case triceps = "Triceps"
    case biceps = "Biceps"
    case hands = "Hands"
    case forearms = "Forearms"
    case delts = "Delts"
    case rearDelts = "RearDelts"
    case frontDelts = "FrontDelts"
    case legs = "Legs"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
    case knees = "Knees"
    case calfs = "Calfs"
    case quadriceps = "Quadriceps"
    case chest = "Chest"
    case back = "Back"
    case infraspinatus = "Infraspinatus"
    case lats = "Lats"
    case traps = "Traps"
    case lowerBack = "LowerBack"
    case obliques = "Obliques"
    case abdominals = "Abdominals"
}

struct ExerciseData {
    static let allExercises = [
        
        // Chest exercises
        "Barbell Bench Press",
        "Dumbbell Bench Press",
        "Single Arm Dumbbell Bench Press",
        "Incline Barbell Bench Press",
        "Incline Dumbbell Bench Press",
        "Decline Barbell Bench Press",
        "Decline Dumbbell Bench Press",
        "Chest Flyes",
        "Dumbbell Chest Fly",
        "Cable Chest Fly",
        "Cable Crossovers",
        "Push-Ups",
        "Pec Deck Machine",
        "Guillotine Press",
        "Hex Press",
        "Svend Press",
        "Cable Chest Press",
        "Machine Chest Press",
        "Smith Machine Bench Press",
        "Landmine Press",
        "Dumbbell Pullover",
        "Machine Pullover",
        "Cable Pullover",

        // Back exercises
        "Barbell Deadlift",
        "Trap Bar Deadlift",
        "Sumo Deadlift",
        "Romanian Deadlift (Barbell)",
        "Romanian Deadlift (Dumbbell)",
        "Pull-Ups",
        "Chin-Ups",
        "Lat Pulldown",
        "Single Arm Lat Pulldown",
        "Barbell Row",
        "Dumbbell Row",
        "Single Arm Dumbbell Row",
        "T-Bar Row",
        "Cable Seated Row",
        "Chest Supported Row",
        "Machine Row",
        "Cable Row",
        "Rack Pulls",
        "Face Pulls",
        "Hyperextensions",
        "Inverted Row",
        "Seal Row",
        "Pendlay Row (Barbell)",
        "Pendlay Row (Dumbbell)",
        "Kroc Row",
        "Single Arm Cable Row",
        "Wide Grip Pull-Up",
        "Meadows Row",
        "Neutral Grip Pull-Up",
        "Deficit Deadlift",
        "Stiff-Legged Deadlift",
        "Snatch-Grip Deadlift",
        "Good Mornings",
        
        // Shoulder exercises
        "Barbell Overhead Press (OHP)",
        "Dumbbell Shoulder Press",
        "Single Arm Dumbbell Shoulder Press",
        "Arnold Press",
        "Lateral Raises",
        "Dumbbell Lateral Raise",
        "Cable Lateral Raise",
        "Front Raises",
        "Dumbbell Front Raise",
        "Cable Front Raise",
        "Rear Delt Flyes",
        "Cable Face Pulls",
        "Landmine Shoulder Press",
        "Smith Machine Overhead Press",
        "Cuban Press",
        "Snatch-Grip Overhead Press",
        "Z-Press",
        "Standing Dumbbell Press",
        "Machine Shoulder Press",
        "Y Raises",
        "Behind-the-Neck Press",
        "Scaption",

        // Bicep exercises
        "Barbell Bicep Curl",
        "Dumbbell Bicep Curl",
        "Single Arm Dumbbell Bicep Curl",
        "Cable Bicep Curl",
        "Preacher Curl",
        "Hammer Curl",
        "Incline Hammer Curl",
        "Concentration Curl",
        "Cable Hammer Curl",
        "Incline Dumbbell Curl",
        "Spider Curl",
        "Cable Preacher Curl",
        "Drag Curl",
        "Bayesian Curl",
        "21s Bicep Curl",
        "EZ Bar Curl",
        "Reverse Curl",
        "Concentration Cable Curl",

        // Tricep exercises
        "Tricep Dips",
        "Skull Crushers",
        "Close-Grip Bench Press",
        "Smith Machine Close Grip Bench Press",
        "Tricep Pushdowns",
        "Single Arm Tricep Pushdown",
        "Reverse Grip Tricep Pushdown",
        "Overhead Tricep Extension",
        "Cable Tricep Extension",
        "Dumbbell Kickbacks",
        "Cable Kickback",
        "Dumbbell Floor Press",
        "Diamond Push-Ups",
        "Rope Pushdowns",
        "Tricep Extensions on Bench",
        "JM Press",
        "Ring Dips",

        // Leg exercises
        "Barbell Squat",
        "Front Squats",
        "Bulgarian Split Squats",
        "Leg Press",
        "Smith Machine Squat",
        "Single-Leg Press",
        "Lunges",
        "Walking Lunges",
        "Smith Machine Lunges",
        "Step-Ups",
        "Cossack Squat",
        "Romanian Deadlift",
        "Single Leg Romanian Deadlift",
        "Leg Curls",
        "Leg Extensions",
        "Calf Raises",
        "Seated Calf Raises",
        "Smith Machine Calf Raise",
        "Hack Squat",
        "Sumo Deadlift",
        "Hip Thrusts",
        "Barbell Hip Thrust",
        "Glute Bridge",
        "Goblet Squat",
        "Anderson Squats",
        "Jefferson Squat",
        "Sissy Squat",
        "Belt Squat",
        "Overhead Squat",
        "Kang Squat",
        "Box Squat",
        "Pistol Squats",
        "Sled Push",
        "Sled Pull",
        "Nordic Curls",
        "Reverse Hack Squat",
        "Cable Pull-Through",
        "Landmine Squat",
        "Lateral Lunges",

        // Core exercises
        "Planks",
        "Hanging Leg Raise",
        "Crunches",
        "Cable Crunches",
        "Russian Twists",
        "Cable Woodchoppers",
        "Ab Wheel Rollout",
        "Bicycle Crunches",
        "Sit-Ups",
        "Mountain Climbers",
        "Dead Bug",
        "V-Sit Hold",
        "Dragon Flag",
        "Weighted Planks",
        "Stir-the-Pot",
        "L-Sit",
        "Hollow Body Hold",
        "Garhammer Raise",
        "Cable Pallof Press",
        "Flutter Kicks",
        "Toe-to-Bar",
        "Oblique Crunches",
        "Cable Side Bends",
        "Side Plank",
        "Jackknives",

        // Forearm exercises
        "Wrist Curls",
        "Reverse Wrist Curls",
        "Farmer's Walk",
        "Plate Pinches",
        "Zottman Curl",
        "Reverse Curl with EZ Bar",
        "Behind-the-Back Wrist Curls",
        "Towel Grip Pull-Ups",
        "Fat Grip Bar Holds",
        "Finger Curls",
        "Wrist Roller",
        "Thick Bar Deadlifts",

        // Full body exercises
        "Clean and Jerk",
        "Snatch",
        "Kettlebell Swings",
        "Turkish Get-Up",
        "Thrusters",
        "Overhead Squat",
        "Dumbbell Snatch",
        "Kettlebell Clean",
        "Squat Clean",
        "Kettlebell High Pull",
        "Man Makers",
        "Barbell Complexes",
        "Dumbbell Thruster",
        "Devil Press",
        "Kettlebell Turkish Get-Up",
        "Clean Pull",

        // Compound movements
        "Barbell Squat",
        "Deadlift",
        "Bench Press",
        "Pull-Ups",
        "Overhead Press",
        "Bent-Over Row",
        "Log Press",
        "Tire Flip",
        "Stone to Shoulder",
        "Farmers Walk with Trap Bar",
        "Zercher Squat",
        "Sots Press",

        // Isolation and machine-based movements
        "Leg Adduction",
        "Leg Abduction",
        "Machine Hamstring Curl",
        "Cable Glute Kickbacks",
        "Machine Hip Abduction",
        "Leg Extension Machine",
        "Standing Hamstring Curl",
        "Single Leg Curl Machine",

        // Olympic Lifting Variations
        "Power Clean",
        "Power Snatch",
        "Hang Clean",
        "Hang Snatch",
        "Split Jerk",
        "Push Jerk",
        "Push Press",
        "Snatch Balance",
        "Hang Power Clean",

        // Unique Variations
        "Paused Deadlift",
        "Banded Bench Press",
        "Banded Squats",
        "Deficit Bulgarian Split Squat",
        "Single Leg Romanian Deadlift",
        "Safety Bar Squat",
        "Zercher Deadlift",
        "Cluster Set Deadlifts",
        "Eccentric Pull-Ups",
        "Paused Squats",
        "Tempo Bench Press"
    ]
    
    static let muscleGroupMapping: [String: [MuscleGroup]] = [
        // Chest exercises
        "Barbell Bench Press": [.chest, .frontDelts, .triceps],
        "Dumbbell Bench Press": [.chest, .frontDelts, .triceps],
        "Single Arm Dumbbell Bench Press": [.chest, .frontDelts, .triceps],
        "Incline Barbell Bench Press": [.chest, .frontDelts, .triceps],
        "Incline Dumbbell Bench Press": [.chest, .frontDelts, .triceps],
        "Decline Barbell Bench Press": [.chest, .frontDelts, .triceps],
        "Decline Dumbbell Bench Press": [.chest, .frontDelts, .triceps],
        "Chest Flyes": [.chest],
        "Dumbbell Chest Fly": [.chest],
        "Cable Chest Fly": [.chest],
        "Cable Crossovers": [.chest],
        "Push-Ups": [.chest, .frontDelts, .triceps, .abdominals],
        "Pec Deck Machine": [.chest],
        
        // Back exercises
        "Barbell Deadlift": [.lowerBack, .hamstrings, .glutes, .traps],
        "Pull-Ups": [.lats, .biceps, .rearDelts],
        "Chin-Ups": [.lats, .biceps, .rearDelts],
        "Lat Pulldown": [.lats, .biceps, .rearDelts],
        "Barbell Row": [.back, .lats, .biceps, .rearDelts],
        "Dumbbell Row": [.back, .lats, .biceps, .rearDelts],
        "T-Bar Row": [.back, .lats, .biceps],
        "Face Pulls": [.rearDelts, .traps, .infraspinatus],
        
        // Shoulder exercises
        "Barbell Overhead Press (OHP)": [.frontDelts, .delts, .triceps],
        "Dumbbell Shoulder Press": [.frontDelts, .delts, .triceps],
        "Arnold Press": [.frontDelts, .delts, .triceps],
        "Lateral Raises": [.delts],
        "Front Raises": [.frontDelts],
        "Rear Delt Flyes": [.rearDelts],
        
        // Arm exercises
        "Barbell Bicep Curl": [.biceps],
        "Dumbbell Bicep Curl": [.biceps],
        "Hammer Curl": [.biceps, .forearms],
        "Tricep Dips": [.triceps, .chest],
        "Skull Crushers": [.triceps],
        "Close-Grip Bench Press": [.triceps, .chest],
        "Tricep Pushdowns": [.triceps],
        
        // Leg exercises
        "Barbell Squat": [.quadriceps, .glutes, .hamstrings, .abdominals],
        "Front Squats": [.quadriceps, .abdominals],
        "Bulgarian Split Squats": [.quadriceps, .glutes, .hamstrings],
        "Leg Press": [.quadriceps, .glutes, .hamstrings],
        "Lunges": [.quadriceps, .glutes, .hamstrings],
        "Romanian Deadlift": [.hamstrings, .glutes, .lowerBack],
        "Leg Curls": [.hamstrings],
        "Leg Extensions": [.quadriceps],
        "Calf Raises": [.calfs],
        "Hip Thrusts": [.glutes, .hamstrings],
        
        // Core exercises
        "Planks": [.abdominals],
        "Hanging Leg Raise": [.abdominals],
        "Crunches": [.abdominals],
        "Russian Twists": [.obliques, .abdominals],
        "Ab Wheel Rollout": [.abdominals],
        
        // Olympic Lifts
        "Clean and Jerk": [.quadriceps, .glutes, .delts, .traps],
        "Snatch": [.quadriceps, .glutes, .delts, .traps],
        "Power Clean": [.quadriceps, .glutes, .traps]
    ]
}
