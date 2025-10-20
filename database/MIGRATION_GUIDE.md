# Migration Guide: Local to Cloud with Dual Storage

## Overview

This guide explains how to use the dual-storage system that keeps your existing local models working while adding cloud sync capabilities.

---

## Architecture

### 🏗️ Three-Layer System

```
┌─────────────────────────────────────┐
│      UI Layer (ViewControllers)     │
│   Uses: MoodEntry, JournalEntry     │ ← No changes needed!
└─────────────────────────────────────┘
                  ↕️
┌─────────────────────────────────────┐
│   Data Layer (MoodDataManager)      │
│   • Saves locally (UserDefaults)    │
│   • Syncs to cloud (background)     │ ← New sync added
└─────────────────────────────────────┘
                  ↕️
┌─────────────────────────────────────┐
│   Cloud Layer (Supabase)             │
│   Uses: DBMoodEntry, DBJournalEntry │ ← New models
└─────────────────────────────────────┘
```

### 📦 Model Mapping

| Local UI Model | Database Model | Table | Purpose |
|----------------|----------------|-------|---------|
| `MoodEntry` | `DBMoodEntry` | `mood_entries` | Mood tracking |
| `JournalEntry` | `DBJournalEntry` | `journal_entries` | Journal entries |
| `Message` (OpenAI) | `ChatMessage` | `messages` | AI conversations |

---

## Phase 1: Initial Setup (Current State)

### ✅ What's Done

1. **Models Created**:
   - ✅ Local models unchanged (`MoodEntry`, `JournalEntry`)
   - ✅ Database models added (`DBMoodEntry`, `DBJournalEntry`, `ChatMessage`)
   - ✅ Converters created (`ModelConverters.swift`)

2. **Managers Ready**:
   - ✅ `MoodDataManager` - works as before
   - ✅ `MoodDataManager+CloudSync` - adds cloud sync
   - ✅ `CloudSyncManager` - orchestrates all sync
   - ✅ `SupabaseManager` - handles database

3. **Zero Breaking Changes**:
   - ✅ All existing ViewControllers work unchanged
   - ✅ All existing user data preserved
   - ✅ App works offline exactly as before

### 🎯 Your Code Works As-Is

```swift
// This still works exactly the same:
MoodDataManager.shared.saveMoodEntry(
    emoji: "😊",
    moodLabel: "Joyful",
    journalText: "Great day!",
    tags: ["happy", "productive"]
)

// And this:
let moods = MoodDataManager.shared.getAllMoodEntries()
```

---

## Phase 2: Enable Cloud Sync (Optional)

### Step 1: Enable Sync in Settings

Add a toggle in your Settings screen:

```swift
// SettingsViewController.swift

class SettingsViewController: UIViewController {

    private let cloudSyncToggle = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load current state
        cloudSyncToggle.isOn = MoodDataManager.shared.isCloudSyncEnabled

        // Handle toggle
        cloudSyncToggle.addTarget(self, action: #selector(cloudSyncToggled), for: .valueChanged)
    }

    @objc private func cloudSyncToggled() {
        if cloudSyncToggle.isOn {
            // User wants to enable cloud sync
            enableCloudSync()
        } else {
            // User wants to disable cloud sync
            MoodDataManager.shared.isCloudSyncEnabled = false
        }
    }

    private func enableCloudSync() {
        // Check if user is signed in
        guard SupabaseManager.shared.isAuthenticated else {
            showAlert(title: "Sign In Required", message: "Please sign in to enable cloud sync") {
                self.cloudSyncToggle.isOn = false
            }
            return
        }

        // Show migration dialog
        let alert = UIAlertController(
            title: "Enable Cloud Sync?",
            message: "This will upload your existing mood data to the cloud. Continue?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.cloudSyncToggle.isOn = false
        })

        alert.addAction(UIAlertAction(title: "Enable", style: .default) { _ in
            // Enable sync
            MoodDataManager.shared.isCloudSyncEnabled = true

            // This automatically triggers syncLocalToCloud() in background
            self.showAlert(title: "Syncing", message: "Uploading your data to cloud...")
        })

        present(alert, animated: true)
    }
}
```

### Step 2: Use Sync Methods (Gradual Adoption)

You can start using sync methods without breaking existing code:

