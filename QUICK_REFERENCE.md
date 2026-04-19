# 📌 DWELL SYNC - QUICK REFERENCE CARD

## ⚡ QUICK COMMANDS

### Start Development
```bash
cd c:\FlutterProjects\dwell_sync
flutter pub get          # Install dependencies
flutter run             # Run app
flutter run -v          # Run with verbose output
```

### Clean & Rebuild
```bash
flutter clean           # Remove build files
flutter pub get         # Reinstall dependencies
flutter run            # Fresh run
```

### Device Management
```bash
flutter devices        # List available devices
flutter run -d <id>   # Run on specific device
```

---

## 🎨 COLOR CODES (Copy-Paste Ready)

```dart
// Primary Colors
primary: 0xFF155E63      // Teal (Main)
primaryDark: 0xFF0D3B3F  // Teal Dark
primaryLight: 0xFF2E9DA7 // Teal Light

// Status Colors
success: 0xFF4CAF50      // Green (Paid)
error: 0xFFFF5252        // Red (Unpaid)
warning: 0xFFFFC107      // Yellow (Overdue)

// Neutral
white: 0xFFFFFFFF
black: 0xFF000000
grey: 0xFF757575

// Dark Mode
darkBg: 0xFF121212
darkText: 0xFFE0E0E0
```

---

## 🧩 COMMON CODE SNIPPETS

### Access ThemeProvider
```dart
final themeProvider = Provider.of<ThemeProvider>(context);
bool isDark = themeProvider.isDarkMode;
themeProvider.toggleTheme();
```

### Access AuthProvider
```dart
final authProvider = Provider.of<AuthProvider>(context);
if (authProvider.isLandlord()) { }
if (authProvider.isTenant()) { }
```

### Access PaymentProvider
```dart
final paymentProvider = Provider.of<PaymentProvider>(context);
double total = paymentProvider.getTotalAmount();
int pending = paymentProvider.getPendingBillsCount();
```

### Format Currency
```dart
String formatted = FormatUtils.formatCurrency(1500.50);
// Output: $1,500.50
```

### Format Date
```dart
String date = FormatUtils.formatDate(DateTime.now());
// Output: 19 Apr 2026
```

### Navigate to Screen
```dart
Navigator.pushNamed(context, '/login');
Navigator.pushReplacementNamed(context, '/register_landlord');
```

### Create Custom Button
```dart
CustomButton(
  text: 'Click Me',
  onPressed: () {},
  isLoading: false,
  icon: Icons.check,
)
```

### Create Custom Text Field
```dart
CustomTextField(
  label: 'Email',
  hintText: 'Enter email',
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  validator: (value) { return null; },
)
```

---

## 📂 FILE LOCATIONS

| File | Path |
|------|------|
| Main App | `lib/main.dart` |
| Theme Provider | `lib/providers/theme_provider.dart` |
| Auth Provider | `lib/providers/auth_provider.dart` |
| Payment Provider | `lib/providers/payment_provider.dart` |
| Login Screen | `lib/screens/auth/login_screen.dart` |
| Register Landlord | `lib/screens/auth/register_landlord_screen.dart` |
| Register Tenant | `lib/screens/auth/register_tenant_screen.dart` |
| Splash Screen | `lib/screens/splash_screen.dart` |
| Colors | `lib/utils/colors.dart` |
| Format Utils | `lib/utils/format.dart` |
| Custom Button | `lib/widgets/custom_button.dart` |
| Custom TextField | `lib/widgets/custom_text_field.dart` |
| Loading Widget | `lib/widgets/loading.dart` |
| User Model | `lib/models/user.dart` |
| Bill Model | `lib/models/bill.dart` |

---

## 🔄 NAVIGATION ROUTES

```dart
'/splash'                    // Splash screen
'/login'                     // Login screen
'/register_landlord'         // Register as landlord
'/register_tenant'          // Register as tenant
```

---

## 🧪 TEST CREDENTIALS

**Any email/password combination works** (mock data):
- Email: `test@example.com`
- Password: `Password123`

---

## 🎯 NEXT ACTIONS

### After Week 1
- [ ] Review all screens in app
- [ ] Test form validation
- [ ] Check dark mode
- [ ] Navigate through flows
- [ ] Collect teacher feedback

### Before Week 2
- [ ] Create landlord dashboard mockup
- [ ] Create tenant dashboard mockup
- [ ] Plan additional screens
- [ ] Design dashboard layouts

### For Week 2 Implementation
- [ ] Build dashboard screens
- [ ] Add navigation between screens
- [ ] Implement mock data display
- [ ] Add more animations

---

## ❌ COMMON MISTAKES TO AVOID

1. **Forgetting `flutter pub get`**
   - Always run after opening project

2. **Hot Reload Issues**
   - Full restart if hot reload doesn't work
   - Use `flutter run` after `flutter clean`

3. **Widget Not Updating**
   - Ensure using `Consumer` or `Provider.of`
   - Check if `notifyListeners()` is called

