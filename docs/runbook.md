# AI Sales Machine — Operations Runbook

## Quick Reference

### Webhook URLs (fill in after deploying n8n workflows)

| Workflow | Path | Full URL |
|----------|------|----------|
| 02 — Clay → Instantly | `/webhook/clay-enriched-lead` | `https://{{N8N_INSTANCE}}/webhook/clay-enriched-lead` |
| 04 — Interested Lead | `/webhook/interested-lead` | `https://{{N8N_INSTANCE}}/webhook/interested-lead` |
| 05 — Book Meeting | `/webhook/book-meeting` | `https://{{N8N_INSTANCE}}/webhook/book-meeting` |
| 06 — Approve Deal | `/webhook/approve-deal` | `https://{{N8N_INSTANCE}}/webhook/approve-deal` |
| 07 — Razorpay Payment | `/webhook/razorpay-payment-webhook` | `https://{{N8N_INSTANCE}}/webhook/razorpay-payment-webhook` |

---

## Daily Operations

### Morning (9:00 AM IST)
1. Check n8n execution log for overnight failures
2. Review new leads in HubSpot pipeline
3. Check Instantly warmup health score
4. Review any NEEDS_REVIEW classified replies

### Throughout Day
- Reply notifications arrive via email automatically
- Meeting booking notifications arrive automatically
- Monitor for any manual actions needed

### Evening (6:00 PM IST)
1. Review day's outreach stats in Instantly
2. Check HubSpot for deal stage movement
3. Follow up on any meetings that occurred today

---

## Manual Actions Required

### 1. Approve a Deal for Payment

When a client verbally agrees to pay, trigger the payment link:

```bash
curl -X POST https://{{N8N_INSTANCE}}/webhook/approve-deal \
  -H "Content-Type: application/json" \
  -d '{
    "deal_id": "HUBSPOT_DEAL_ID",
    "client_name": "Client Name",
    "client_email": "client@example.com",
    "client_phone": "+919999999999"
  }'
```

### 2. Book a Meeting Manually

When you agree on a time with a prospect:

```bash
curl -X POST https://{{N8N_INSTANCE}}/webhook/book-meeting \
  -H "Content-Type: application/json" \
  -d '{
    "prospect_name": "Prospect Name",
    "prospect_email": "prospect@example.com",
    "company": "Company Name",
    "title": "CEO",
    "pain_point": "Their pain point",
    "relevance_score": 8,
    "meeting_datetime": "2026-07-15T10:00:00+05:30"
  }'
```

### 3. Move Deal Stages Manually

For stages that aren't automated (Meeting Completed, Proposal Sent):
- Go to HubSpot → Deals → Click the deal → Change stage

---

## Troubleshooting

### Problem: Emails landing in spam
1. Check SPF/DKIM/DMARC at mxtoolbox.com
2. Check Instantly warmup health
3. Review email content for spam trigger words
4. Reduce daily sending volume
5. Check if tracking domain is properly configured

### Problem: No leads flowing from Apollo
1. Check n8n Workflow 01 execution log
2. Verify Apollo API key is valid
3. Check if ICP filters are too restrictive (try broadening)
4. Verify Apollo account has remaining credits

### Problem: Clay enrichment not working
1. Check Clay dashboard for errors
2. Verify Clay webhook URL is correct in Workflow 01
3. Check Clay credit balance
4. Test with a single manual row in Clay

### Problem: GPT responses are malformed
1. Check OpenAI API key and billing
2. Verify model availability (gpt-4o)
3. Check n8n execution log for the specific error
4. The system will fall back to NEEDS_REVIEW classification

### Problem: HubSpot contact creation fails
1. Check if contact already exists (duplicate email)
2. Verify Private App token hasn't expired
3. Check scopes — ensure all required permissions are enabled
4. Check if custom properties were created in HubSpot

### Problem: Razorpay payment link not generating
1. Check Razorpay API key validity
2. Ensure amount is in paise (multiply by 100)
3. Check if the Razorpay account is activated for live mode
4. Verify Basic Auth credentials in n8n

### Problem: Google Meet link not attached
1. Ensure `conferenceDataVersion=1` query param is in the URL
2. Verify `requestId` is unique for each event
3. Check Google OAuth scopes include Calendar.events
4. Try re-authenticating the Google credential in n8n

---

## Scaling Guide

### Week 1-2: Warmup Phase
- 10-20 emails/day via Instantly warmup
- Monitor deliverability metrics
- No live campaigns yet

### Week 3-4: Soft Launch
- 30 emails/day live campaign
- Monitor reply rates and classification accuracy
- Adjust GPT prompts based on reply quality

### Month 2: Ramp Up
- Increase to 50 emails/day
- Add secondary ICP (Startup Founders)
- Consider adding a second sending domain
- Add more email sequence variants (A/B test)

### Month 3+: Optimize
- Analyze which ICPs generate most meetings
- Refine GPT prompts based on what works
- Consider adding LinkedIn touchpoints
- Add inbound lead capture to the same pipeline

---

## Environment Variables (set in n8n)

| Variable | Description |
|----------|-------------|
| `OWNER_EMAIL` | Your email for notifications |
| `CLAY_WEBHOOK_URL` | Clay table webhook URL |
| `INSTANTLY_CAMPAIGN_ID` | Primary Instantly campaign ID |

---

## Key Metrics to Track

| Metric | Target | Where to Check |
|--------|--------|----------------|
| Email Open Rate | >50% | Instantly Dashboard |
| Reply Rate | >5% | Instantly Dashboard |
| Positive Reply Rate | >2% | HubSpot (Interested stage count) |
| Meeting Book Rate | >30% of interested | HubSpot pipeline |
| Close Rate | >20% of meetings | HubSpot pipeline |
| Average Deal Size | ≥₹1,000 | HubSpot deals |
| Email Bounce Rate | <2% | Instantly Dashboard |
| Spam Complaint Rate | <0.3% | Instantly Dashboard |
