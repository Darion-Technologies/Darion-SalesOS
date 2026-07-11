# Credentials & Connection Checklist

> Update status as you connect each platform.
> Status: ❌ Not Connected | 🔄 In Progress | ✅ Connected

## Platform Connections

| # | Platform | Status | Credential Type | Notes |
|---|----------|--------|-----------------|-------|
| 1 | **Apollo.io** | ❌ | Master API Key | Settings → Integrations → API |
| 2 | **Clay** | ❌ | API Key | Settings → API Keys |
| 3 | **Instantly.ai** | ❌ | API Key | Settings → Integrations → API |
| 4 | **HubSpot** | ❌ | Private App Access Token | Settings → Integrations → Private Apps |
| 5 | **OpenAI** | ❌ | API Key | platform.openai.com → API Keys |
| 6 | **n8n Cloud** | ❌ | Instance URL + Login | Your n8n Cloud dashboard |
| 7 | **Google (Calendar)** | ❌ | OAuth Client ID + Secret | Google Cloud Console → Credentials |
| 8 | **Google (Gmail)** | ❌ | OAuth or App Password | Same project as Calendar |
| 9 | **Razorpay** | ❌ | Key ID + Key Secret | Dashboard → Account & Settings → API Keys |

## n8n Credential Entries

Once connected in n8n, record the credential names here for reference:

| n8n Credential Name | Platform | Type |
|---------------------|----------|------|
| `apollo-api` | Apollo.io | Header Auth |
| `clay-webhook` | Clay | (No credential — webhook URL) |
| `instantly-api` | Instantly.ai | Header Auth |
| `hubspot-private-app` | HubSpot | Access Token |
| `openai-api` | OpenAI | API Key |
| `google-oauth` | Google Calendar + Gmail | OAuth2 |
| `razorpay-api` | Razorpay | Basic Auth (Key ID : Key Secret) |

## DNS Records Status

| Record | Type | Status | Value |
|--------|------|--------|-------|
| SPF | TXT | ❌ | See `dns-records.md` |
| DKIM | TXT | ❌ | Generated from Google Workspace |
| DMARC | TXT | ❌ | See `dns-records.md` |
| Custom Tracking Domain | CNAME | ❌ | From Instantly dashboard |

## Pre-Launch Checklist

- [ ] All 9 platforms connected
- [ ] DNS records verified (SPF, DKIM, DMARC pass)
- [ ] Gmail warmup started in Instantly (14-day minimum)
- [ ] Mail-tester.com score ≥ 9/10
- [ ] Test email sent successfully
- [ ] HubSpot pipeline created
- [ ] All 7 n8n workflows imported and tested
- [ ] Razorpay webhook configured
- [ ] End-to-end dry run completed
