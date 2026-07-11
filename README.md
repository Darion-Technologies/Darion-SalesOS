# Darion SalesOS

**Fully automated AI sales pipeline — from lead sourcing to payment collection.**

Built with Apollo · Clay · Instantly · GPT · HubSpot · n8n · Google Calendar · Razorpay

---

## Overview

SalesOS is a no-code sales automation system that connects 8 SaaS platforms through 7 n8n workflows to create an end-to-end pipeline: find leads → enrich → personalize → outreach → classify replies → book meetings → collect payments → onboard clients.

```
Apollo ──→ Clay ──→ GPT ──→ Instantly ──→ Gmail
                                           │
                                     Reply detected
                                           │
                                     GPT Classifier
                                      ┌────┴────┐
                                Interested   Not Interested
                                      │           │
                                  HubSpot    Archive
                                      │
                               Google Meet
                                      │
                               Razorpay Link
                                      │
                              Onboarding Email
```

## Features

- **AI Lead Scoring** — GPT rates every lead 1–10 against your ICP; only scores ≥ 7 enter campaigns
- **Personalized Outreach** — Every cold email is uniquely written by GPT using enriched company data
- **Smart Reply Classification** — Incoming replies are classified into 7 categories with auto-routing
- **Auto Meeting Booking** — Google Calendar events with Meet links created automatically
- **Manual Payment Gate** — Razorpay payment links generated only after your explicit approval
- **CRM Sync** — HubSpot contacts, deals, and notes updated at every pipeline stage
- **Real-time Notifications** — Email alerts for replies, bookings, and payments

## Architecture

| Layer | Tool | Purpose |
|-------|------|---------|
| Lead Sourcing | Apollo.io | ICP-based contact search |
| Enrichment | Clay | Company data, news, tech stack |
| AI | OpenAI GPT-4o/5.5 | Personalization, classification, briefs |
| Outreach | Instantly.ai | Email sequences with warmup |
| CRM | HubSpot Free | Contacts, deals, pipeline |
| Scheduling | Google Calendar + Meet | Auto-created meetings |
| Payments | Razorpay | Payment link generation |
| Orchestration | n8n Cloud | Workflow engine connecting everything |

## Project Structure

```
├── .env.example              # Environment variables template
├── resolve-env.sh            # Script to inject .env values into all files
│
├── config/
│   ├── credentials-checklist.md    # Platform connection tracker
│   ├── dns-records.md              # SPF / DKIM / DMARC setup guide
│   ├── apollo-icp.json             # Ideal Customer Profile definitions
│   ├── clay-table-schema.json      # Enrichment table with 19 columns
│   └── hubspot-pipeline.json       # 9-stage pipeline + custom properties
│
├── prompts/
│   ├── clay-enrichment.md          # Lead scoring + pain point analysis
│   ├── outreach-personalizer.md    # Cold email generation (75 words max)
│   ├── reply-classifier.md         # 7-category reply classification
│   ├── lead-summarizer.md          # Pre-call brief for HubSpot notes
│   └── service-matcher.md          # Service recommendation engine
│
├── campaigns/
│   ├── primary-outreach.json       # Instantly campaign configuration
│   └── email-sequences.md          # 3-step email sequence + A/B testing
│
├── workflows/
│   ├── 01-apollo-to-clay.json      # Daily lead sourcing + deduplication
│   ├── 02-clay-to-instantly.json   # Enriched leads → personalized campaign
│   ├── 03-reply-classification.json # Gmail → GPT classify → route
│   ├── 04-interested-to-hubspot.json # Lead brief + meeting request
│   ├── 05-meeting-booking.json     # Google Calendar + Meet link
│   ├── 06-razorpay-payment.json    # Manual approval → payment link
│   └── 07-payment-onboarding.json  # Payment → onboarding + kickoff
│
└── docs/
    ├── system-architecture.md      # Full technical documentation
    └── runbook.md                  # Daily ops, troubleshooting, scaling
```

## Quick Start

### 1. Clone and configure

```bash
git clone https://github.com/Darion-Technologies/Darion-SalesOS.git
cd Darion-SalesOS
cp .env.example .env
```

### 2. Fill in your credentials

Open `.env` and add your API keys for all 8 platforms. See [`config/credentials-checklist.md`](config/credentials-checklist.md) for where to find each key.

### 3. Inject values into files

```bash
# Preview changes (dry run)
./resolve-env.sh

# Apply to all workflow, config, and campaign files
./resolve-env.sh --apply
```

### 4. Set up email deliverability

Follow the DNS setup guide in [`config/dns-records.md`](config/dns-records.md) to configure SPF, DKIM, and DMARC on your outreach domain.

### 5. Import workflows into n8n

1. Log into your n8n Cloud instance
2. Go to **Workflows → Import from File**
3. Import each JSON from `workflows/` in order (01 through 07)
4. Configure credentials in each workflow node
5. Activate all workflows

