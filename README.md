# MAU Off-Campus Housing

A Flutter app prototype for discovering and moderating off-campus housing around Maranatha University (MAU). Students can browse approved listings, landlords can submit homes for review, and administrators can moderate listings and reports.

## Features

- Role-based sign-in and separate student, landlord, and administrator workspaces.
- Student property search, availability and amenity filters, and listing details with rent and distance from the MAU gate.
- Student property reviews, listing reports, and a housing-agent contact flow.
- Landlord listing creation with property details and an uploaded image, approval status tracking, and listing deletion.
- Administrator listing approval or rejection and report resolution.

## Run in GitHub Codespaces

The project uses Flutter and Dart. If Flutter was installed in `$HOME/flutter`, add it to the current terminal's `PATH` and fetch dependencies:

```sh
export PATH="$HOME/flutter/bin:$PATH"
flutter doctor
flutter pub get
dart run sqflite_common_ffi_web:setup
curl -fL https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.5.2/sqlite3.wasm -o web/sqlite3.wasm
```

The setup command creates the SQLite worker, but currently downloads a WASM binary that does not match the locked `sqlite3` version. The `curl` command replaces it with the matching 3.5.2 binary. If `sqlite3` changes in `pubspec.lock`, update the release version in this URL too.

Start the app using Flutter's web-server target:

```sh
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081
```

In VS Code, open the **Ports** tab, forward port `8080` if it is not already forwarded, and open the forwarded URL. This web-server workflow does not require Chrome to be installed inside the Codespace. To use `flutter run -d chrome`, install Chrome in the environment and ensure Flutter can find its executable.

If Flutter reports that web is not configured for the project, generate the web platform files and retry:

```sh
flutter create --platforms=web .
```

The SDK path export applies only to the current terminal. To make it persistent in Bash, add `export PATH="$HOME/flutter/bin:$PATH"` to `~/.bashrc` and open a new terminal (or run `source ~/.bashrc`). Android and Linux desktop builds need their respective SDKs and native development tools; see `flutter doctor` for environment-specific requirements.

## Sign In

On the login screen, select the matching **Account type**, enter the email and password, and select **Login**. The app routes each signed-in account to its role's workspace.

Seeded demo accounts:

| Role | Email | Password |
| --- | --- | --- |
| Student | `student@mau.edu.ng` | `student123` |
| Landlord | `landlord@example.com` | `landlord123` |
| Admin | `admin@mau.edu.ng` | `admin123` |

There is also an owner administrator demo account: `jzacks543@gmail.com` / `223344`. These credentials are for local demonstration only. Do not use them or the current authentication implementation for real accounts.

### Create an account

Select **Create account**, choose Student or Landlord, complete the form, and submit. Registration returns to the login screen; sign in with the new account afterward. Admin is not offered as a normal registration role. The owner administrator account is restricted to the seeded owner credentials above.

### default admin accounts
admin@mau.edu.ng / admin123
jzacks543@gmail.com / 223344

## Role Workflows

### Student

1. Sign in using the Student account type.
2. Search approved homes by title, community, or address. Sort listings and filter by availability or amenities.
3. Open a listing to review its description, rent, rooms, amenities, availability, reviews, and distance from the MAU gate.
4. From the listing details, submit a rating and comment, report an issue, or choose **Contact Agent** for housing support and WhatsApp contact.

### Landlord

1. Sign in using the Landlord account type, or create a landlord account.
2. Choose **Add property** and provide the listing details, rent, room count, address, amenities, availability, and an image. Coordinates are optional.
3. Select **Submit for approval**. New listings enter the administrator's pending queue and are not shown in the student search until approved.
4. Return to the landlord workspace to see total, approved, and pending listings. Use a listing's actions menu to delete it.

### Administrator

1. Sign in using the Admin account type and an admin demo account.
2. In **Listing approval queue**, open a listing for details, then approve or reject it. Approved listings become visible to students.
3. In **Report center**, review student reports and select **Resolve** when handled.
4. The landlord profile is available from a listing detail page. The analytics action and displayed trust score are placeholders, not live analytics.

## Project Structure

- `lib/core/`: app constants, routes, service registration, Firebase bootstrap, theme, and validation.
- `lib/domain/`: property, user, review, and report entities.
- `lib/data/`: SQLite user storage and repository implementations.
- `lib/presentation/`: Riverpod providers, role screens, shared widgets, and property flows.
- `android/`, `ios/`, and `linux/`: native platform projects.

## Data and Prototype Limitations

- Accounts are stored locally in SQLite; the repository seeds the demo users on startup. This is not a production authentication service, and passwords are hashed locally without a production-grade identity provider.
- Property listings, reviews, and reports currently use in-memory repositories. Changes to these records are temporary and are lost when the app process is restarted.
- Firebase initialization is attempted but is optional. The current repository implementations do not use Firebase, and no Firebase configuration is required for the local demo.
- Password recovery is not implemented. Student and landlord registrations are local to the running app's database.

Do not use the demo accounts or this prototype's local storage and in-memory data handling for production or sensitive user information.

## Development Checks

Run static analysis with:

```sh
flutter analyze
```

Run tests with `flutter test` when test files are present in the pr