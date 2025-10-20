//
//  CloudSyncManager.swift
//  irisOne
//
//  Central manager for cloud sync operations
//

import Foundation
import UIKit

class CloudSyncManager {
    static let shared = CloudSyncManager()

    private init() {}

    // MARK: - Sync Status

    enum SyncState {
        case idle
        case syncing
        case completed
        case failed(Error)
    }

    private(set) var currentState: SyncState = .idle

    // MARK: - Full Sync

    /// Perform full sync: local → cloud and cloud → local
    func performFullSync() async {
        guard SupabaseManager.shared.isAuthenticated else {
            print("⚠️ Cannot sync: Not authenticated")
            return
        }

        currentState = .syncing
        print("🔄 Starting full sync...")

        // 1. Sync moods
        await MoodDataManager.shared.syncLocalToCloud()
        await MoodDataManager.shared.syncCloudToLocal()

        // 2. Sync journals (when implemented)
        // await JournalDataManager.shared.syncLocalToCloud()
        // await JournalDataManager.shared.syncCloudToLocal()

        currentState = .completed
        print("✅ Full sync completed")
    }

    /// Sync only new/changed data (incremental)
    func performIncrementalSync() async {
        guard SupabaseManager.shared.isAuthenticated else { return }

        let lastSyncDate = UserDefaults.standard.object(forKey: "last_full_sync_date") as? Date ?? Date.distantPast

        print("🔄 Incremental sync since: \(lastSyncDate)")

        // Sync only data created/modified since last sync
        // Implementation depends on tracking modification dates

        UserDefaults.standard.set(Date(), forKey: "last_full_sync_date")
    }

    // MARK: - Conflict Resolution Strategy

    enum ConflictResolutionStrategy {
        case cloudWins      // Cloud data overwrites local
        case localWins      // Local data overwrites cloud
        case newerWins      // Most recent modification wins
        case merge          // Attempt to merge both
    }

    var conflictStrategy: ConflictResolutionStrategy = .cloudWins

    // MARK: - Sync Monitoring

    struct SyncStatistics {
        var lastSyncDate: Date?
        var totalItemsSynced: Int
        var failedItems: Int
        var conflictsResolved: Int
    }

    private(set) var statistics = SyncStatistics(
        lastSyncDate: nil,
        totalItemsSynced: 0,
        failedItems: 0,
        conflictsResolved: 0
    )

    /// Reset sync statistics
    func resetStatistics() {
        statistics = SyncStatistics(
            lastSyncDate: nil,
            totalItemsSynced: 0,
            failedItems: 0,
            conflictsResolved: 0
        )
    }

    // MARK: - Background Sync

    /// Enable automatic background sync
    var isBackgroundSyncEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "background_sync_enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "background_sync_enabled")
        }
    }

    /// Schedule background sync (called on app launch or entering foreground)
    func scheduleBackgroundSync() {
        guard isBackgroundSyncEnabled else { return }

        Task {
            // Wait a bit to avoid blocking app launch
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds

            await performIncrementalSync()
        }
    }

    // MARK: - Network Status

    private var isOnline: Bool {
        // Simple check - in production, use NWPathMonitor or Reachability
        return true // Assume online for now
    }

    /// Sync when network becomes available
    func syncWhenNetworkAvailable() {
        guard isOnline else {
            print("⏳ Waiting for network connection...")
            return
        }

        Task {
            await performIncrementalSync()
        }
    }

    // MARK: - Data Migration

    /// Migrate all local data to cloud (one-time operation)
    func migrateToCloud(completion: @escaping (Bool, String) -> Void) {
        Task {
            do {
                // Check authentication
                guard SupabaseManager.shared.isAuthenticated else {
                    await MainActor.run {
                        completion(false, "Not authenticated")
                    }
                    return
                }

                print("📤 Starting migration to cloud...")

                // Migrate moods
                await MoodDataManager.shared.syncLocalToCloud()

                // Migrate journals (when implemented)
                // await JournalDataManager.shared.syncLocalToCloud()

                // Mark migration as complete
                UserDefaults.standard.set(true, forKey: "cloud_migration_completed")
                UserDefaults.standard.set(Date(), forKey: "cloud_migration_date")

                await MainActor.run {
                    completion(true, "Migration completed successfully")
                }

                print("✅ Migration completed")

            } catch {
                await MainActor.run {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }

    /// Check if migration has been completed
    var hasCompletedMigration: Bool {
        return UserDefaults.standard.bool(forKey: "cloud_migration_completed")
    }

    // MARK: - Debugging

    #if DEBUG
    /// Print sync status for debugging
    func printSyncStatus() {
        print("📊 Sync Status:")
        print("   State: \(currentState)")
        print("   Last Sync: \(statistics.lastSyncDate?.formatted() ?? "Never")")
        print("   Items Synced: \(statistics.totalItemsSynced)")
        print("   Failed: \(statistics.failedItems)")
        print("   Background Sync: \(isBackgroundSyncEnabled ? "Enabled" : "Disabled")")
        print("   Migration Complete: \(hasCompletedMigration ? "Yes" : "No")")

        // Mood sync details
        let moodSummary = MoodDataManager.shared.getSyncSummary()
        print("   Moods: \(moodSummary.total) total, \(moodSummary.synced) synced, \(moodSummary.pending) pending")
    }

    /// Force resync all data (clears local cache)
    func forceResync() async {
        print("🔄 Force resync...")

        // Clear local data
        UserDefaults.standard.removeObject(forKey: "last_full_sync_date")

        // Perform full sync
        await performFullSync()
    }
    #endif
}

// MARK: - Sync Notifications

extension CloudSyncManager {

    /// Post notification when sync starts
    func notifySyncStarted() {
        NotificationCenter.default.post(name: .cloudSyncStarted, object: nil)
    }

    /// Post notification when sync completes
    func notifySyncCompleted() {
        NotificationCenter.default.post(name: .cloudSyncCompleted, object: nil)
    }

    /// Post notification when sync fails
    func notifySyncFailed(error: Error) {
        NotificationCenter.default.post(
            name: .cloudSyncFailed,
            object: nil,
            userInfo: ["error": error]
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let cloudSyncStarted = Notification.Name("cloudSyncStarted")
    static let cloudSyncCompleted = Notification.Name("cloudSyncCompleted")
    static let cloudSyncFailed = Notification.Name("cloudSyncFailed")
}

// MARK: - Convenience Extensions
// UI integration helpers can be added here later
