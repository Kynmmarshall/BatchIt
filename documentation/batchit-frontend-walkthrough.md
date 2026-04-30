# BatchIt Frontend Walkthrough

This document turns the BatchIt system plan into a practical frontend execution path for the customer Flutter app. It focuses on the screens, flows, design system, localization, and theme work needed to satisfy the plan while keeping the product polished, consistent, and ready for later backend expansion.

## Frontend Principles

Use the same visual language everywhere.

- Build one shared design system first, then compose screens from it.
- Keep the UI bilingual from the start: English and French only.
- Support both light and dark themes on every screen.
- Design for the full user flow, not isolated pages.
- Prefer reusable components over one-off screen styling.
- Make loading, empty, and error states part of the design system.

## Scope From the System Plan

The PDF describes a customer app MVP first, then later phases for maps, chat, intelligence, and provider tooling. For frontend delivery, treat the work in two layers:

- MVP customer app: onboarding, questionnaire, auth, home, create batch, batch detail, join batch, my batches/orders, notifications, profile, settings.
- Expansion screens: provider profile, provider discovery, map, chat, advanced notifications, hub dashboard.

## Step-by-Step Walkthrough

### 1. Freeze the screen map

Start by locking the screen inventory from the system plan and grouping it into priority buckets.

Must-have MVP screens:
- Splash / onboarding
- Questionnaire
- Login
- Register
- Home
- Create batch
- Batch details
- Join batch
- My batches / My orders
- Notifications
- Profile
- Settings

Later-phase screens:
- Search results
- Provider profile
- Provider discovery
- Map
- Chat room
- Hub dashboard
- Edit profile
- Order details

Deliverable:
- A single screen inventory with priorities and navigation links.

### 2. Define the shared design system

Before building more screens, define the tokens that every page will use.

Create these design foundations:
- Color tokens for light and dark themes
- Typography scale
- Spacing scale
- Border radius scale
- Shadows and surface styles
- Icon sizing rules
- Button, chip, card, input, and sheet styles

Use the same language across the app:
- Rounded surfaces
- Strong hierarchy for titles and summaries
- Clear CTA buttons
- Subtle gradients and layered backgrounds
- No screen should feel visually unrelated to the rest

Deliverable:
- Theme tokens and reusable UI primitives ready for reuse on all screens.

### 3. Set up global app structure

Build the shell that all screens live inside.

Frontend tasks:
- Configure routing for every screen in the plan.
- Add a startup flow that chooses splash or authenticated shell.
- Keep navigation predictable with named routes.
- Add shared layout containers for auth, onboarding, and main app sections.

Recommended structure:
- Splash flow
- Onboarding flow
- Auth flow
- Main shell flow
- Detail flows pushed on top of the shell

Deliverable:
- Stable navigation skeleton with no screen built in isolation.

### 4. Make localization and theme global from day one

This is not a polish step. It is a foundation step.

Localization tasks:
- Add English and French ARB keys for all copy.
- Avoid hardcoded UI text in widgets.
- Localize labels, empty states, buttons, helper text, and fallback messages.
- Keep pluralizable or dynamic text as keyed format strings.

Theme tasks:
- Make every screen respond to the current brightness.
- Use the same widgets in both themes, not separate screen copies.
- Validate contrast in dark mode and light mode.

Deliverable:
- Every visible string and every visible screen state can switch language and theme without layout breakage.

### 5. Build the splash and onboarding flow

The system plan calls for a first-launch walkthrough that explains the product and its provider-centric model.

Build the flow in this order:
1. Splash screen with brand presence and loading state.
2. 2 to 3 onboarding slides with a strong visual story.
3. Optional questionnaire step that captures interests, frequency, region, and budget.
4. Login or register entry point.

Onboarding content should explain:
- What a batch is
- Why the provider model exists
- How users save money by joining batches
- How the app uses location and subscriptions to surface relevant batches

Design requirements:
- Use one consistent background treatment across onboarding.
- Keep the CTA clear and repeated on every slide.
- Make the slides localized in English and French.

Deliverable:
- A complete first-run flow that leads a new user from launch to account creation.

### 6. Implement authentication screens

Auth is part of the MVP and should feel premium, not generic.

Build these screens:
- Login
- Register
- Forgot password placeholder or actual flow
- Verification code screen if the signup flow uses email verification

Tasks per screen:
- Use the same visual shell and background treatment.
- Keep form fields consistent with shared input components.
- Localize all labels, validation messages, and helper copy.
- Add clear actions for sign in, sign up, and social login entry points.

Flow requirements:
- Register should link to verification if required.
- Login should lead to the main shell on success.
- Switching between sign in and sign up should be one tap.

Deliverable:
- Fully connected auth flow that feels cohesive in both themes and both languages.

### 7. Build the home screen as the main dashboard

The home screen is the app’s main entry point and should reflect the plan’s recommendation feed plus active batches.

Include these UI sections:
- Top header with branding, notifications, and profile entry
- Search bar or search mode toggle
- Active batches banner
- Popular providers section if shown in the MVP
- Recommended or nearby batch feed
- Bottom navigation

Frontend requirements:
- Show real loading, empty, and error states.
- Support search states even if backend search is limited early.
- Make the screen responsive for smaller devices.
- Localize section labels and CTA text.

Deliverable:
- A strong dashboard that leads users naturally into browsing, joining, or creating batches.

### 8. Build the batch card component before the full batch flow

The batch card is the reusable core component for the app.

Card content from the plan:
- Product image
- Product name
- Provider name or hub name
- Progress bar or quantity summary
- Participant count
- Price information
- Join or view CTA
- Time or status label

Implementation guidance:
- Make the card reusable in home, search results, provider pages, and notifications.
- Keep it theme-aware.
- Keep all labels localized.
- Ensure long text truncates gracefully.

