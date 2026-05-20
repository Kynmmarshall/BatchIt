# BatchIt Frontend Task Checklist

Use this checklist to build the BatchIt customer app in a controlled order. It tracks the requirements from the walkthrough and keeps the frontend aligned with the system plan, bilingual support, and the shared design language.

## Current Done Items

- [x] Add a dedicated settings screen for theme and language.
- [x] Remove theme and language controls from the profile screen.
- [x] Redesign the home dashboard to use a richer app shell style.
- [x] Rework batch details to match the dashboard visual language.
- [x] Add questionnaire flow between onboarding and login.
- [x] Add English and French localization keys for the current UI.

## 1. Global Foundation

- [ ] Finalize the shared design tokens for colors, typography, spacing, radius, shadows, and motion.
- [ ] Confirm the light theme and dark theme palettes work on all existing screens.
- [ ] Keep all screens using the same rounded, layered, polished visual language.
- [ ] Make loading, empty, and error states part of the same design system.
- [ ] Verify every visible label, button, helper text, and fallback is localized.
- [ ] Keep reusable components as the default approach instead of one-off screen styling.
- [ ] Ensure the app uses a single navigation language and no screen feels isolated.

## 2. App Structure

- [ ] Lock the final MVP screen map from the system plan.
- [ ] Confirm the route constants for onboarding, auth, questionnaire, home, batch, orders, profile, settings, map, and chat.
- [ ] Keep the startup flow stable for splash, onboarding, and authenticated shell entry.
- [ ] Review the shared auth shell so login, register, and questionnaire stay visually consistent.
- [ ] Review the main shell layout so home, create batch, orders, and profile work as one app.

## 3. Splash and Onboarding

- [x] Keep the splash screen as the first launch entry.
- [x] Keep onboarding slides localized in English and French.
- [ ] Polish onboarding copy so it clearly explains batches, providers, and savings.
- [ ] Verify onboarding CTA behavior on every slide.
- [x] Route the final onboarding action into the questionnaire step.
- [ ] Confirm onboarding backgrounds, image assets, and layout feel consistent in both themes.

## 4. Questionnaire

- [x] Add the questionnaire screen.
- [ ] Refine questionnaire categories so they feel like product preferences, not placeholder chips.
- [ ] Add or adjust preference chips for shopping frequency, region, and budget range.
- [ ] Keep questionnaire labels and actions localized in both languages.
- [ ] Make sure the questionnaire can be skipped cleanly without breaking the flow.
- [ ] Store selected preferences in a proper model or provider when backend state is ready.

## 5. Authentication

- [x] Keep the login screen connected to the shell.
- [x] Keep the register screen connected to the verification flow.
- [ ] Polish login spacing and text wrapping for French copy.
- [ ] Confirm auth labels, hints, validation messages, and footer text are localized.
- [ ] Add or confirm the forgot password behavior.
- [ ] Verify login and register transitions remain smooth on smaller screens.
- [ ] Keep the auth shell background and translucent card styling consistent.

## 6. Home Dashboard

- [x] Keep the home screen in the new dashboard style.
- [ ] Review the hero summary card for spacing, contrast, and clarity.
- [ ] Keep the search affordance visible and easy to scan.
- [ ] Keep active batches visible as a horizontal rail.
- [ ] Keep the filters for nearby, open, and full batches.
- [ ] Keep the recommended batch feed responsive for smaller devices.
- [ ] Add or confirm proper empty and loading states for the dashboard sections.
- [ ] Keep home section titles and buttons localized.

## 7. Batch Card Component

- [x] Keep the reusable batch card in place.
- [ ] Confirm the card works in list and grid layouts.
- [ ] Make sure the card supports long product and provider names without overflow.
- [ ] Keep the progress label, quantity summary, and CTA consistent.
- [ ] Verify the card stays theme-aware in both light and dark modes.
- [ ] Reuse the same card structure in home, details, orders, and future provider views.

## 8. Batch Lifecycle Screens

- [x] Keep batch details aligned with the dashboard visual style.
- [ ] Build the create batch screen.
- [ ] Add product selection UI to the create batch flow.
- [ ] Add quantity entry and validation to the create batch flow.
- [ ] Add provider or destination selection to the create batch flow.
- [ ] Add optional note or deadline fields if the plan keeps them in MVP.
- [ ] Build the join batch screen.
- [ ] Add quantity entry and confirm actions in the join flow.
- [ ] Make batch status states visible: open, full, confirmed, fulfilled, expired.
- [ ] Keep the quantity format consistent everywhere, for example 23 kg / 50 kg.