4. **Navigation Not Working**
   - Verify route name is exactly same
   - Check route is defined in main.dart

5. **Validation Not Showing**
   - Ensure validator returns error string
   - Check TextFormField is in Form widget

---

## 🔧 USEFUL DEBUG TIPS

### Check Widget Tree
```dart
// In debugger, inspect widget hierarchy
// Use DevTools: flutter pub global activate devtools
devtools
```

### Print Values
```dart
print('Debug: $value');
debugPrint('Debug: $value');
```

### Break Points
- Click line number in IDE to set breakpoint
- Debugger will pause execution

### Hot Reload Shortcut
- Press `r` in terminal while app is running

---

## 📊 PROJECT STATISTICS

- **Total Lines of Code**: 2000+
- **Number of Files**: 16
- **Custom Widgets**: 3
- **Screens**: 4
- **Providers**: 3
- **Models**: 2
- **Development Time**: ~8-10 hours
- **Completion**: ✅ 100%

---

## 🎓 LEARNING RESOURCES

### Flutter Official
- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Samples](https://github.com/flutter/samples)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

### Provider State Management
- [Provider Package](https://pub.dev/packages/provider)
- [Provider Examples](https://github.com/rrousselGit/provider)

### Material Design
- [Material Design 3](https://material.io/design)
- [Material Components](https://material.io/components)

---

## ⚠️ IMPORTANT NOTES

1. **No Backend Yet**
   - All auth is simulated
   - Replace mock logic in providers

2. **Mock Data Only**
   - Bills are stored in memory
   - Add persistence layer in Week 4

3. **Validation is Local**
   - No server-side validation
   - Add backend validation later

4. **Dark Mode Partial**
   - Works in settings
   - Will add theme toggle in Week 2

---

## ✅ WEEKLY CHECKLIST

### Week 1 ✅
- [x] Setup dependencies
- [x] Create models
- [x] Build providers
- [x] Create 4 screens
- [x] Implement theme system
- [x] Create reusable widgets
- [x] Write documentation
- [x] Test all features

### Week 2 🔜
- [ ] Create dashboard screens
- [ ] Implement navigation
- [ ] Add mock data display
- [ ] Create more screens

### Week 3 🔜
- [ ] Polish UI
- [ ] Add animations
- [ ] Refine forms
- [ ] Prepare for midterm

---

## 🚀 PERFORMANCE TIPS

1. **Use const where possible**
   ```dart
   const Widget()  // Better than Widget()
   ```

2. **Use consumer for specific widgets**
   ```dart
   Consumer<Provider>(
     builder: (context, provider, child) { }
   )
   ```

3. **Lazy loading for lists**
   - Use `ListView.builder` instead of `ListView`

4. **Cache images**
   - Use Image.asset for local images

---

## 📞 QUICK HELP

**Problem: App crashes on startup?**
```bash
flutter clean && flutter pub get && flutter run
```

**Problem: Hot reload not working?**
- Press Ctrl+C to stop
- Run `flutter run` again

**Problem: Widgets look weird?**
- Check for overflow errors
- Verify screen size
- Test on different devices

**Problem: Can't navigate?**
- Verify route name matches exactly
- Check route is in main.dart
- Try `pushReplacementNamed` instead of `pushNamed`

---

## 💡 PRODUCTIVITY SHORTCUTS

- `Ctrl+K` → Command palette (VS Code)
- `Ctrl+P` → Quick file open (VS Code)
- `Ctrl+H` → Find and replace (VS Code)
- `Ctrl+/` → Toggle comment (VS Code)
- `F5` → Run with debugger (VS Code)

---

## 📱 DEVICE TESTING

### Android Emulator
```bash
flutter emulators --launch Pixel_4_API_30
```

### iOS Simulator
```bash
open -a Simulator
flutter run
```

### Physical Device
1. Enable USB debugging
2. Connect to computer
3. Run `flutter devices`
4. Run `flutter run -d <device_id>`

---

## 🎨 THEME CUSTOMIZATION QUICK GUIDE

### Change Primary Color
Edit `lib/utils/colors.dart`:
```dart
static const Color primary = Color(0xFF155E63); // Change hex
```

### Change App Title
Edit `lib/main.dart`:
```dart
title: 'DwellSync',  // Change this
```

### Change Button Style
Edit `lib/widgets/custom_button.dart`:
```dart
borderRadius: 8,      // Change corner radius
height: 48,          // Change button height
fontSize: 16,        // Change text size
```

---

## 📋 BEFORE SUBMITTING TO TEACHER

- [ ] App runs without errors
- [ ] No console warnings
- [ ] All buttons work
- [ ] Forms validate correctly
- [ ] Navigation flows smoothly
- [ ] Dark/light theme works
- [ ] Code is formatted nicely
- [ ] Comments are clear
- [ ] Documentation is complete
- [ ] All features from Week 1 list are done

---

**Keep this card nearby while developing!** 🚀

Last Updated: Week 1, April 19, 2026
