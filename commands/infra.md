---
name: infra
description: Add and validate production infrastructure one bundle at a time
---

# /infra Command

Add and validate production infrastructure one bundle at a time. Follows the universal 9-step flow shared with /audit and /pipeline.

## Master List (4 Bundles)

Industry standard order (availability to automation):

| Priority | Bundle | Contents |
|----------|--------|----------|
| 1 | **Health** | /health endpoint + platform probes |
| 2 | **Security** | WAF rules + rate limiting |
| 3 | **Backup** | DB backup + storage + retention policy |
| 4 | **Deploy** | CD webhook/trigger from main branch |

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--dry-run` | false | Preview what would happen without changes |
| `--skip-install` | false | Don't create configs or scripts |
| `--verbose` | false | Show full command output |

## Flow

### Step 1: DETECT

1. Check for `.spec_system/CONVENTIONS.md`
   - If missing: "No CONVENTIONS.md found. Run /initspec first."
   - Read Infrastructure table for configured components
   - Identify: CDN, hosting platform, database, cache, backup, deploy

2. Detect infrastructure from existing files/configs:
   - `wrangler.toml` = Cloudflare
   - `docker-compose.yml`, `coolify.json` = Coolify/Docker
   - `vercel.json` = Vercel
   - `fly.toml` = Fly.io
   - Terraform/Pulumi files = IaC detected

3. Check for `.spec_system/audit/known-issues.md`
   - Load Skipped Infra section
   - Note: "Known issues loaded (N infra items skipped)"

4. If `--dry-run`: Skip to Dry Run Output

### Step 2: COMPARE

Compare Infrastructure table against 4-bundle master list:
- Health: Is there a /health endpoint? Platform probe configured?
- Security: WAF rules present? Rate limiting configured?
- Backup: Backup script/job exists? Storage configured?
- Deploy: CD trigger configured?

Build list of missing bundles in priority order.

If all bundles configured: "All infrastructure configured. Jumping to Step 5 to Validate."

### Step 3: SELECT

Pick the highest-priority missing bundle from Step 2.

Output: "Selected: [Bundle Name] - not yet configured"

### Step 4: IMPLEMENT

Add configuration for the selected bundle.

**Stack-agnostic implementations:**

| Bundle | Component | Implementation varies by platform |
|--------|-----------|-----------------------------------|
| Health | Endpoint | FastAPI, Express, Go handler, etc. |
| Health | Probe | Coolify, Kubernetes, ECS, Vercel, etc. |
| Security | WAF | Cloudflare, AWS WAF, Vercel Firewall |
| Security | Rate Limit | slowapi, express-rate-limit, in-platform |
| Backup | Script | pg_dump, mongodump, mysqldump |
| Backup | Storage | R2, S3, GCS, local |
| Backup | Schedule | Cron, GitHub Actions, platform scheduler |
| Deploy | Trigger | Webhook, Git push, platform integration |

**Implementation by detected stack:**

**Health Bundle:**
```python
# FastAPI example
@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "database": await check_db(),
        "cache": await check_cache(),
        "timestamp": datetime.utcnow().isoformat()
    }
```

1. Create /health endpoint in detected framework
2. Add DB and cache connectivity checks
3. Configure platform health probe (if platform detected)

**Security Bundle:**
1. If Cloudflare: Document WAF ruleset to enable (OWASP Core)
2. Add rate limiting middleware to application
3. Document rate limit configuration

**Backup Bundle:**
1. Create backup script for detected database
2. Configure storage destination
3. Create schedule (cron or GitHub Action)
4. Document retention policy

**Deploy Bundle:**
1. Configure webhook URL (Coolify, Render, etc.)
2. Or configure Git-based deploy (Vercel, Netlify)
3. Add deploy step to release workflow

### Step 5: VALIDATE

Verify all configured infrastructure:

1. **Health**: `curl` the /health endpoint, verify 200 + JSON
2. **Security**: Verify rate limiting works (test with rapid requests)
3. **Backup**: Verify backup runs, check storage for recent backup
4. **Deploy**: Trigger test deploy or verify webhook connectivity

**Validation commands by component:**

| Component | Validation |
|-----------|------------|
| Health endpoint | `curl -f https://domain.com/health` |
| Rate limiting | Rapid requests should get 429 |
| Backup | Check storage for file < 24h old |
| Deploy webhook | `curl -X POST webhook_url` (dry-run if possible) |

