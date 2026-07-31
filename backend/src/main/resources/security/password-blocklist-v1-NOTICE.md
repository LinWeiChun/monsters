# Password blocklist v1

The production list is generated from the SecLists `2026.1` release file
`Passwords/Common-Credentials/10k-most-common.txt`.

- Upstream: https://github.com/danielmiessler/SecLists
- Release: `2026.1`
- License: MIT (`https://github.com/danielmiessler/SecLists/blob/2026.1/LICENSE`)
- Source SHA-256: `4adb3f0afb4a10cf19ebe48d8c69a46f934bbc8d77c694c210564f9583e7f4ba`
- Generated artifact SHA-256: `189f53a4f6852b6d4a19f0a61482a45646ea96f7b7b64ea23eafb28c70f8ecba`
- Matching: exact whole password after Unicode NFC normalization
- Storage: lowercase SHA-256 values only; plaintext candidates are not shipped
- Entries: 10,000 upstream values plus one product regression value

The generated `.sha256` resource must remain versioned with this notice. Updating
the source or transformation requires a new blocklist version and regression tests.
