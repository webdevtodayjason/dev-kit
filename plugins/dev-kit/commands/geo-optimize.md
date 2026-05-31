---
description: Optimize a website for GEO (Generative Engine Optimization) — making content discoverable by AI search engines (ChatGPT, Perplexity, Claude, Gemini). Use when building or auditing any website that needs to be found by AI crawlers.
---

# GEO (Generative Engine Optimization) Skill

## What is GEO?

GEO optimizes websites for AI search engines — ChatGPT, Perplexity, Claude, Google AI Overview, Gemini. Unlike traditional SEO which targets Google's link-based algorithm, GEO targets how AI models select, cite, and surface content.

## When to Use

- Building a new marketing site or product page
- Auditing an existing site for AI visibility
- User mentions "GEO", "AI SEO", "AI search optimization", "AI crawler", or "generative engine"
- After building significant new content that needs to be AI-discoverable

## The GEO Checklist

### 1. BLUF (Bottom Line Up Front)
Every page should start with a **30-50 word direct answer summary** before any other content. AI models often "snatch" these opening paragraphs as response snippets.

```html
<p class="bluf">[Product Name] is a [category] that [primary benefit in plain
words], built for [target user]. [One sentence on what sets it apart].</p>
```

### 2. Static HTML for Crawlers
AI crawlers (GPTBot, ClaudeBot, PerplexityBot) may NOT execute JavaScript. SPAs must either:
- **Pre-render at build time** (preferred) — Use Puppeteer/Playwright to generate static HTML for every route
- **Server-Side Render (SSR)** — Render on the server for each request
- **Noscript fallback** — Comprehensive `<noscript>` content as a minimum

```html
<noscript>
  <h1>Product Name — One-line description</h1>
  <p>Complete product description with key features...</p>
  <ul>
    <li>Feature 1 — description</li>
    <li>Feature 2 — description</li>
  </ul>
</noscript>
```

### 3. robots.txt — Explicitly Allow AI Crawlers
```
User-agent: *
Allow: /

User-agent: GPTBot
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: GoogleOther
Allow: /

User-agent: ChatGPT-User
Allow: /

User-agent: anthropic-ai
Allow: /

User-agent: cohere-ai
Allow: /

# Block private routes
Disallow: /admin/
Disallow: /api/

Sitemap: https://yourdomain.com/sitemap.xml
```

### 4. llms.txt — Machine-Readable Site Map for AI
Create `/llms.txt` at your domain root with:
- Product name and one-line description
- Key capabilities (bullet list)
- All important page URLs
- Contact information
- Make it dynamic if you have a blog (include recent articles)

```markdown
# Product Name

> One-line description

## Key Capabilities
- Feature 1
- Feature 2

## Links
- Website: https://...
- GitHub: https://...
- Docs: https://...

## Contact
- Email: support@...
```

Also create `/llms-full.txt` with 2000-3000 words of comprehensive content.

### 5. Content-Signal Headers
Add HTTP headers telling AI crawlers they can use your content:

```javascript
// Express middleware
app.use((req, res, next) => {
  if (req.path.endsWith('.html') || !req.path.includes('.')) {
    res.setHeader('Content-Signal', 'ai-train=yes, search=yes, ai-input=yes')
  }
  next()
})
```

### 6. AI Meta Tags
```html
<meta name="fragment" content="!">
<meta name="ai.content_type" content="software_product">
<meta name="ai.entity" content="Your Product Name">
<meta name="ai.category" content="Category1, Category2">
```

### 7. Structured Data (JSON-LD) — Go Deep
Every page needs appropriate Schema.org markup:

| Page Type | Schema |
|-----------|--------|
| Product/Feature | `SoftwareApplication` |
| FAQ | `FAQPage` (Google shows expandable answers) |
| How-To/Tutorial | `HowTo` |
| Comparison | `WebPage` with `about[]` |
| Blog Article | `Article` with author + publisher |
| Course/Education | `Course` + `CourseInstance` |
| Service/Industry | `Service` with `areaServed` |
| About/Team | `Organization` + `Person` |
| All Pages | `BreadcrumbList` |

### 8. Self-Contained Passages
Each H2/H3 section should be **self-contained** — a question followed by a complete answer. AI "chunks" content by headings, so each section must make sense independently.

```html
<h2>What is persistent memory in AI?</h2>
<p>Persistent memory allows an AI system to remember context across
every interaction indefinitely. Unlike session-based AI that resets
after each conversation, persistent memory maintains facts, decisions,
preferences, and relationships over weeks, months, and years.</p>
```

### 9. Citable Claims with Numbers
Structure content around **verifiable, specific claims**:
- ❌ "Our system is very fast"
- ✅ "The system processes requests in under 10ms with <5MB RAM footprint"
- ❌ "We support many providers"
- ✅ "Smart model routing across 15+ LLM providers with 205 model profiles"

### 10. Entity Clarity
Explicitly define your entities and their relationships:
```json
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "ProductName",
  "applicationCategory": "DeveloperApplication",
  "operatingSystem": "macOS, Linux",
  "author": {"@type": "Person", "name": "..."},
  "publisher": {"@type": "Organization", "name": "..."}
}
```

### 11. HTML Tables for Comparisons
AI extracts structured HTML tables far more reliably than images of tables or CSS-styled layouts. Use real `<table>` elements for feature comparisons, specifications, and pricing.

### 12. Timestamps and Versioning
Every content page should display "Last updated: YYYY-MM-DD" to signal freshness. AI models prefer current information.

### 13. agent-card.json
Create `/agent-card.json` for AI agent discovery:
```json
{
  "@context": "https://schema.org",
  "@type": "SoftwareAgent",
  "name": "Your Agent",
  "description": "...",
  "capabilities": ["..."],
  "agentWebStandards": {
    "llmsTxt": "https://yourdomain.com/llms.txt",
    "agentCard": "https://yourdomain.com/agent-card.json"
  }
}
```

### 14. Cloudflare Markdown for Agents
If using Cloudflare, enable "Markdown for Agents" in AI Crawl Control. This automatically converts HTML to markdown for AI crawlers requesting `Accept: text/markdown`.

### 15. Dynamic Sitemap
Serve sitemap.xml dynamically so it always includes the latest content (blog articles, new pages). AI crawlers use sitemaps to discover content.

## Audit Command

When asked to audit a site for GEO, check all 15 points above and report:
- ✅ Implemented
- ⚠️ Partial
- ❌ Missing

Prioritize fixes by impact:
1. Static HTML / SSR (without this, nothing else matters)
2. llms.txt + robots.txt (AI crawlers need permission and a map)
3. Structured data (JSON-LD schemas)
4. Content-Signal headers
5. BLUF summaries + self-contained passages
6. Everything else
