# BatchIt Frontend Task Checklist

Use this checklist to build the BatchIt customer app in a controlled order. The goal is to satisfy the system plan while keeping the UI polished, consistent, bilingual, and theme-aware across every screen.

## Global Requirements

- [ ] Define shared design tokens for color, typography, spacing, radius, shadows, and motion.
- [ ] Verify all primary screens work in both light and dark themes.
- [ ] Add full English and French localization coverage for visible UI text.
- [ ] Remove hardcoded strings from screens, widgets, buttons, labels, empty states, and fallbacks.
- [ ] Use reusable components instead of designing each screen independently.
- [ ] Create loading, empty, error, and offline-friendly states in the shared design system.
- [ ] Keep navigation and screen flow consistent across the entire app.

## Phase 1: App Foundation

- [ ] Lock the final screen map for the customer app MVP.
- [ ] Set up route constants for all screens in the plan.
- [ ] Configure the main app shell and startup flow.
- [ ] Add splash screen behavior for first launch and returning users.
- [ ] Add onboarding flow with 2 to 3 slides.
- [ ] Add the questionnaire screen if it is part of the current release.
- [ ] Add a global language switcher that works from every screen.
- [ ] Add a global theme switcher that works from every screen.

## Phase 2: Authentication

- [ ] Build the login screen with the shared auth shell.
- [ ] Build the register screen with the shared auth shell.
- [ ] Build the verification code screen if signup requires verification.
- [ ] Add forgot password flow or a temporary placeholder if deferred.
- [ ] Wire login navigation to the main shell.
- [ ] Wire register navigation to verification or next-step onboarding.
- [ ] Wire sign-in and sign-up links so users can switch between them in one tap.
- [ ] Localize all auth labels, hints, validation text, and CTA labels.

## Phase 3: Home and Browsing

- [ ] Build the home screen as the app’s main dashboard.
- [ ] Add a header area with brand, notifications, and profile access.
- [ ] Add search entry or search mode toggle if included in MVP.
- [ ] Add active batches or recommended batches sections.
- [ ] Add popular providers or nearby batch sections if supported.
- [ ] Add bottom navigation for the core app flow.
- [ ] Create empty and loading states for the home feed.
- [ ] Ensure section titles and buttons are localized.

## Phase 4: Batch Core Components

- [ ] Build a reusable batch card component.
- [ ] Include product image, product name, provider or hub name, progress, and CTA.
- [ ] Show quantity progress in a clear and consistent format.
- [ ] Make the batch card reusable across home, search, provider, and notification views.
- [ ] Ensure the batch card respects both light and dark themes.
- [ ] Add truncation rules for long product and provider names.

## Phase 5: Batch Flow

- [ ] Build create batch screen.
- [ ] Add product selection UI.
- [ ] Add quantity input UI.
- [ ] Add provider selection or batch destination selection UI.
- [ ] Add optional note or deadline input.
- [ ] Build batch details screen.
- [ ] Show product info, quantity progress, participants, provider info, and join CTA.
- [ ] Build join batch screen.
- [ ] Add quantity entry and confirmation actions.
- [ ] Show success and pending states after joining.
- [ ] Add status states such as open, filled, confirmed, fulfilled, and expired.

## Phase 6: Orders and Participation

- [ ] Build My Batches or My Orders screen.
- [ ] Show active, pending, fulfilled, and completed items clearly.
- [ ] Add order details screen if included in current scope.
- [ ] Show pickup or fulfillment status where relevant.
- [ ] Add empty state when the user has no active orders.
- [ ] Keep all order status labels localized.

## Phase 7: Notifications and Empty States

- [ ] Build the notifications screen.
- [ ] Group notifications by date such as Today, Yesterday, and Earlier.
- [ ] Show notification icon, summary, timestamp, and destination link.
- [ ] Add unread/read styling.
- [ ] Add mark-all-read behavior if included in scope.
- [ ] Localize all notification titles and system messages.
- [ ] Add reusable empty-state components for batches, orders, and notifications.

## Phase 8: Profile and Settings

- [ ] Build the profile screen.
- [ ] Add user identity, avatar, and basic account summary.
- [ ] Add settings entry points for theme and language.
- [ ] Add subscription management entry if the screen is in scope.
- [ ] Add notification preferences if the screen is in scope.
- [ ] Add edit profile screen if required by the MVP.
- [ ] Add order history access from profile.
- [ ] Localize all profile labels and helper text.

## Phase 9: Provider Surfaces

- [ ] Build provider profile screen if included in the frontend scope.
- [ ] Build provider discovery screen if needed.
- [ ] Show provider branding, description, and active batches.
- [ ] Add subscription actions and status.
- [ ] Make provider surfaces visually consistent with customer surfaces.

## Phase 10: Maps and Discovery

- [ ] Build map screen after the core batch flow is stable.
- [ ] Show nearby batches, providers, and hubs using privacy-safe approximate locations.
- [ ] Add map marker detail sheet with quick join or view action.
- [ ] Make the map UI match the app’s theme and spacing system.
- [ ] Localize map labels, tooltips, and sheet actions.

## Phase 11: Chat and Advanced Features

- [ ] Add chat list screen if it is part of the current phase.
- [ ] Build chat room screen with sender bubbles and input area.
- [ ] Add typing, sending, and empty-message states.
- [ ] Add smart notification or in-app message states if required.
- [ ] Keep chat UI lightweight and readable in both themes.

## Phase 12: Quality and Polish

- [ ] Validate responsive layouts on small, medium, and large screens.
- [ ] Check contrast in light mode and dark mode.
- [ ] Verify accessibility basics such as tap targets, labels, and readable text sizes.
- [ ] Ensure every screen has a coherent visual style.
- [ ] Verify English and French translations on all visible screens.
- [ ] Verify global language switching does not break navigation.
- [ ] Verify global theme switching does not break layout or contrast.
- [ ] Test the main flow: splash → onboarding → auth → home → batch → join → order/status.

## MVP Release Gate

The frontend is ready for MVP launch when all of the following are true:

- [ ] Login, register, home, create batch, batch details, join batch, orders, profile, and notifications screens are complete.
- [ ] Every visible text string has English and French support.
- [ ] Light and dark themes work consistently across all completed screens.
- [ ] Shared components are reused instead of duplicated.
- [ ] Loading, empty, and error states are styled and tested.
- [ ] Navigation flows match the BatchIt system plan.

## Suggested Build Order

1. Design system and global tokens
2. Routing and app shell
3. Localization and theme controls
4. Splash and onboarding
5. Login, register, and verification
6. Home and batch card
7. Batch create, details, and join
8. My orders and notifications
9. Profile and settings
10. Provider, map, and chat screens
11. Polish, accessibility, and QA