```swift
// Option A: Keep using old method (local only)
MoodDataManager.shared.saveMoodEntry(...) // Works as before

// Option B: Use new sync method (local + cloud)
MoodDataManager.shared.saveMoodEntryWithSync(...) { success, error in
    if success {
        print("Saved locally (and cloud if enabled)")
    }
}

// Both work! Choose when to switch
```

### Step 3: Update Gradually

Update one ViewController at a time:

```swift
// MoodTrackerViewController.swift

@objc private func saveMood() {
    // OLD WAY (still works):
    // let success = MoodDataManager.shared.saveMoodEntry(...)

    // NEW WAY (with cloud sync):
    MoodDataManager.shared.saveMoodEntryWithSync(
        emoji: selectedEmoji,
        moodLabel: selectedLabel,
        journalText: notesTextView.text,
        tags: selectedTags
    ) { success, error in
        if success {
            self.showAlert(title: "Saved!", message: "Your mood has been recorded")
        } else {
            self.showAlert(title: "Error", message: "Failed to save mood")
        }
    }
}
```

---

## Phase 3: Migration Strategies

### Strategy A: Automatic Background Sync (Recommended)

Let the system sync automatically in the background:

```swift
// AppDelegate.swift

func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {

    // Configure Supabase
    SupabaseManager.shared.configure(
        url: SupabaseConfig.projectURL,
        anonKey: SupabaseConfig.anonKey
    )

    // Enable background sync if user is signed in
    if SupabaseManager.shared.isAuthenticated {
        CloudSyncManager.shared.isBackgroundSyncEnabled = true
        CloudSyncManager.shared.scheduleBackgroundSync()
    }

    return true
}
```

### Strategy B: Manual Sync Button

Add a "Sync Now" button in settings:

```swift
// SettingsViewController.swift

@objc private func syncNowTapped() {
    showAlert(title: "Syncing...", message: "Please wait")

    Task {
        await CloudSyncManager.shared.performFullSync()

        await MainActor.run {
            self.dismissAlert()
            self.showAlert(title: "Success", message: "All data synced!")
        }
    }
}
```

### Strategy C: One-Time Migration Dialog

Show a one-time migration prompt:

```swift
// Show on first launch after authentication

func checkAndOfferMigration() {
    // Only show once
    guard !CloudSyncManager.shared.hasCompletedMigration else { return }

    // Only if user has local data
    let localMoods = MoodDataManager.shared.getAllMoodEntries()
    guard !localMoods.isEmpty else { return }

    let alert = UIAlertController(
        title: "Sync to Cloud?",
        message: "You have \(localMoods.count) mood entries saved locally. Would you like to sync them to the cloud for backup and access across devices?",
        preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))

    alert.addAction(UIAlertAction(title: "Yes, Sync", style: .default) { _ in
        CloudSyncManager.shared.migrateToCloud { success, message in
            self.showAlert(title: success ? "Success" : "Error", message: message)
        }
    })

    present(alert, animated: true)
}
```

---

## Phase 4: Fetching Data (Cloud-First)

### Cloud-First with Local Fallback

```swift
// MoodOverviewViewController.swift

override func viewDidLoad() {
    super.viewDidLoad()

    // Load moods
    loadMoods()
}

private func loadMoods() {
    // Option A: Simple (existing way - local only)
    let moods = MoodDataManager.shared.getAllMoodEntries()
    displayMoods(moods)

    // Option B: Cloud-first (new way)
    MoodDataManager.shared.getAllMoodEntriesWithSync { moods in
        self.displayMoods(moods)
    }

    // Both work! Cloud-first will:
    // 1. Try to fetch from cloud if enabled
    // 2. Fallback to local if cloud fails
    // 3. Work offline automatically
}
```

### Progress Indicator

Show loading state while fetching from cloud:

```swift
private func loadMoods() {
    showLoadingIndicator()

    MoodDataManager.shared.getAllMoodEntriesWithSync { moods in
        self.hideLoadingIndicator()
        self.displayMoods(moods)
    }
}
```

---

## Best Practices

### ✅ Do's

1. **Enable Sync After Sign In**
   ```swift
   // After successful login
   MoodDataManager.shared.isCloudSyncEnabled = true
   ```

2. **Disable Sync on Sign Out**
   ```swift
   // When user signs out
   MoodDataManager.shared.isCloudSyncEnabled = false
   ```

