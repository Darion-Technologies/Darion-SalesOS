# AI Sales Machine — System Architecture

## Overview

This document describes the complete architecture of the AI-powered sales automation system. The system uses 8 SaaS platforms orchestrated by n8n to create a fully automated pipeline from lead generation to payment collection.

---

## System Flow

```
Apollo.io ──→ Clay ──→ Instantly.ai ──→ Gmail
   │             │           │              │
   │        (Enrichment)     │         (Reply Detection)
   │             │           │              │
   │        GPT-4o/5.5       │         GPT Classifier
   │             │           │              │
   │             ▼           │              ▼
   │        Relevance        │         INTERESTED ──→ HubSpot ──→ Google Calendar ──→ Meeting
   │        Score ≥ 7        │         NOT_INTERESTED ──→ HubSpot (Closed Lost)
   │             │           │         OBJECTION ──→ GPT Draft Reply
   │             │           │              │
   └─────────────┘           │              │
         │                   │              │
    HubSpot CRM ◄────────────┘              │
         │                                  │
         ▼                                  │
    Deal Approved (Manual) ──→ Razorpay Payment Link
         │                                  │
         ▼                                  │
    Payment Received ──→ Onboarding Email + Kickoff Call
```

---

## Platform Responsibilities

| Platform | Role | Data Flow |
|----------|------|-----------|
| **Apollo.io** | Lead sourcing | Outbound → Clay |
| **Clay** | Lead enrichment + AI scoring | Apollo → GPT → Instantly |
| **OpenAI GPT** | Personalization, classification, briefs | Called by Clay + n8n |
| **Instantly.ai** | Email campaign delivery | Receives enriched leads, sends sequences |
| **Gmail** | Reply detection + sending | Monitored by n8n for incoming replies |
| **HubSpot** | CRM — contacts, deals, notes | Central record of all interactions |
| **Google Calendar** | Meeting scheduling | Creates events with Meet links |
| **Google Meet** | Video meetings | Auto-attached to Calendar events |
| **Razorpay** | Payment collection | Creates payment links, sends webhooks |
| **n8n** | Orchestration engine | Connects everything, runs logic |

---

## n8n Workflows Summary

| # | Workflow | Trigger | Key Actions |
|---|---------|---------|-------------|
| 01 | Apollo → Clay | Schedule (daily 8AM) | Search leads, dedup, push to Clay |
| 02 | Clay → Instantly | Webhook (from Clay) | GPT personalize, add to campaign, create HubSpot records |
| 03 | Reply Classification | Gmail poll (every 2 min) | GPT classify, route by category, notify |
| 04 | Interested → HubSpot | Webhook (from WF03) | Generate brief, add HubSpot note, draft meeting reply |
| 05 | Meeting Booking | Webhook (manual/auto) | Create Calendar event with Meet, update HubSpot |
| 06 | Razorpay Payment | Webhook (manual approval) | Create payment link, email to client, update deal |
| 07 | Payment → Onboarding | Webhook (Razorpay) | Mark Closed Won, onboarding email, schedule kickoff |

---

## Data Model

### Lead Lifecycle States

```
[New Lead] → [Enriched] → [Qualified (Score ≥ 7)] → [Contacted] → [Replied]
     │                                                                   │
     │                                                    ┌──────────────┤
     │                                                    ▼              ▼
     │                                             [Interested]    [Not Interested]
     │                                                    │              │
     │                                                    ▼              ▼
     │                                             [Meeting Set]   [Closed Lost]
     │                                                    │
     │                                                    ▼
     │                                             [Meeting Done]
     │                                                    │
     │                                                    ▼
     │                                             [Proposal Sent]
     │                                                    │
     │                                                    ▼
     │                                             [Payment Sent]
     │                                                    │
     │                                                    ▼
     └──────────────────────────────────────────→ [Closed Won] 🎉
```

### Key Data Fields

| Field | Source | Used By |
|-------|--------|---------|
| `email` | Apollo | All systems (primary key) |
| `relevance_score` | Clay + GPT | Qualification gate (≥ 7) |
| `personalized_note` | Clay + GPT | Email personalization |
| `pain_point` | Clay + GPT | Email copy + call prep |
| `classification` | GPT (n8n WF03) | Reply routing |
| `payment_link_url` | Razorpay | HubSpot deal record |
| `payment_status` | Razorpay webhook | Deal stage automation |

---

## Security Considerations

1. **API Keys**: Stored as n8n credentials (encrypted at rest in n8n Cloud)
2. **Webhook URLs**: Only shared between trusted platforms; consider adding secret query params
3. **Razorpay Webhooks**: Verify webhook signatures using the shared secret
4. **Gmail OAuth**: Uses OAuth2 (no passwords stored); scopes limited to mail + calendar
5. **HubSpot**: Private App with minimum required scopes only
6. **Data Retention**: HubSpot retains all contact/deal data; n8n execution logs auto-expire

---

## Rate Limits & Quotas

| Platform | Limit | Our Usage |
|----------|-------|-----------|
| Apollo | 200 API calls/min | ~25 calls/day (well under) |
| Clay | Depends on plan credits | ~50 enrichments/day |
| OpenAI | Varies by tier | ~100-200 calls/day |
| Instantly | Varies by plan | 30-50 emails/day |
| HubSpot Free | 100 API calls/10 sec | ~50 calls/day |
| Google Calendar | 1M queries/day | ~10 events/day |
| Razorpay | 20 requests/sec | ~5 links/day |

---

## Failure Modes & Recovery

| Failure | Impact | Recovery |
|---------|--------|----------|
| Apollo API down | No new leads sourced | Workflow retries next day; manual CSV import as backup |
| Clay webhook fails | Leads not enriched | n8n error handler retries; check Clay dashboard |
| GPT API timeout | No personalization | Fallback to template emails (see `email-sequences.md`) |
| Instantly API error | Lead not added to campaign | Error logged; manual CSV upload to Instantly |
| Gmail quota exceeded | Replies not detected | Increase poll interval; check Google API console |
| HubSpot API error | CRM not updated | n8n retry with exponential backoff |
| Razorpay API down | Payment link not created | Manual link from Razorpay dashboard |
| n8n execution fails | Workflow stops | Check n8n execution log; error trigger sends notification |

---

## Monitoring Dashboard

Check these daily during the first 2 weeks:

1. **n8n Executions**: Cloud dashboard → check for failed executions
2. **Instantly Dashboard**: Open rate, reply rate, bounce rate, warmup health
3. **HubSpot Pipeline**: Deal distribution across stages
4. **Gmail Deliverability**: Check sent folder for bounces
5. **Razorpay Dashboard**: Payment link status
