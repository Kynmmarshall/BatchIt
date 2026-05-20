# BatchIt Frontend Sprint Plan

This plan converts the BatchIt frontend checklist into a short, execution-focused sequence. It assumes the customer Flutter app is the priority, with a polished visual design, full English/French localization, and light/dark theme support across every screen.

## Planning Rules

- Build shared foundations before individual screens.
- Treat bilingual copy and theme support as core requirements, not finishing touches.
- Reuse the same components across auth, home, batch, orders, profile, notifications, and future screens.
- Design every screen around the full user flow: launch → auth → browse → batch → join → order → profile.

## Sprint 0: Product and UI Foundation

Goal: define the experience and visual system before expanding the screen count.

Deliverables:
- Final customer-app screen map for MVP and Phase 2.
- Shared design tokens for color, typography, spacing, radius, and motion.
- Theme rules for light and dark modes.
- Localization structure for English and French.
- Navigation map and route names for all planned screens.

Tasks:
- Confirm the MVP screen list from the system plan.
- Define the reusable layout shell for auth, onboarding, and the main app.
- Create the first draft of all global UI components: buttons, inputs, chips, cards, and empty states.
- Agree on a visual direction for gradients, surfaces, shadows, and icon usage.

Exit criteria:
- The app has a shared design language and route strategy.

## Sprint 1: Launch Flow and Authentication

Goal: make the first-launch and sign-in journey feel complete.

Deliverables:
- Splash screen
- Onboarding flow
- Login screen
- Register screen
- Verification code screen if used
- Language switcher available globally
- Theme switcher available globally

Tasks:
- Build the splash screen with a stable startup path.
- Build 2 to 3 onboarding slides that explain the batch concept and provider model.
- Add the optional questionnaire only if it fits the current release window.
- Build the auth screens with the shared auth shell.
- Connect register to verification or the next onboarding step.
- Connect login to the authenticated shell.
- Localize all onboarding and auth copy.

Exit criteria:
- A new user can launch the app, understand it, and create or access an account in both English and French.

## Sprint 2: Core Dashboard and Batch Browsing

Goal: give users a useful home screen and reusable batch presentation components.

Deliverables:
- Home screen
- Batch card component
- Loading and empty states for batch feeds
- Bottom navigation for the main shell

Tasks:
- Build the home screen as the main entry point.
- Add header actions such as notifications and profile access.
- Add batch browsing sections such as nearby batches, active batches, or recommended batches.
- Add search entry if the MVP includes it.
- Build the reusable batch card so it can be used throughout the app.
- Ensure batch labels, status text, and CTA text are localized.

Exit criteria:
- The user can land on a polished dashboard and browse batch content in a consistent way.

## Sprint 3: Batch Lifecycle

Goal: complete the most important product loop.

Deliverables:
- Create batch screen
- Batch details screen
- Join batch screen
- Status states for open, full, confirmed, fulfilled, and expired batches

Tasks:
- Build the create batch form.
- Build the batch details view with quantity progress and provider context.
- Build the join flow with quantity entry and confirmation.
- Add visible status handling for the batch lifecycle.
- Add success, pending, and error feedback states.
- Keep the progress UI and action labels consistent across all batch-related screens.

Exit criteria:
- A user can create, review, join, and understand a batch from start to finish.

## Sprint 4: Orders, Notifications, and Profile

Goal: make the app feel complete after the batch loop is in place.

Deliverables:
- My Batches or My Orders screen
- Notifications screen
- Profile screen
- Settings entries for language and theme

Tasks:
- Build the user’s activity and order history area.
- Build notifications grouped by date with unread styling.
- Build the profile page with user info and preferences.
- Add settings controls for theme and language.
- Add empty states for users with no orders or notifications.
- Localize all status labels and settings copy.

Exit criteria:
- The app supports post-join engagement, preference management, and readable activity history.

## Sprint 5: Expansion Screens

Goal: prepare the customer app for the next phase of the system plan.

Deliverables:
- Provider profile or provider discovery screens
- Map screen
- Chat list and chat room screens if included

Tasks:
- Build provider surfaces only after the core customer loop is stable.
- Add map discovery with privacy-safe approximate locations.
- Add chat UI only when real-time messaging is ready.
- Reuse the same theme, spacing, and localization rules.

Exit criteria:
- The app is ready for broader discovery features without breaking the MVP experience.

## Sprint 6: Quality, Polish, and Release Hardening

Goal: verify the frontend is stable enough for handoff or MVP release.

Deliverables:
- Responsive layout checks
- Accessibility pass
- Localization QA
- Theme QA
- Final navigation QA

Tasks:
- Test small, medium, and large screens.
- Verify dark mode and light mode contrast.
- Verify every visible string in English and French.
- Test the main path: splash → onboarding → auth → home → batch → join → order.
- Confirm loading, empty, and error states are present for the MVP screens.

Exit criteria:
- The frontend is visually consistent, bilingual, theme-aware, and ready to integrate with the backend roadmap.

## MVP Delivery Sequence

If the goal is only the first releasable customer app, build in this exact order:

1. Design system and routes
2. Splash and onboarding
3. Login, register, and verification
4. Home and batch card
5. Create batch, batch details, and join batch
6. Orders, notifications, and profile
7. Final QA for localization, theme, and responsive behavior

## Done Criteria for Frontend MVP

The frontend MVP is done when:

- The main customer flow works without dead ends.
- All required screens are connected.
- English and French are complete for visible UI text.
- Light and dark themes work everywhere.
- Shared components are reused across screens.
- Empty and loading states are handled gracefully.
- The UI matches one consistent design language.