## 9. Orders and Participation

- [ ] Build the My Orders / My Batches screen.
- [ ] Show active, pending, fulfilled, and completed states clearly.
- [ ] Add an order details screen if it remains in the MVP scope.
- [ ] Show pickup or fulfillment status where relevant.
- [ ] Add a strong empty state for users with no orders.
- [ ] Keep all order status labels localized.

## 10. Notifications and Empty States

- [ ] Build the notifications screen.
- [ ] Group notifications by date buckets such as Today, Yesterday, and Earlier.
- [ ] Show the notification icon, summary, timestamp, and tap destination.
- [ ] Add unread styling and a mark-all-read action if needed.
- [ ] Keep notification copy localized.
- [ ] Reuse one empty-state style across notifications, orders, and batch lists.

## 11. Profile and Settings

- [x] Keep profile focused on identity and account actions.
- [x] Move theme and language controls into settings.
- [x] Keep a dedicated settings screen reachable from profile.
- [ ] Add order history access from profile if needed.
- [ ] Add subscription management entry if the MVP includes it.
- [ ] Add notification preferences if the plan includes them now.
- [ ] Make profile labels and helper text fully localized.

## 12. Provider Discovery and Related Surfaces

- [ ] Build provider profile screen if the frontend scope includes it now.
- [ ] Build provider discovery if it is needed for MVP browsing.
- [ ] Show provider branding, description, and active batches consistently.
- [ ] Add subscription actions and visible subscription state.
- [ ] Keep provider surfaces visually aligned with customer surfaces.

## 13. Maps and Discovery

- [ ] Build the map screen after the core batch flow is stable.
- [ ] Show nearby batches, providers, and hubs with privacy-safe approximate locations.
- [ ] Add a map marker bottom sheet or detail popup with quick join or view action.
- [ ] Keep map labels, tooltips, and sheet actions localized.
- [ ] Make map visuals match the same theme and spacing system as the rest of the app.

## 14. Chat and Advanced Real-Time Features

- [ ] Add the chat list screen if it becomes part of the next phase.
- [ ] Build the chat room screen with message bubbles and a composer.
- [ ] Add typing, sending, and empty-message states.
- [ ] Keep chat UI lightweight and readable in both themes.
- [ ] Localize system messages and empty-state copy.

## 15. Accessibility and Polish

- [ ] Validate responsive layouts on small, medium, and large screens.
- [ ] Check color contrast in light mode and dark mode.
- [ ] Verify tap targets, labels, and text size readability.
- [ ] Make sure animations support the experience instead of distracting from it.
- [ ] Keep every screen coherent with the same visual language.

## 16. Localization QA

- [ ] Verify every visible screen has English and French coverage.
- [ ] Check that switching locale does not break navigation or layouts.
- [ ] Re-run localization generation whenever new text is added.
- [ ] Avoid hardcoded strings in any new widget or screen.
- [ ] Keep dynamic or plural strings as localization keys.

## 17. Theme QA

- [ ] Verify the app starts in the expected theme mode.
- [ ] Confirm the theme toggle works from settings.
- [ ] Confirm theme changes update all visible screens.
- [ ] Check that cards, inputs, chips, and progress bars remain readable in dark mode.
- [ ] Keep the same component shapes and surfaces in both themes.

## 18. Release Gate

- [ ] Confirm login, register, questionnaire, home, create batch, batch details, join batch, orders, profile, and notifications are all present.
- [ ] Confirm every visible string is localized in English and French.
- [ ] Confirm light and dark themes are stable across all completed screens.
- [ ] Confirm shared components are reused instead of duplicated.
- [ ] Confirm loading, empty, and error states are implemented for the main flows.
- [ ] Confirm navigation matches the BatchIt system plan.

## 19. Suggested Build Order

1. Design system and shared tokens
2. Routing and app shell
3. Localization and theme controls
4. Splash and onboarding
5. Questionnaire
6. Login, register, and verification
7. Home dashboard
8. Batch card and batch lifecycle screens
9. Orders, notifications, and profile/settings
10. Provider, map, and chat screens
11. Polish, accessibility, and QA
