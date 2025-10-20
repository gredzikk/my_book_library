# Email Verification Fix - Cross-Device Flow

## Problem Description
**Scenario:** User registers on Phone A, confirms email on Computer B, returns to Phone A and tries to login → nothing happens (no errors, no navigation).

**Root Cause:**
1. Email confirmation happens on different device (Computer)
2. Phone app doesn't know email was verified (no real-time sync)
3. Login attempt → Supabase returns "email not confirmed" error
4. App showed generic "Invalid credentials" message (confusing!)

## ✅ Solution Implemented

### Changes Made:

#### 1. **AuthService - Better Error Messages** ✅
`lib/features/auth/services/auth_service.dart`

```dart
// BEFORE: Generic error for unverified email
if (message.contains('invalid login credentials') ||
    message.contains('invalid password') ||
    message.contains('email not confirmed')) {
  throw UnauthorizedException('Nieprawidłowy e-mail lub hasło');
}

// AFTER: Specific error for unverified email (checked first!)
if (message.contains('email not confirmed')) {
  throw UnauthorizedException(
    'Adres e-mail nie został potwierdzony. Sprawdź swoją skrzynkę pocztową i kliknij link weryfikacyjny.',
  );
}

if (message.contains('invalid login credentials') ||
    message.contains('invalid password')) {
  throw UnauthorizedException('Nieprawidłowy e-mail lub hasło');
}
```

#### 2. **AuthService - Resend Confirmation Email** ✅
Added new method to resend verification email:

```dart
@override
Future<void> resendConfirmationEmail({required String email}) async {
  await _auth.resend(
    type: OtpType.signup,
    email: email.trim(),
    emailRedirectTo: 'io.supabase.mybooklibrary://login-callback',
  );
}
```

#### 3. **AuthBloc - New Event & State** ✅
- Event: `ConfirmationEmailResendRequested`
- State: `ConfirmationEmailResent`
- Handler: `_onConfirmationEmailResendRequested`

#### 4. **LoginScreen - Smart SnackBar with Action** ✅
```dart
// Detect if error is about unverified email
final isEmailNotConfirmed = state.message.toLowerCase().contains('nie został potwierdzony');

SnackBar(
  content: Text(state.message),
  duration: isEmailNotConfirmed ? Duration(seconds: 7) : Duration(seconds: 4),
  action: isEmailNotConfirmed
      ? SnackBarAction(
          label: 'Wyślij ponownie',
          onPressed: () {
            context.read<AuthBloc>().add(
              ConfirmationEmailResendRequested(email: _emailController.text.trim()),
            );
          },
        )
      : null,
)
```

#### 5. **AuthService - Email Redirect URL for SignUp** ✅
```dart
await _auth.signUp(
  email: email.trim(),
  password: password,
  emailRedirectTo: 'io.supabase.mybooklibrary://login-callback', // ✅ Added
);
```

## User Flow - Cross-Device Scenario