3. **Handle Offline Gracefully**
   ```swift
   // Save works offline automatically
   MoodDataManager.shared.saveMoodEntryWithSync(...) { success, error in
       // Even if cloud sync fails, local save succeeds
       if success {
           print("Saved (cloud sync will retry later)")
       }
   }
   ```

4. **Show Sync Status**
   ```swift
   // In SettingsViewController
   let syncSummary = MoodDataManager.shared.getSyncSummary()
   statusLabel.text = "\(syncSummary.synced)/\(syncSummary.total) moods synced"
   ```

### ❌ Don'ts

1. **Don't Delete Local Data Prematurely**
   - Keep local storage even with cloud sync
   - Provides offline access
   - Faster loading

2. **Don't Force Users to Sync**
   - Make cloud sync optional
   - App should work fully offline
   - Respect user choice

3. **Don't Lose Data on Conflicts**
   - Always prefer keeping data over deleting
   - Cloud wins by default (`cloudWins` strategy)
   - User can manually resolve conflicts

---

## Example: Complete Flow

### Saving a Mood

```swift
// User taps "Save Mood" button
@objc private func saveMoodTapped() {
    // 1. Save happens immediately (local)
    MoodDataManager.shared.saveMoodEntryWithSync(
        emoji: "😊",
        moodLabel: "Joyful",
        journalText: "Had a great day!",
        tags: ["happy"]
    ) { success, error in
        // 2. Local save completes instantly
        if success {
            self.showSuccess()

            // 3. Cloud sync happens in background
            // - If enabled: syncs to Supabase
            // - If disabled: only local
            // - If offline: queued for later
        }
    }
}
```

### Loading Moods

```swift
// User opens Mood Overview
override func viewDidLoad() {
    super.viewDidLoad()

    // 1. Show loading
    showLoadingIndicator()

    // 2. Fetch with cloud-first strategy
    MoodDataManager.shared.getAllMoodEntriesWithSync { moods in
        // 3. Always gets data (cloud or local fallback)
        self.displayMoods(moods)
        self.hideLoadingIndicator()
    }

    // Flow:
    // - If cloud sync enabled + online: fetches from cloud (fresh data)
    // - If cloud sync disabled: uses local (fast)
    // - If offline: uses local (works offline)
}
```

---

## Debugging

### Check Sync Status

```swift
#if DEBUG
// In your settings or debug menu
CloudSyncManager.shared.printSyncStatus()

// Output:
// 📊 Sync Status:
//    State: completed
//    Last Sync: Jan 19, 2025 at 10:30 AM
//    Items Synced: 45
//    Failed: 0
//    Background Sync: Enabled
//    Migration Complete: Yes
//    Moods: 45 total, 45 synced, 0 pending
#endif
```

### Force Resync

```swift
#if DEBUG
// If data seems out of sync
Task {
    await CloudSyncManager.shared.forceResync()
}
#endif
```

---

## Timeline

### Week 1: Setup
- ✅ Add files to Xcode
- ✅ Configure Supabase
- ✅ Test authentication
- ✅ Verify models compile

### Week 2: Enable Sync
- Enable cloud sync toggle in settings
- Test automatic background sync
- Verify local → cloud sync works

### Week 3: Update UI
- Replace some `saveMoodEntry` with `saveMoodEntryWithSync`
- Add sync status indicators
- Test offline behavior

### Week 4: Full Migration
- Enable background sync by default for all users
- Monitor sync success rate
- Remove "beta" labels

### Future: Remove Local Storage (Optional)
- After all users migrated to cloud
- Keep local cache for performance
- But cloud becomes primary storage

---

## Summary

### What You Get

✅ **No Breaking Changes** - Existing code works unchanged
✅ **Preserved User Data** - Nothing lost
✅ **Gradual Migration** - Move at your own pace
✅ **Offline Support** - App works without internet
✅ **Cloud Backup** - Data safe in Supabase
✅ **Multi-Device Sync** - Access across devices
✅ **Easy Rollback** - Can disable sync anytime

### Files Added

- ✅ `models/ModelConverters.swift` - Convert between models
- ✅ `managers/MoodDataManager+CloudSync.swift` - Cloud sync extension
- ✅ `managers/CloudSyncManager.swift` - Central sync orchestrator

### Next Steps

1. Add files to Xcode project
2. Install Supabase package
3. Test in simulator
4. Add sync toggle to settings
5. Ship!

---

**You're ready to go! The app works now with local storage, and you can enable cloud sync whenever you're ready.** 🚀
