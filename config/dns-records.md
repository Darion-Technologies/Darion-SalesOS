# DNS Records for Email Deliverability

> ⚠️ Replace `yourdomain.com` with your actual outreach domain.
> These records must be added at your domain registrar (GoDaddy, Namecheap, Cloudflare, etc.)

## 1. SPF Record

Authorizes Google's servers to send email on your behalf.

| Field | Value |
|-------|-------|
| **Type** | TXT |
| **Host** | `@` |
| **Value** | `v=spf1 include:_spf.google.com ~all` |
| **TTL** | 3600 |

> **Note:** You must have only ONE SPF record per domain. If you already have an SPF record, merge the `include:` statements.

## 2. DKIM Record

Adds a cryptographic signature to every email you send.

### How to Generate:

1. Go to **Google Workspace Admin** → Apps → Google Workspace → Gmail → Authenticate email
2. Click **Generate New Record**
3. Select **2048-bit** key length
4. Copy the generated value

| Field | Value |
|-------|-------|
| **Type** | TXT |
| **Host** | `google._domainkey` |
| **Value** | *(paste the generated DKIM public key here)* |
| **TTL** | 3600 |

> If using a regular Gmail account (not Workspace), DKIM is automatically handled by Google. You only need to manually configure this if you're using Google Workspace or a custom sending domain.

## 3. DMARC Record

Tells receiving servers what to do with emails that fail SPF/DKIM.

| Field | Value |
|-------|-------|
| **Type** | TXT |
| **Host** | `_dmarc` |
| **Value** | `v=DMARC1; p=none; rua=mailto:dmarc-reports@yourdomain.com; pct=100; adkim=r; aspf=r` |
| **TTL** | 3600 |

> **Start with `p=none`** to monitor. After 2-4 weeks of clean reports, upgrade to `p=quarantine`, then `p=reject`.

## 4. Custom Tracking Domain (Instantly.ai)

Required for open tracking without hurting deliverability.

1. Go to **Instantly.ai** → Settings → Tracking Domain
2. Copy the CNAME target value
3. Add the following DNS record:

| Field | Value |
|-------|-------|
| **Type** | CNAME |
| **Host** | `track` (or as specified by Instantly) |
| **Value** | *(paste Instantly's CNAME target)* |
| **TTL** | 3600 |

## 5. MX Records (if using custom domain for receiving)

If you're using a custom domain with Google Workspace:

| Priority | Host | Value |
|----------|------|-------|
| 1 | `@` | `ASPMX.L.GOOGLE.COM` |
| 5 | `@` | `ALT1.ASPMX.L.GOOGLE.COM` |
| 5 | `@` | `ALT2.ASPMX.L.GOOGLE.COM` |
| 10 | `@` | `ALT3.ASPMX.L.GOOGLE.COM` |
| 10 | `@` | `ALT4.ASPMX.L.GOOGLE.COM` |

## Verification

After adding all records, verify using these tools:

1. **MXToolbox**: https://mxtoolbox.com/SuperTool.aspx — check SPF, DKIM, DMARC
2. **Mail-tester**: https://www.mail-tester.com — send a test email, target score ≥ 9/10
3. **Google Admin Toolbox**: https://toolbox.googleapps.com/apps/checkmx/ — verify MX + DNS
4. **Instantly Health Check**: Built into Instantly dashboard under account settings

## Timeline

| Day | Action |
|-----|--------|
| Day 0 | Add all DNS records |
| Day 0 | Start Instantly warmup |
| Day 1-3 | DNS propagation completes (verify with MXToolbox) |
| Day 1-14 | Warmup runs (20→40 emails/day in warmup pool) |
| Day 14+ | Begin live campaign (30 emails/day) |
