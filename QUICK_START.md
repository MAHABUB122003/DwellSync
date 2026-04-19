# DWELL SYNC - QUICK START GUIDE

## ⚡ Get Started in 5 Minutes

### 1. Open Terminal
```bash
cd c:\FlutterProjects\dwell_sync
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
```bash
flutter run
```

### 4. Test the App
- **Splash Screen** → Shows for 3 seconds with animation
- **Login Screen** → Try any email/password
- **Register** → Click "Sign Up as Landlord" or "Sign Up as Tenant"

---

## 📱 Navigation Flow

```
Splash Screen (3 sec)
    ↓
Login Screen
    ├─ Click "Sign In" → Login (simulated)
    ├─ Click "Sign Up as Landlord" → Register Landlord
    └─ Click "Sign Up as Tenant" → Register Tenant
```

---

## 🎨 Key Features

### ✅ Screen 1: Splash Screen
- Professional animated logo
- Auto-navigates to login after 3 seconds
- Smooth fade & scale animation

### ✅ Screen 2: Login Screen
- Email & password input
- Remember me checkbox
- Two registration options
- Beautiful teal color scheme

### ✅ Screen 3: Register Landlord
- Full name, email, phone, password
- Terms & conditions checkbox
- Form validation
- Professional layout

### ✅ Screen 4: Register Tenant
- Same as Landlord but with Tenant-specific messaging
- Icons differentiate roles
- Complete form validation

---

## 🌓 Toggle Dark Mode

To test dark mode:
1. You'll need to add a theme toggle button (coming in Week 2)
2. For now, dark theme is available in system settings

---

## 🔧 Common Tasks

### To Change App Title
Edit `main.dart`:
```dart
title: 'DwellSync',
```

### To Change Primary Color
Edit `lib/utils/colors.dart`:
```dart
static const Color primary = Color(0xFF155E63); // Change hex code
```

### To Modify Button Text
Edit respective screen files (e.g., `login_screen.dart`)

### To Add More Routes
Edit `main.dart` in routes:
```dart
routes: {
  '/new_screen': (context) => const NewScreen(),
}
```

---

## 📊 Project Statistics

- **Total Files Created**: 16
- **Lines of Code**: ~2,000+
- **Custom Widgets**: 3
- **Screens**: 4
- **State Providers**: 3
- **Models**: 2

---

## ✅ Checklist for Teacher Presentation

- [ ] App runs without errors
- [ ] Splash screen displays with animation
- [ ] Login screen is professional looking
- [ ] Can navigate between all screens
- [ ] Form validation works
- [ ] Buttons are responsive
- [ ] Colors match design (teal theme)
- [ ] Dark mode ready (in theme system)
- [ ] All text inputs have icons
- [ ] Loading states show in buttons

---

## 📝 File Locations

| Screen | File |
|--------|------|
| Splash | [lib/screens/splash_screen.dart](lib/screens/splash_screen.dart) |
| Login | [lib/screens/auth/login_screen.dart](lib/screens/auth/login_screen.dart) |
| Register Landlord | [lib/screens/auth/register_landlord_screen.dart](lib/screens/auth/register_landlord_screen.dart) |
| Register Tenant | [lib/screens/auth/register_tenant_screen.dart](lib/screens/auth/register_tenant_screen.dart) |

---

## 🆘 Troubleshooting

### App won't run?
```bash
flutter clean
flutter pub get
flutter run
```

### Dependencies error?
```bash
flutter pub upgrade
```

### Hot reload not working?
- Stop the app (Ctrl+C)
- Run again: `flutter run`

### Seeing old UI?
- Close app completely
- Run: `flutter run -v` (verbose mode)

---

## 📚 What's Next (Week 2)

✅ This week: Frontend design & authentication UI
🔜 Next week: Dashboard screens & navigation
🔜 Week 3: More screens & UI polish
🔜 Week 4: Backend integration
🔜 Week 5+: Full feature implementation

---

## 💡 Tips for Teacher Demo

1. **Show the Theme System**
   - Point out light/dark theme code in `theme_provider.dart`
   - Explain Material Design 3 implementation

2. **Highlight Custom Widgets**
   - Show `custom_button.dart` - reusable button component
   - Show `custom_text_field.dart` - smart text input
   - Explain DRY (Don't Repeat Yourself) principle

3. **Explain State Management**
   - Show how Provider handles themes, auth, payments
   - Explain MultiProvider setup
   - Show Consumer widget usage

4. **Show Code Quality**
   - Point out consistent naming conventions
   - Show model serialization (toJson/fromJson)
   - Explain separation of concerns

5. **Mention 12-Week Plan**
   - Show the roadmap document
   - Explain Week 1-3 focuses on frontend
   - Talk about progressive feature implementation

---

## 🎯 Success Criteria

By end of Week 1, your project should:
- ✅ Run on Android/iOS emulator or physical device
- ✅ Show beautiful splash screen with animation
- ✅ Have working login & registration screens
- ✅ Feature professional UI/UX design
- ✅ Support light & dark themes
- ✅ Include proper form validation
- ✅ Have good code organization
- ✅ Be ready for Week 2 implementation

---

## 📞 Questions?

Refer to:
- [WEEK1_README.md](WEEK1_README.md) - Detailed documentation
- [lib/main.dart](lib/main.dart) - App entry point
- [lib/utils/colors.dart](lib/utils/colors.dart) - Design colors

---

**Happy Coding! 🚀**

Your DwellSync project is off to a great start!
