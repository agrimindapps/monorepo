# Static/Informational Pages

These are simple, static pages that don't require full Clean Architecture implementation.

## Active Pages

- **sobre.dart** - About page
  - Shows app information, contact, external links
  - Simple StatefulWidget with standard Flutter code
  - No complex state management needed

- **atualizacao.dart** - Updates/Changelog page
  - Displays app update history and changelog
  - Simple StatefulWidget with static content
  - No complex state management needed

## Status

✅ These pages are **production-ready** and actively used in the app router.
✅ They use standard Flutter patterns (no GetX).
✅ Simple informational pages don't need Clean Architecture overhead.

## Note

Not all pages need to follow Clean Architecture. Static/informational pages like these are perfectly fine as simple StatefulWidgets.
