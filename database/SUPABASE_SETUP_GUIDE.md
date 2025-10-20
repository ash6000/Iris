# Supabase Setup Guide for Iris Light Within

This guide will walk you through setting up Supabase for the Iris Light Within iOS app.

## Table of Contents

1. [Create Supabase Project](#1-create-supabase-project)
2. [Run Database Migrations](#2-run-database-migrations)
3. [Set Up Storage Buckets](#3-set-up-storage-buckets)
4. [Configure Authentication](#4-configure-authentication)
5. [Install Swift Dependencies](#5-install-swift-dependencies)
6. [Connect iOS App](#6-connect-ios-app)
7. [Testing](#7-testing)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Create Supabase Project

### Step 1.1: Sign Up for Supabase

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign up with GitHub, Google, or email
4. Create your account

### Step 1.2: Create New Project

1. Click "New Project"
2. Fill in project details:
   - **Name**: `iris-light-within`
   - **Database Password**: (generate a strong password - **save this!**)
   - **Region**: Choose closest to your users
   - **Pricing Plan**: Start with Free tier

3. Click "Create new project"
4. Wait 2-3 minutes for project to be provisioned

### Step 1.3: Get Your API Credentials

Once your project is ready:

1. Go to **Project Settings** (gear icon)
2. Click **API** in the sidebar
3. You'll need these two values:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGc...` (long string)

**IMPORTANT**: Save these credentials securely. You'll need them in Step 6.

---

## 2. Run Database Migrations

### Step 2.1: Access SQL Editor

1. In your Supabase dashboard, click **SQL Editor** (left sidebar)
2. Click **New query**

### Step 2.2: Run Migrations in Order

Run each SQL file in order. Copy and paste the entire contents, then click **Run**.

**Run in this exact order:**

#### Migration 1: Core Schema
```sql
-- Copy entire contents of 01_core_schema.sql
-- Paste into SQL Editor
-- Click "Run"
```

**Expected result**: "Success. No rows returned"

#### Migration 2: Conversations Schema
```sql
-- Copy entire contents of 02_conversations_schema.sql
-- Paste into SQL Editor
-- Click "Run"
```

**Expected result**: "Success. 12 rows affected" (the 12 chat categories)

#### Migration 3: Content Schema
```sql
-- Copy entire contents of 03_content_schema.sql
-- Paste into SQL Editor
-- Click "Run"
```

**Expected result**: "Success. No rows returned"

#### Migration 4: Tracking Schema
```sql
-- Copy entire contents of 04_tracking_schema.sql
-- Paste into SQL Editor
-- Click "Run"
```

**Expected result**: "Success. No rows returned"

#### Migration 5: Ambassador Schema
```sql
-- Copy entire contents of 05_ambassador_schema.sql
-- Paste into SQL Editor
-- Click "Run"
```

**Expected result**: "Success. No rows returned"

### Step 2.3: Verify Tables Were Created

1. Click **Table Editor** in the sidebar
2. You should see tables like:
   - `profiles`
   - `conversations`
   - `messages`
   - `mood_entries`
   - `journal_entries`
   - `meditation_content`
   - `ambassadors`
   - And many more...

---

## 3. Set Up Storage Buckets

Supabase Storage is used for audio files, profile photos, and journal voice recordings.

### Step 3.1: Create Buckets

1. Click **Storage** in the sidebar
2. Click **New bucket**

Create these buckets:

#### Bucket 1: avatars
- **Name**: `avatars`
- **Public**: ✅ Yes
- **File size limit**: 2 MB
- **Allowed MIME types**: `image/jpeg, image/png`

#### Bucket 2: audio
- **Name**: `audio`
- **Public**: ❌ No (private)
- **File size limit**: 10 MB
- **Allowed MIME types**: `audio/m4a, audio/mp3, audio/wav`

#### Bucket 3: journal_audio
- **Name**: `journal_audio`
- **Public**: ❌ No (private)
- **File size limit**: 50 MB
- **Allowed MIME types**: `audio/m4a, audio/mp3`

#### Bucket 4: meditation_audio
- **Name**: `meditation_audio`
- **Public**: ✅ Yes
- **File size limit**: 100 MB
- **Allowed MIME types**: `audio/m4a, audio/mp3`

### Step 3.2: Set Up Storage Policies

For each **private bucket** (audio, journal_audio):

1. Click the bucket name
2. Click **Policies**
3. Click **New policy**
4. Select **Custom policy**
5. Add this policy:

```sql
-- Allow users to upload their own files
CREATE POLICY "Users can upload own files"
ON storage.objects FOR INSERT
WITH CHECK (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to read their own files
CREATE POLICY "Users can read own files"
ON storage.objects FOR SELECT
USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to delete their own files
CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
USING (auth.uid()::text = (storage.foldername(name))[1]);
```

---

## 4. Configure Authentication

### Step 4.1: Enable Email Authentication

1. Click **Authentication** in sidebar
2. Click **Providers**
3. **Email** should be enabled by default
4. Configure email settings:
   - **Enable email confirmations**: ✅ Yes
   - **Enable secure email change**: ✅ Yes
   - **Enable password recovery**: ✅ Yes

### Step 4.2: Configure Email Templates

1. Click **Email Templates**
2. Customize these templates for your brand:
   - **Confirm signup**: Welcome message
   - **Invite user**: Not needed for now
   - **Magic Link**: Optional feature
   - **Change Email Address**: Confirmation email
   - **Reset Password**: Password reset instructions

### Step 4.3: Enable Apple Sign In (Optional but Recommended)

1. In Supabase, go to **Authentication > Providers**
2. Find **Apple** and click **Enable**
3. You'll need to set up Apple Sign In in your Apple Developer account:
   - Create a Service ID
   - Configure Sign in with Apple
   - Get the necessary credentials
4. Add credentials to Supabase

**Detailed Apple Setup**: See [Supabase Apple Auth Docs](https://supabase.com/docs/guides/auth/social-login/auth-apple)

### Step 4.4: Configure JWT Settings

1. Go to **Authentication > Settings**
2. **JWT expiry**: 3600 seconds (1 hour) - default is good
3. **Refresh token rotation**: ✅ Enabled
4. **Security**:
   - Enable "Secure password change"
   - Minimum password length: 8

---

## 5. Install Swift Dependencies

### Step 5.1: Add Swift Package Dependencies

Open your project in Xcode:

1. File > Add Packages...
2. Enter this URL: `https://github.com/supabase/supabase-swift`
3. Select version: "Latest" or `2.x.x`
4. Click "Add Package"
5. Select these products:
   - ✅ Supabase
   - ✅ Supabase Auth
   - ✅ Supabase Database (PostgREST)
   - ✅ Supabase Storage
6. Click "Add Package"

### Step 5.2: Add Files to Xcode Project

Add these new files to your Xcode project:

1. Right-click on your project in Xcode
2. Select "Add Files to 'irisOne'..."
3. Navigate to and add:
   - `models/DatabaseModels.swift`
   - `managers/SupabaseManager.swift`
   - `managers/SupabaseHelpers.swift`
4. Make sure "Copy items if needed" is checked
5. Click "Add"

---

## 6. Connect iOS App

### Step 6.1: Create Configuration File

Create a new file called `SupabaseConfig.swift`:

```swift
//
//  SupabaseConfig.swift
//  irisOne
//

import Foundation

struct SupabaseConfig {
    // IMPORTANT: Replace these with your actual credentials from Step 1.3
    static let projectURL = "https://YOUR_PROJECT_ID.supabase.co"
    static let anonKey = "YOUR_ANON_KEY"
}
```

**⚠️ SECURITY WARNING**: Never commit this file with real credentials to a public repository!

For production:
1. Add `SupabaseConfig.swift` to `.gitignore`
2. Use environment variables or a secrets manager

### Step 6.2: Initialize Supabase in AppDelegate

Open `AppDelegate.swift` and add:

```swift
import UIKit
import Supabase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Configure Supabase
        SupabaseManager.shared.configure(
            url: SupabaseConfig.projectURL,
            anonKey: SupabaseConfig.anonKey
        )

        // Rest of your app setup...

        return true
    }
}
```

### Step 6.3: Update Authentication Flow

Replace your current authentication in `LoginViewController.swift` with:

```swift
// Sign In
@objc private func handleSignIn() {
    guard let email = emailTextField.text, !email.isEmpty,
          let password = passwordTextField.text, !password.isEmpty else {
        showAlert(title: "Error", message: "Please fill in all fields")
        return
    }

    executeWithLoading {
        try await SupabaseManager.shared.signIn(email: email, password: password)
    } completion: { [weak self] result in
        switch result {
        case .success:
            // Navigate to main app
            self?.navigateToMainApp()
        case .failure(let error):
            SupabaseManager.showError(error, in: self!)
        }
    }
}

// Sign Up
@objc private func handleSignUp() {
    guard let email = emailTextField.text, !email.isEmpty,
          let password = passwordTextField.text, !password.isEmpty,
          let fullName = nameTextField.text else {
        showAlert(title: "Error", message: "Please fill in all fields")
        return
    }

    executeWithLoading {
        try await SupabaseManager.shared.signUp(
            email: email,
            password: password,
            fullName: fullName
        )
    } completion: { [weak self] result in
        switch result {
        case .success:
            self?.showAlert(
                title: "Success",
                message: "Check your email to confirm your account"
            )
        case .failure(let error):
            SupabaseManager.showError(error, in: self!)
        }
    }
}
```

### Step 6.4: Update PersonalizedChatViewController

Replace your chat message saving with Supabase:

```swift
// In PersonalizedChatViewController.swift

private func sendMessage(_ text: String) {
    guard !text.isEmpty else { return }

    // Add user message to UI immediately
    addMessage(text, isUser: true)

    // Save to database
    Task {
        do {
            // Get or create conversation
            let conversation = try await SupabaseManager.shared.getOrCreateConversation(
                categoryId: currentCategoryId
            )

            // Save user message
            _ = try await SupabaseManager.shared.sendUserMessage(text, in: conversation.id)

            // Get AI response
            let aiResponse = try await getAIResponse(for: text, categoryId: currentCategoryId)

            // Add AI response to UI
            await MainActor.run {
                addMessage(aiResponse, isUser: false)
            }

            // Save AI response to database
            _ = try await SupabaseManager.shared.sendAssistantMessage(
                aiResponse,
                in: conversation.id,
                modelUsed: "gpt-3.5-turbo"
            )

        } catch {
            print("❌ Error saving message: \(error)")
            await MainActor.run {
                showAlert(title: "Error", message: "Failed to save message")
            }
        }
    }
}
```

### Step 6.5: Update MoodTrackerViewController

Replace mood saving with Supabase:

```swift
// In MoodTrackerViewController.swift

@objc private func saveMood() {
    guard let selectedMood = currentSelectedMood else {
        showAlert(title: "Error", message: "Please select a mood")
        return
    }

    let note = notesTextView.text

    executeWithLoading {
        try await SupabaseManager.shared.logMood(selectedMood, note: note)
    } completion: { [weak self] result in
        switch result {
        case .success:
            self?.showAlert(title: "Success", message: "Mood logged!") {
                self?.dismiss(animated: true)
            }
        case .failure(let error):
            SupabaseManager.showError(error, in: self!)
        }
    }
}
```

---

## 7. Testing

### Test 7.1: Test Authentication

1. Run your app
2. Try to sign up with a new account
3. Check your email for confirmation
4. Confirm the account
5. Sign in with the credentials
6. **Verify in Supabase Dashboard**:
   - Go to **Authentication > Users**
   - You should see your test user

### Test 7.2: Test Profile Creation

After signing in:

1. Go to **Table Editor > profiles**
2. You should see a profile record with your user ID
3. Check that the trigger auto-created the profile

### Test 7.3: Test Chat Categories

```swift
// Add this test function somewhere in your app
func testChatCategories() {
    Task {
        do {
            let categories = try await SupabaseManager.shared.fetchChatCategories()
            print("✅ Fetched \(categories.count) categories")
            categories.forEach { category in
                print("   - \(category.name)")
            }
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
```

Expected output:
```
✅ Fetched 12 categories
   - What's My Purpose?
   - Astrology & Messages from the Universe
   - Healing Childhood Wounds
   - All Faiths & All Religions
   ... (12 total)
```

### Test 7.4: Test Conversation & Messages

1. Start a conversation in your app
2. Send a few messages
3. **Verify in Supabase Dashboard**:
   - Go to **Table Editor > conversations**
   - You should see your conversation
   - Go to **Table Editor > messages**
   - You should see your messages in order

### Test 7.5: Test Mood Tracking

1. Log a mood in your app
2. **Verify in Supabase Dashboard**:
   - Go to **Table Editor > mood_entries**
   - You should see your mood entry
   - Go to **Table Editor > profiles**
   - Check that `total_mood_entries` increased

---

## 8. Troubleshooting

### Issue: "Unable to connect to Supabase"

**Solution:**
1. Verify your project URL and anon key are correct
2. Check that your Supabase project is not paused (free tier auto-pauses after 7 days of inactivity)
3. Check your internet connection
4. Look for errors in Xcode console

### Issue: "Row Level Security policy violation"

**Solution:**
1. Make sure you're authenticated (signed in)
2. Verify RLS policies were created (check SQL Editor for errors)
3. Try disabling RLS temporarily to test:
   ```sql
   ALTER TABLE your_table DISABLE ROW LEVEL SECURITY;
   ```
   (Don't forget to re-enable it!)

### Issue: "User not found after sign up"

**Solution:**
1. Check if email confirmation is required
2. Look in **Authentication > Users** to see user status
3. Check that the `handle_new_user()` trigger is working

### Issue: "File upload failed"

**Solution:**
1. Verify storage buckets exist
2. Check bucket policies
3. Make sure file size is under the limit
4. Verify MIME type is allowed

### Issue: "Cannot decode response"

**Solution:**
1. Check that your Swift models match the database schema
2. Print the raw JSON response to debug:
   ```swift
   print(String(data: response.data, encoding: .utf8))
   ```
3. Verify enum values match exactly (case-sensitive)

### Common Error Codes

| Code | Meaning | Solution |
|------|---------|----------|
| 401 | Unauthorized | User not signed in or session expired |
| 403 | Forbidden | RLS policy denied access |
| 404 | Not Found | Record doesn't exist |
| 409 | Conflict | Duplicate unique constraint |
| 500 | Server Error | Check Supabase logs |

### Debug Mode

Enable debug logging in SupabaseManager:

```swift
// Add to SupabaseManager.configure()
#if DEBUG
client.logLevel = .debug
#endif
```

---

## Next Steps

Now that Supabase is set up:

1. **Add Data Seeding**: Create sample meditation content, affirmations, horoscopes
2. **Set Up Push Notifications**: Configure FCM/APNs for notifications
3. **Implement Real-time**: Add real-time message syncing
4. **Set Up Stripe**: Integrate subscription payments
5. **Deploy to Production**: Move from Supabase free tier to Pro

---

## Support

- **Supabase Docs**: https://supabase.com/docs
- **Supabase Discord**: https://discord.supabase.com
- **Swift Client Repo**: https://github.com/supabase/supabase-swift

---

## Security Best Practices

### ✅ DO:
- Use Row Level Security (RLS) on all tables
- Keep your `anon` key public, but keep `service_role` key secret
- Validate user input on the client
- Use HTTPS only
- Enable email confirmation
- Rotate passwords regularly

### ❌ DON'T:
- Hardcode credentials in your app
- Commit secrets to Git
- Disable RLS in production
- Use `service_role` key in client apps
- Trust client-side validation alone

---

**✨ Your Iris Light Within app is now connected to Supabase! ✨**