### Step 6: FIX

For each validation failure:

1. **Health endpoint missing**: Create it (Step 4)
2. **Health returns error**: Fix DB/cache connectivity
3. **Rate limiting not working**: Check middleware order, config
4. **Backup missing/stale**: Run backup manually, fix schedule
5. **Deploy webhook fails**: Verify URL, check platform logs

**After 3 failed attempts**: Log for manual review.

Filter out items in known-issues.md Skipped Infra section.

### Step 7: RECORD

Update `.spec_system/CONVENTIONS.md` Infrastructure table:

```markdown
| Component | Provider | Details |
|-----------|----------|---------|
| CDN/DNS | Cloudflare | - |
| WAF | Cloudflare | OWASP ruleset enabled |
| Hosting | Coolify | 8GB VPS |
| Database | PostgreSQL 16 | Coolify-managed |
| Backup | R2 | pg_dump, daily, 7-day retention |
| Deploy | Coolify webhook | On push to main |
```

### Step 8: REPORT

```
REPORT
- Added: Health bundle
- Created: src/api/health.py
- Configured: Coolify health probe (HTTP, /health, 30s interval)
- Validated: Endpoint returns 200, DB check passes, cache check passes
- Response time: 45ms

Platform notes:
- Coolify probe configured via UI (manual step documented)
```

**If secrets/manual steps required:**
```
Required setup:
1. In Coolify dashboard, set health check path to /health
2. Set health check interval to 30 seconds
3. Enable "Restart on unhealthy" option
```

### Step 9: RECOMMEND

**If validation failures remain:**
```
ACTION REQUIRED:
1. Database connectivity failing - check DATABASE_URL env var
2. Cache check timing out - verify Valkey is running

Rerun /infra after addressing these issues.
```

**If all clean but bundles remain:**
```
Note: more bundles remain, they will be added in future runs!

Recommendation: Run /documents
```

**If all 4 bundles configured and validated:**
```
All infrastructure configured and validated.

Recommendation: Run /documents
```

## Dry Run Output

```
INFRA PREVIEW (DRY RUN)

Stack detected:
- CDN: Cloudflare
- Platform: Coolify
- Database: PostgreSQL 16
- Cache: Valkey

Configured: Health, Security
Missing: Backup, Deploy

Would add: Backup
Would create: scripts/backup.sh
Would configure: Cron schedule (daily 02:00 UTC)
Would store: Cloudflare R2 (bucket: backups)

Required setup:
- R2_ACCESS_KEY_ID in environment
- R2_SECRET_ACCESS_KEY in environment

Run without --dry-run to apply.
```

## Platform-Specific Notes

**Cloudflare:**
- WAF rules configured via dashboard or Terraform
- Document which rulesets to enable
- R2 for backup storage

**Coolify:**
- Health probes configured via UI
- Webhook URL available in deployment settings
- Supports Docker and static deploys

**Vercel:**
- Health checks automatic for serverless
- Rate limiting via Edge Config or middleware
- Git-based deploys, no webhook needed

**AWS/ECS:**
- Health checks via target group
- WAF via AWS WAF
- Backups via RDS snapshots or custom scripts

## Rules

1. **One bundle per run** - Add one, validate all
2. **Stack agnostic** - Read platform from CONVENTIONS.md, adapt
3. **Document manual steps** - Some platforms require UI configuration
4. **Don't store secrets** - Document required env vars, don't create them
5. **Validate everything** - Verify infra actually works, not just exists
6. **Respect known-issues.md** - Skip items marked as manual-only
