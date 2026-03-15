# DocVault — Architecture & Product Design

## App Name
**DocVault** — Privacy-first document scanner and secure vault.
*Alternatives: PaperSafe, VaultScan, Doxly, SafeDoc*

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (iOS + Android) |
| State Management | Riverpod 2 (code-gen) |
| Navigation | go_router |
| Local DB | Hive (NoSQL, fast, Flutter-native) |
| Encryption | AES-256-GCM via PointyCastle |
| Key Storage | flutter_secure_storage (Keychain/Keystore) |
| Camera/Scanning | cunning_document_scanner |
| OCR | Google ML Kit (on-device) |
| PDF | pdf + syncfusion_flutter_pdfviewer |
| Biometrics | local_auth |
| Notifications | flutter_local_notifications |
| Monetization | RevenueCat (purchases_flutter) |
| Backup (optional) | Supabase (encrypted blobs only) |

---

## Privacy Architecture

```
Device Only (Default)
┌─────────────────────────────────┐
│  User scans document            │
│  ↓                              │
│  ML Kit OCR (on-device)         │
│  ↓                              │
│  AES-256-GCM encryption         │
│  Key stored in Keychain/Keystore│
│  ↓                              │
│  Encrypted file saved to        │
│  App private storage (sandbox)  │
└─────────────────────────────────┘
         ↓ (Optional Premium)
┌─────────────────────────────────┐
│  Encrypted backup to Supabase   │
│  (Supabase never sees plaintext)│
│  Key stays on device            │
└─────────────────────────────────┘
```

**Key principle:** Supabase only ever receives AES-256 ciphertext. The encryption key never leaves the device.

---

## Database Schema

### DocumentEntity (Hive typeId: 1)
| Field | Type | Description |
|-------|------|-------------|
| id | String | UUID v4 |
| folderId | String | Parent folder |
| title | String | User-visible name |
| type | DocumentType | Enum (passport, license, etc.) |
| createdAt | DateTime | Creation timestamp |
| updatedAt | DateTime | Last modified |
| expiryDate | DateTime? | Extracted or user-set |
| encryptedFilePath | String | Path to .enc file |
| thumbnailPath | String? | Path to encrypted thumbnail |
| ocrText | String? | Full OCR text (for search) |
| extractedFields | Map | {passport_number: ..., etc.} |
| hasReminder | bool | Notification enabled |
| pageCount | int | Number of pages |
| fileSizeBytes | int | Encrypted file size |

### FolderEntity (Hive typeId: 2)
| Field | Type | Description |
|-------|------|-------------|
| id | String | UUID or preset slug |
| name | String | Display name |
| iconEmoji | String | Folder emoji |
| colorHex | String | Brand color |
| documentCount | int | Cached count |
| createdAt | DateTime | |

### Default Folders
- 🪪 Identity (passport, license)
- 💰 Finance (tax, insurance, bank)
- 🏥 Medical (reports, prescriptions)
- 📝 Contracts
- 🧾 Receipts
- 🎓 Certificates
- 📁 Other

---

## UI Screen Map

```
/lock              ← Biometric / PIN gate
/onboarding        ← 3-slide intro + PIN setup
/home              ← Recent docs, expiry alerts, stats
/vault             ← Folder grid
/vault/document/:id ← PDF viewer + metadata
/vault/search      ← Full-text OCR search
/settings          ← Security, subscription, backup
/scan              ← Camera (cunning_document_scanner)
/scan/adjust       ← Edge adjustment preview
/scan/processing   ← OCR + type detection (animated)
/scan/save         ← Title, folder, expiry, tags
/paywall           ← Subscription upsell
```

---

## User Flows

### Scan → Save (Primary)
```
Home → FAB (Scan)
  → Camera (auto edge detection)
  → Processing screen (OCR + type detect)
  → Save screen (pre-filled: type, folder, expiry)
  → Vault → Document
  → [If expiry found] → Enable reminder prompt
```