### 6. Configure platforms

| Step | Platform | Action |
|------|----------|--------|
| 1 | HubSpot | Create pipeline + custom properties per [`hubspot-pipeline.json`](config/hubspot-pipeline.json) |
| 2 | Clay | Create table matching [`clay-table-schema.json`](config/clay-table-schema.json) |
| 3 | Instantly | Create campaign with [`primary-outreach.json`](campaigns/primary-outreach.json) settings |
| 4 | Razorpay | Add webhook URL pointing to n8n Workflow 07 |
| 5 | Gmail | Connect to Instantly and start warmup |

### 7. Start warmup and launch

> **Important:** Email warmup takes 14 days minimum. The system configures in ~60 minutes, but campaigns should wait until warmup completes.

## Workflows

| # | Name | Trigger | Description |
|---|------|---------|-------------|
| 01 | Apollo → Clay | ⏰ Daily 8 AM IST | Searches Apollo for ICP matches, deduplicates against HubSpot, pushes to Clay |
| 02 | Clay → Instantly | 🪝 Webhook | Receives enriched leads, generates personalized email via GPT, adds to Instantly campaign, creates HubSpot contact + deal |
| 03 | Reply Classification | 📧 Gmail poll (2 min) | Detects replies, classifies via GPT (Interested / Not Interested / Objection / Referral / OOO / Spam), routes accordingly |
| 04 | Interested → HubSpot | 🪝 Webhook | Generates lead brief, saves as HubSpot note, drafts and sends meeting request reply |
| 05 | Meeting Booking | 🪝 Webhook | Creates Google Calendar event with auto-generated Meet link, updates HubSpot, notifies you |
| 06 | Payment Link | 🪝 Webhook (manual) | You approve → Razorpay creates payment link → emailed to client → HubSpot updated |
| 07 | Onboarding | 🪝 Razorpay webhook | Payment captured → HubSpot Closed Won → GPT onboarding email → kickoff call scheduled |

## AI Prompts

Five production-ready GPT prompts in `prompts/`, each with specific temperature, token limits, and output formats:

| Prompt | Model | Temp | Purpose |
|--------|-------|------|---------|
| `clay-enrichment` | GPT-4o | 0.3 | Score leads + identify pain points |
| `outreach-personalizer` | GPT-4o | 0.7 | Write 75-word cold emails |
| `reply-classifier` | GPT-4o | 0.2 | Classify replies into 7 categories |
| `lead-summarizer` | GPT-4o | 0.4 | Generate pre-call briefings |
| `service-matcher` | GPT-4o | 0.3 | Recommend best service offering |

## CRM Pipeline

9-stage deal pipeline in HubSpot:

```
Lead Captured → Contacted → Replied (Interested) → Meeting Scheduled
→ Meeting Completed → Proposal Sent → Payment Link Sent → Closed Won
                                                        ↘ Closed Lost
```

## Manual Actions

Two actions require your explicit trigger via webhook:

**Approve a deal for payment:**
```bash
curl -X POST https://YOUR_N8N_INSTANCE/webhook/approve-deal \
  -H "Content-Type: application/json" \
  -d '{"deal_id":"HUBSPOT_DEAL_ID","client_name":"Name","client_email":"email@example.com"}'
```

**Book a meeting:**
```bash
curl -X POST https://YOUR_N8N_INSTANCE/webhook/book-meeting \
  -H "Content-Type: application/json" \
  -d '{"prospect_name":"Name","prospect_email":"email@example.com","company":"Co","meeting_datetime":"2026-07-15T10:00:00+05:30"}'
```

## Email Deliverability

The system enforces anti-spam best practices:

- ✅ SPF, DKIM, DMARC configured
- ✅ No HTML formatting in cold emails
- ✅ Link tracking disabled (open tracking only via custom domain)
- ✅ Daily sending capped at 30, ramping from 10
- ✅ 2–5 minute gaps between sends
- ✅ Weekend sends disabled
- ✅ Stop on reply / bounce / auto-reply
- ✅ CAN-SPAM compliant (unsubscribe + physical address)

## Documentation

- [`docs/system-architecture.md`](docs/system-architecture.md) — Full system design, data model, security, rate limits, failure recovery
- [`docs/runbook.md`](docs/runbook.md) — Daily operations, manual action commands, troubleshooting, scaling guide

## Tech Stack

| Category | Technology |
|----------|-----------|
| Orchestration | n8n Cloud |
| AI | OpenAI GPT-4o / GPT-5.5 |
| Lead Gen | Apollo.io |
| Enrichment | Clay |
| Outreach | Instantly.ai |
| CRM | HubSpot Free |
| Email | Gmail (OAuth2) |
| Scheduling | Google Calendar + Meet |
| Payments | Razorpay |

## License

Proprietary — Darion Technologies. All rights reserved.
