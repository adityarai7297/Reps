class CacheManager {
    static let shared = CacheManager()
    
    private var exerciseCache: [String: [ExerciseHistory]] = [:] // Cache by exercise name

    private init() {}

    // Store history in cache
    func cacheExerciseHistory(_ exerciseName: String, history: [ExerciseHistory]) {
        exerciseCache[exerciseName] = history
    }

    // Retrieve history from cache
    func getExerciseHistory(for exerciseName: String) -> [ExerciseHistory]? {
        return exerciseCache[exerciseName]
    }

    // Clear cache for a specific exercise (if data changes, e.g., user saves new set)
    func clearCache(for exerciseName: String) {
        exerciseCache.removeValue(forKey: exerciseName)
    }
}