Deliverable:
- A single batch card component that can power every list and feed screen.

### 9. Build batch creation, details, and join flows

This is the main product loop, so it deserves the most careful frontend work.

Batch creation flow:
- Choose product
- Enter quantity
- Choose provider or batch destination
- Add note or deadline if supported
- Submit batch

Batch detail flow:
- Show product info
- Show quantity progress clearly
- Show participants or claimed quantity
- Show provider or hub details
- Show join CTA and status

Join flow:
- Enter desired quantity
- Confirm participation
- Show confirmation state and resulting order status

Design requirements:
- Use the same progress language everywhere, for example 23 kg / 50 kg.
- Show batch states clearly: open, full, confirmed, fulfilled, expired.
- Make the join action obvious and persistent.

Deliverable:
- A complete create -> join -> details loop that matches the system plan.

### 10. Build my batches, orders, and status tracking

The plan treats batch participation and order status as a recurring user need.

Screen tasks:
- List active batches the user created or joined
- Show completed or fulfilled items separately
- Present order status clearly: pending, ready, picked, completed
- Add order details if included in the current release

Frontend notes:
- Use compact status chips and timeline-style rows.
- Keep the wording localized and consistent.
- Provide empty states for users with no activity.

Deliverable:
- A clear history and status area that keeps users informed after joining a batch.

### 11. Build notifications and empty-state patterns

The system plan includes notifications as a core interaction layer.

Notifications UI should support:
- New batch alerts
- Batch filled alerts
- Order ready alerts
- Batch expired alerts
- Profile completion reminders

Frontend tasks:
- Create grouped notification sections such as Today, Yesterday, This Week.
- Use icon + summary + timestamp patterns.
- Add unread styling and mark-all-read behavior.
- Reuse the same empty and error state style everywhere.

Deliverable:
- A notification experience that is readable, actionable, and localized.

### 12. Build profile and settings around user control

The plan calls out profile completion, theme switching, language switching, and subscription management.

Profile screen should include:
- User avatar and basic identity
- Order history entry point
- Subscriptions or provider preferences
- Theme toggle
- Language toggle
- Notification preferences

Design requirements:
- Make settings feel like part of the same app, not a separate admin panel.
- Put theme and language controls where users can actually find them.
- Use the same design language for profile rows, cards, and toggles.

Deliverable:
- A self-service profile area that handles personalization and preferences.

### 13. Add provider-facing discovery UI if it belongs in the current frontend scope

The system plan is provider-centric, so customer UI should still acknowledge providers.

Frontend screens to add when ready:
- Provider profile
- Provider discovery list
- Provider catalogue or active batches under a provider
- Subscription button and subscription state

Tasks:
- Show provider branding consistently.
- Present provider subscription status clearly.
- Surface active batches per provider.

Deliverable:
- Customer-facing provider surfaces that support the system plan’s subscription model.

### 14. Add maps only after the core batch loop is stable

The plan marks maps as important, but it is safer to build them after the core batch UX works.

Map UI should support:
- Nearby batches
- Providers and hubs
- Privacy-safe approximate locations
- Quick join entry points from map markers or bottom sheets

Design requirements:
- Keep the map visually integrated with the app theme.
- Avoid exposing exact home locations.
- Make map details readable in both languages.

Deliverable:
- A map view that supports discovery without weakening privacy or design consistency.

### 15. Add chat and advanced interaction screens later

Chat and advanced real-time UI should be treated as Phase 2 frontend work unless the backend is already ready.

Screens and components:
- Chat list
- Chat room
- Sender bubbles
- Input composer
- Typing or sending states

Frontend notes:
- Reuse message bubble and timestamp styles everywhere.
- Localize system messages and empty states.
- Keep the chat screen lightweight and readable.

Deliverable:
- A clean chat UI that can plug into real-time updates later.

### 16. Polish for accessibility, responsiveness, and motion

Once the flows work, polish them.

Check for:
- Contrast in dark mode and light mode
- Readable typography on smaller phones
- Safe padding and scrolling behavior
- Animation that supports the experience instead of distracting from it
- Tap targets large enough for mobile use

Deliverable:
- A polished interface that feels deliberate, stable, and production-ready.

### 17. Test the full flow end to end

Before calling the frontend done, verify the complete customer flow.

Test scenarios:
- New user launch through onboarding to register
- Returning user launch straight to authenticated flow
- Create batch and join batch
- Empty batch list and empty notification states
- Switching between English and French
- Switching between light and dark mode
- Long text and smaller screen layouts

Deliverable:
- A verified frontend flow that matches the system plan and works in both locales and both themes.

## Recommended Build Order

If you want the fastest path to a usable frontend, build in this order:

1. Theme tokens and design system
2. Routing and app shell
3. Localization and theme switching
4. Splash and onboarding
5. Auth screens
6. Home screen
7. Batch card component
8. Batch details and join flow
9. Create batch flow
10. Profile and settings
11. Notifications
12. Search and provider discovery
13. Map
14. Chat
15. Final polish and QA

## MVP Frontend Acceptance Criteria

The frontend is ready for MVP when:

- All core customer screens exist and are linked.
- Every visible string is localized in English and French.
- Light and dark themes work on every screen.
- The batch lifecycle is visible through cards, details, join, and status views.
- Empty, loading, and error states are styled consistently.
- The design language is consistent across auth, home, batch, profile, and notifications.

## Practical Note

The system plan includes backend-heavy areas such as payments, provider portals, advanced search, and intelligence. For the frontend, keep those routes and UI surfaces ready in the design system, but do not block MVP delivery on backend complexity.

That keeps the customer app aligned with the plan while still letting you ship the important screens first.