### Search
```
Home (search icon) or Vault (search icon)
  → Type query
  → Results: title match + OCR text match + type match
  → Tap → Document detail
```

---

## Monetization

### Free Tier
- Scan & save up to 20 documents
- Basic OCR
- Local encrypted storage
- Folder organization

### Premium — $4.99/mo or $39.99 lifetime
- Unlimited documents
- Smart expiry reminders
- Advanced field extraction
- Encrypted cloud backup
- Secure time-limited share links
- Auto-categorization

### RevenueCat Integration
```dart
// Initialize in main.dart (add to production build):
await Purchases.configure(PurchasesConfiguration('YOUR_KEY'));

// Check entitlement:
final info = await Purchases.getCustomerInfo();
final isPremium = info.entitlements.active.containsKey('premium');

// Purchase:
final offerings = await Purchases.getOfferings();
await Purchases.purchasePackage(offerings.current!.monthly!);
```

---

## Encryption Details

### Algorithm: AES-256-GCM
- **Key size:** 256 bits
- **IV:** 96 bits, randomly generated per file
- **Tag:** 128 bits (GCM authentication)
- **Key derivation:** PBKDF2 with SHA-256, 100,000 iterations (for PIN-locked export)

### File format on disk:
```
[IV: 12 bytes] | [GCM Tag: 16 bytes] | [Ciphertext: N bytes]
```

### Key storage:
- iOS: Keychain with `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`
- Android: EncryptedSharedPreferences via Android Keystore

---

## Document Type Classifier

Rule-based keyword matching (no server needed):

| Type | Keywords |
|------|----------|
| Passport | "passport", "nationality", "MRZ", "P<" |
| License | "driver's license", "DL number", "motor vehicle" |
| Insurance | "insurance", "policy number", "coverage", "premium" |
| Medical | "patient", "diagnosis", "prescription", "physician" |
| Tax | "tax return", "form 1040", "W-2", "IRS" |
| Contract | "agreement", "whereas", "hereinafter", "parties agree" |
| Receipt | "receipt", "subtotal", "sales tax", "order number" |
| Certificate | "certificate", "awarded to", "diploma", "degree" |

---

## Differentiation vs CamScanner

| Feature | CamScanner | DocVault |
|---------|-----------|---------|
| Default storage | Cloud | Local only |
| Encryption | Weak | AES-256-GCM |
| OCR location | Server | On-device (ML Kit) |
| Expiry reminders | No | Yes |
| Doc type detection | No | Yes |
| Data monetization | Yes | Never |
| Price | $4.99-$9.99/mo | $4.99/mo or $39.99 |

---

## Growth Strategy to 1M Users

### Phase 1: 0–10K (Months 1–3)
- Product Hunt launch (privacy angle)
- Reddit: r/privacy, r/selfhosted, r/productivity
- ASO: "secure document scanner", "encrypted PDF scanner"

### Phase 2: 10K–100K (Months 4–8)
- Privacy/productivity YouTube sponsorships
- Press: 9to5Mac, Android Authority, Privacy Guides
- Referral: share → 5 extra free document slots

### Phase 3: 100K–1M (Months 9–18)
- Family plan ($9.99/mo for 5 users)
- Localization: Spanish, Arabic, French, German, Hindi
- Enterprise/HIPAA tier for healthcare professionals

---

## 12-Week Development Roadmap

| Weeks | Focus |
|-------|-------|
| 1–2 | Foundation: Flutter setup, Hive DB, encryption, auth, navigation |
| 3–4 | Camera & scanning: edge detection, multi-page, PDF generation |
| 5–6 | OCR & intelligence: ML Kit, type classifier, expiry extractor |
| 7–8 | Vault & organization: encrypted storage, search, PDF viewer |
| 9–10 | Monetization: RevenueCat, paywall, free tier enforcement |
| 11–12 | Polish: reminders, onboarding, dark mode, App Store prep |
