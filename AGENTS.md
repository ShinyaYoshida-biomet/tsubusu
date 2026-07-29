# Repository contribution rules

## Public OSS privacy

- Do not commit real personal names, usernames, email addresses, account names, machine-specific absolute paths, home-directory paths, or other worker-identifying information.
- Do not hide personal or workstation information in code constants, defaults, comments, fixtures, documentation, examples, generated files, logs, or filenames.
- Use neutral placeholders such as `your-org`, `<TEAM_ID>`, `<BUNDLE_ID>`, `example.com`, or relative paths when documenting local configuration.
- Keep credentials and release files out of Git. This includes API keys, tokens, certificates, provisioning profiles, private keys, and generated archives or packages.
- Supply local-only identifiers through ignored configuration files or environment variables. Commit the variable names and templates, never real values.
- Before committing, scan tracked and staged files for personal identifiers, absolute paths, secrets, and generated artifacts.

## Git history and local changes

- Do not rewrite the history of a branch that has already been pushed unless explicitly requested.
- Preserve unrelated user changes in a dirty worktree.
- If a privacy issue is found after a branch has been pushed, fix it with a new commit and clearly disclose that older history was not rewritten.

## Release automation

- Release workflows must use secure local or CI configuration for credentials and signing material.
- Validation must not upload to external services unless the user explicitly requests or approves that upload.
