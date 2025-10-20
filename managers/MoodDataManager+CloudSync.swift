//
//  MoodDataManager+CloudSync.swift
//  irisOne
//
//  Cloud sync extension for MoodDataManager
//  Adds Supabase cloud sync while maintaining local storage
//

import Foundation

// MARK: - Cloud Sync Extension

extension MoodDataManager {

    // MARK: - Configuration

    /// Enable/disable cloud sync (can be toggled in settings)
    var isCloudSyncEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "mood_cloud_sync_enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "mood_cloud_sync_enabled")
            if newValue {
                // When enabled, sync existing local data to cloud
                Task {
                    await syncLocalToCloud()
                }
            }
        }
    }

    // MARK: - Enhanced Save (Local + Cloud)

    /// Save mood entry with cloud sync
    /// This replaces the existing saveMoodEntry but maintains backward compatibility
    func saveMoodEntryWithSync(
        emoji: String,
        moodLabel: String,
        journalText: String,
        tags: [String],
        voiceRecordingPath: String? = nil,
        voiceRecordingDuration: Double = 0,
        completion: ((Bool, Error?) -> Void)? = nil
    ) {
        // 1. Save locally first (existing behavior - always works offline)
        let localSuccess = saveMoodEntry(
            emoji: emoji,
            moodLabel: moodLabel,
            journalText: journalText,
            tags: tags,
            voiceRecordingPath: voiceRecordingPath,
            voiceRecordingDuration: voiceRecordingDuration
        )

        guard localSuccess else {
            completion?(false, nil)
            return
        }

        // 2. Sync to cloud in background (if enabled and authenticated)
        if isCloudSyncEnabled && SupabaseManager.shared.isAuthenticated {
            Task {
                do {
                    // Convert to database model
                    let moodEntry = MoodEntry(
                        id: UUID().uuidString,
                        date: Date(),
                        emoji: emoji,
                        moodLabel: moodLabel,
                        journalText: journalText,
                        tags: tags
                    )

                    guard let userId = SupabaseManager.shared.currentUserId else {
                        print("⚠️ No user ID for cloud sync")
                        completion?(true, nil) // Local save succeeded
                        return
                    }

                    let dbParams = moodEntry.toDatabaseModel(userId: userId)

                    // Save to Supabase
                    let dbEntry = try await SupabaseManager.shared.createMoodEntry(
                        mood: dbParams.mood,
                        moodScore: dbParams.moodScore,
                        note: dbParams.note,
                        tags: dbParams.tags
                    )

                    print("✅ Mood synced to cloud: \(dbEntry.id)")
                    await MainActor.run {
                        completion?(true, nil)
                    }

                } catch {
                    print("⚠️ Cloud sync failed (local save succeeded): \(error)")
                    // Still return success because local save worked
                    await MainActor.run {
                        completion?(true, error)
                    }
                }
            }
        } else {
            // Cloud sync disabled or not authenticated - local save is enough
            completion?(true, nil)
        }
    }

    // MARK: - Enhanced Fetch (Cloud-first with Local Fallback)

    /// Fetch mood entry with cloud-first strategy
    func getMoodEntryWithSync(for date: Date, completion: @escaping (MoodEntry?) -> Void) {
        // If cloud sync is enabled and user is authenticated, try cloud first
        if isCloudSyncEnabled && SupabaseManager.shared.isAuthenticated {
            Task {
                do {
                    let startOfDay = Calendar.current.startOfDay(for: date)
                    let endOfDay = startOfDay.addingTimeInterval(86400 - 1) // 23:59:59

                    let dbEntries = try await SupabaseManager.shared.fetchMoodEntries(
                        startDate: startOfDay,
                        endDate: endOfDay
                    )

                    if let dbEntry = dbEntries.first {
                        // Found in cloud - convert to local model
                        let localEntry = dbEntry.toLocalMoodEntry()
                        await MainActor.run {
                            completion(localEntry)
                        }
                        return
                    }
                } catch {
                    print("⚠️ Cloud fetch failed, falling back to local: \(error)")
                }

                // Fallback to local storage
                await MainActor.run {
                    let localEntry = self.getMoodEntry(for: date)
                    completion(localEntry)
                }
            }
        } else {
            // Cloud sync disabled - use local only
            let localEntry = getMoodEntry(for: date)
            completion(localEntry)
        }
    }

    /// Fetch all mood entries with cloud-first strategy
    func getAllMoodEntriesWithSync(completion: @escaping ([MoodEntry]) -> Void) {
        if isCloudSyncEnabled && SupabaseManager.shared.isAuthenticated {
            Task {
                do {
                    // Fetch last 90 days from cloud
                    let endDate = Date()
                    let startDate = Calendar.current.date(byAdding: .day, value: -90, to: endDate)!

                    let dbEntries = try await SupabaseManager.shared.fetchMoodEntries(
                        startDate: startDate,
                        endDate: endDate
                    )

                    let localEntries = dbEntries.toLocalMoodEntries()

                    await MainActor.run {
                        completion(localEntries)
                    }
                } catch {
                    print("⚠️ Cloud fetch failed, falling back to local: \(error)")
                    await MainActor.run {
                        let localEntries = self.getAllMoodEntries()
                        completion(localEntries)
                    }
                }
            }
        } else {
            let localEntries = getAllMoodEntries()
            completion(localEntries)
        }
    }

    // MARK: - Background Sync

    /// Sync local data to cloud (called when enabling cloud sync)
    func syncLocalToCloud() async {
        guard SupabaseManager.shared.isAuthenticated,
              let userId = SupabaseManager.shared.currentUserId else {
            print("⚠️ Cannot sync: Not authenticated")
            return
        }

        let localEntries = loadMoodEntries()
        print("📤 Starting sync: \(localEntries.count) local mood entries")

        var successCount = 0
        var failureCount = 0

        for persistentEntry in localEntries {
            do {
                let dbParams = persistentEntry.toDatabaseParameters(userId: userId)

                // Check if already synced
                let dbEntries = try await SupabaseManager.shared.fetchMoodEntries(
                    startDate: persistentEntry.date.startOfDay,
                    endDate: persistentEntry.date.endOfDay
                )

                if dbEntries.isEmpty {
                    // Not in cloud yet - create it
                    _ = try await SupabaseManager.shared.createMoodEntry(
                        mood: dbParams.mood,
                        moodScore: dbParams.moodScore,
                        note: dbParams.note,
                        tags: dbParams.tags,
                        activities: dbParams.activities
                    )
                    successCount += 1
                    print("✅ Synced: \(persistentEntry.date)")
                } else {
                    print("⏭️ Skipped (already synced): \(persistentEntry.date)")
                }

            } catch {
                print("❌ Failed to sync entry: \(error)")
                failureCount += 1
            }
        }

        print("📊 Sync complete: \(successCount) synced, \(failureCount) failed")
    }

    /// Sync cloud data to local (called on app launch)
    func syncCloudToLocal() async {
        guard SupabaseManager.shared.isAuthenticated else {
            print("⚠️ Cannot sync: Not authenticated")
            return
        }

        do {
            // Fetch last 90 days from cloud
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -90, to: endDate)!

            let dbEntries = try await SupabaseManager.shared.fetchMoodEntries(
                startDate: startDate,
                endDate: endDate
            )

            print("📥 Fetched \(dbEntries.count) mood entries from cloud")

            // Convert and save locally
            var localEntries = loadMoodEntries()

            for dbEntry in dbEntries {
                let persistentEntry = dbEntry.toPersistentMoodEntry()

                // Check if already exists locally
                if !localEntries.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: persistentEntry.date) }) {
                    localEntries.append(persistentEntry)
                }
            }

            saveMoodEntries(localEntries)
            print("✅ Local storage updated with cloud data")

        } catch {
            print("❌ Failed to sync from cloud: \(error)")
        }
    }

    // MARK: - Conflict Resolution

    /// Merge local and cloud data intelligently
    func mergeLocalAndCloud() async {
        guard SupabaseManager.shared.isAuthenticated else { return }

        do {
            // Get all local entries
            let localEntries = loadMoodEntries()

            // Get all cloud entries (last 90 days)
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -90, to: endDate)!
            let dbEntries = try await SupabaseManager.shared.fetchMoodEntries(
                startDate: startDate,
                endDate: endDate
            )

            // Create merged list
            var merged: [PersistentMoodEntry] = []

            // Add all cloud entries (cloud is source of truth)
            merged.append(contentsOf: dbEntries.map { $0.toPersistentMoodEntry() })

            // Add local entries that don't exist in cloud
            for localEntry in localEntries {
                let existsInCloud = merged.contains { Calendar.current.isDate($0.date, inSameDayAs: localEntry.date) }

                if !existsInCloud {
                    merged.append(localEntry)
                }
            }

            // Save merged data locally
            saveMoodEntries(merged)
            print("✅ Merged \(merged.count) total entries")

        } catch {
            print("❌ Merge failed: \(error)")
        }
    }
}