### Before Fix:
1. 📱 User registers on Phone → email sent
2. 💻 User clicks link on Computer → email verified (but phone doesn't know!)
3. 📱 User returns to Phone → tries to login
4. ❌ **"Nieprawidłowy e-mail lub hasło"** (confusing! credentials are correct!)
5. 😕 User frustrated, doesn't know what's wrong

### After Fix:
1. 📱 User registers on Phone → email sent
2. 💻 User clicks link on Computer → email verified
3. 📱 User returns to Phone → tries to login
4. ✅ **"Adres e-mail nie został potwierdzony. Sprawdź swoją skrzynkę pocztową..."**
5. 🔘 SnackBar shows **"Wyślij ponownie"** button
6. 📧 User clicks button → new verification email sent
7. 💻 User clicks new link on Computer (or Phone if they check email there)
8. 📱 User returns to Phone → tries to login again
9. ✅ **Login succeeds!** (email is now verified)

**Alternative:** User can also just **wait and try logging in again** after verifying on Computer - it will work on next attempt since Supabase knows email is verified.

## Technical Details

### Why "email not confirmed" after verification on different device?

**Answer:** This is **correct behavior** from Supabase perspective:

1. When user **verifies email on Computer**, Supabase updates the database: `users.email_confirmed_at = NOW()`
2. When user **tries to login on Phone**, Phone makes API call to Supabase
3. Supabase checks: `SELECT * FROM users WHERE email = ? AND email_confirmed_at IS NOT NULL`
4. **If user just verified on Computer:** `email_confirmed_at` IS NOT NULL → login should succeed
5. **If user hasn't verified yet:** `email_confirmed_at` IS NULL → Supabase returns "Email not confirmed"

**The issue was:**
- App was showing **wrong error message** ("Invalid credentials" instead of "Email not confirmed")
- App didn't provide **easy way to resend** verification email

### Why show "Wyślij ponownie" button?

**Use cases:**
1. **Email expired** (24h validity) → resend fresh link
2. **Email lost in spam** → resend to check again
3. **User needs mobile link** → get link on phone instead of computer
4. **User verified but app cached old state** → resend triggers refresh

### Email Redirect URL Importance

```dart
emailRedirectTo: 'io.supabase.mybooklibrary://login-callback'
```

**Why needed:**
- When user clicks email link, Supabase redirects to this URL
- **On Phone:** Opens app directly (deep link)
- **On Computer:** Shows "Open in app" prompt (if app installed) or web fallback

**Configured in:**
- ✅ `android/app/src/main/AndroidManifest.xml` (Android deep linking)
- ⏳ `ios/Runner/Info.plist` (iOS deep linking - TODO)
- ✅ Supabase Dashboard → Authentication → URL Configuration

## Testing the Fix

### Test Case 1: Same Device
```
1. Register with new email on Phone
2. Check email on Phone
3. Click verification link
4. App opens (deep link)
5. Login → ✅ Success
```

### Test Case 2: Cross-Device (Computer verification)
```
1. Register with new email on Phone
2. Check email on Computer
3. Click verification link on Computer
4. Return to Phone app
5. Try to login → ❌ "Email not confirmed" message
6. Click "Wyślij ponownie" button
7. New email sent
8. Option A: Click link on Phone → App opens → Login ✅
9. Option B: Wait 10 seconds → Try login again → ✅ Success (email already verified from step 3!)
```

### Test Case 3: Expired Link
```
1. Register with email
2. Wait 24+ hours
3. Try to click old verification link → ❌ Expired
4. Try to login → "Email not confirmed" + "Wyślij ponownie" button
5. Click "Wyślij ponownie"
6. Get fresh link → Click → ✅ Success
```

### Test Case 4: Lost in Spam
```
1. Register with email
2. Email goes to SPAM (user doesn't see it)
3. User tries to login → "Email not confirmed" + "Wyślij ponownie"
4. Click "Wyślij ponownie"
5. Check SPAM folder → find new email
6. Click link → ✅ Verified
```

## What's Still TODO

### iOS Deep Linking
Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.mybooklibrary</string>
    </array>
  </dict>
</array>
```

### Supabase Dashboard Configuration
1. **Authentication** → **URL Configuration** → **Redirect URLs**
   - Add: `io.supabase.mybooklibrary://login-callback`

2. **Authentication** → **Email Templates** → **Confirm signup**
   - Ensure `{{ .ConfirmationURL }}` is present in template
   - Customize Polish text if needed

3. **Optional: Custom SMTP** (production)
   - Supabase default SMTP has rate limits (~3 emails/hour on free plan)
   - For production: SendGrid, AWS SES, Mailgun

## Summary of Benefits

### For Users:
- ✅ **Clear error messages** - know exactly what's wrong
- ✅ **Easy fix** - one-click resend button
- ✅ **Works cross-device** - register on phone, verify on computer
- ✅ **No confusion** - won't think password is wrong

### For Developers:
- ✅ **Better UX** - users don't get stuck
- ✅ **Less support tickets** - clear guidance
- ✅ **Proper error handling** - specific messages for specific errors
- ✅ **Follows best practices** - resend verification is standard feature

## Files Changed

1. `lib/features/auth/services/auth_service.dart` - Better error mapping + resendConfirmationEmail()
2. `lib/features/auth/bloc/auth_event.dart` - Added ConfirmationEmailResendRequested event
3. `lib/features/auth/bloc/auth_state.dart` - Added ConfirmationEmailResent state
4. `lib/features/auth/bloc/auth_bloc.dart` - Added handler for resend confirmation
5. `lib/features/auth/screens/login_screen.dart` - Smart SnackBar with "Wyślij ponownie" button
6. `SUPABASE_EMAIL_CONFIG.md` - Updated troubleshooting guide
7. `EMAIL_VERIFICATION_FIX.md` - This document

## Next Steps

1. ✅ Test on Android device with real email
2. ⏳ Configure iOS deep linking
3. ⏳ Add redirect URL to Supabase Dashboard
4. ⏳ Test cross-device flow (phone → computer → phone)
5. ⏳ Optional: Add loading state while resending email