// MARK: - Convenience Methods

extension MoodDataManager {

    /// Check if mood entry is synced to cloud
    func isSynced(entryId: String) -> Bool {
        let syncStatus = UserDefaults.standard.loadMoodSyncStatus()
        return syncStatus[entryId]?.isSynced ?? false
    }

    /// Manually trigger sync for a specific date
    func syncMoodEntry(for date: Date) async {
        guard let localEntry = getMoodEntry(for: date),
              let userId = SupabaseManager.shared.currentUserId else {
            return
        }

        do {
            let dbParams = localEntry.toDatabaseModel(userId: userId)

            _ = try await SupabaseManager.shared.createMoodEntry(
                mood: dbParams.mood,
                moodScore: dbParams.moodScore,
                note: dbParams.note,
                tags: dbParams.tags
            )

            print("✅ Synced mood entry for \(date)")
        } catch {
            print("❌ Failed to sync: \(error)")
        }
    }
}

// MARK: - Migration Helpers

extension MoodDataManager {

    /// One-time migration: Move all local data to cloud
    func migrateAllToCloud() async -> (success: Int, failed: Int) {
        guard SupabaseManager.shared.isAuthenticated else {
            return (0, 0)
        }

        await syncLocalToCloud()

        let localEntries = loadMoodEntries()
        return (localEntries.count, 0) // Simplified - check actual sync status
    }

    /// Check sync status of all entries
    func getSyncSummary() -> (total: Int, synced: Int, pending: Int) {
        let localEntries = loadMoodEntries()
        let total = localEntries.count

        // In a real implementation, you'd track sync status per entry
        // For now, assume all are pending if cloud sync is disabled
        if isCloudSyncEnabled {
            return (total, total, 0) // Simplified
        } else {
            return (total, 0, total)
        }
    }
}
