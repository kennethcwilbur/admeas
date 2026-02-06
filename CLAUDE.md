# AdMeas Project — Advertising Measurement Slides

## Project Overview

This project contains the "Advertising Measurement" lecture slides for UCSD MGTA 451 (Marketing). The goal is to migrate from the default Quarto revealjs theme to the [Grant McDermott clean-revealjs template](https://github.com/grantmcdermott/quarto-revealjs-clean), then review and refine all slides for visual quality and mobile/laptop readability.

## Key Files

| File | Description |
|------|-------------|
| `admeas.qmd` | Main slide deck (active development) |
| `admeas.html` | Rendered HTML slides |
| `custom.css` | CSS overrides (flexbox layout, source-url positioning) |
| `images/` | Active images used in the presentation |
| `archive/` | Test files and unused images |
| `_extensions/grantmcdermott/clean/` | Installed clean-revealjs extension |

## Project Phases

### Phase 1: Setup and Testing (COMPLETED)
- [x] Archived 256 unused images to `images/archive/`
- [x] Installed clean-revealjs Quarto extension
- [x] Created test deck with 11 representative slides (graphics, math, text, scrollable)
- [x] Verified rendering via headless browser screenshots
- [x] Confirmed MathJax renders correctly
- [x] Created `custom.css` with adjusted `.smaller` class (0.85em)
- [x] Configured chalkboard: buttons hidden, "Press C" note on Agenda slide
- [x] Established reveal.js native PDF export workflow
- [x] Installed tools: Chromium, librsvg2-bin, poppler-utils

### Phase 2: Template Migration (PENDING)
- [ ] Convert main .qmd YAML header to clean-revealjs format
- [ ] Adjust image sizing for responsive display (laptop + smartphone)
- [ ] Review/adjust use of `.smaller`, `.scrollable` classes
- [ ] Test full deck rendering

### Phase 3: Slide-by-Slide Review (PENDING)
- [ ] Review each slide for visual quality and consistency
- [ ] Apply assertion/evidence/takeaway structure to graphic-heavy slides
- [ ] Improve visual hierarchy where needed
- [ ] Address any overflow or readability issues

### Phase 4: Additions and Refinements (PENDING)
- [ ] Add new content elements as identified during review
- [ ] Final polish and consistency check

## Technical Notes

### Slide Numbering Convention

When the user refers to a slide number, they mean the number displayed in the bottom-right corner of the rendered slide. Numbering starts at 1 on the title slide. To find a slide by number, use the slide's HTML ID (e.g., `#/slide-title-here`) rather than numeric URL indexing.

### Rendering Commands

**Render to HTML:**
```bash
cd "/mnt/chromeos/GoogleDrive/MyDrive/aaaCURRENT/mgta451mktg/AdMeas"
quarto render [filename].qmd
```

**Render to PDF (LaTeX, document format):**
```bash
quarto render [filename].qmd --to pdf -M geometry:landscape
```
Note: LaTeX PDF has limitations—SVGs may not render, text truncates, slides flow as document pages.

**Render to PDF (reveal.js native, slide-per-page):** ← PREFERRED
```bash
chromium --headless --disable-gpu \
  --print-to-pdf="[filename]-slides.pdf" \
  --print-to-pdf-no-header \
  --virtual-time-budget=30000 \
  "file:///[full-path]/[filename].html?print-pdf"
```
This produces true slide-per-page PDF with correct landscape formatting.

### Headless Browser for HTML Verification

Chromium is installed and can capture screenshots of rendered HTML slides. Use `--virtual-time-budget=5000` to allow MathJax to render.

**Capture single slide:**
```bash
chromium --headless --disable-gpu \
  --screenshot="slide_N.png" \
  --window-size=1280,720 \
  --virtual-time-budget=5000 \
  "file:///mnt/chromeos/GoogleDrive/MyDrive/aaaCURRENT/mgta451mktg/AdMeas/[filename].html#/N"
```

**Slide numbering:** Slides are 0-indexed in the URL hash (#/0, #/1, #/2, ...).

**Responsive testing:** Adjust `--window-size` for different screen sizes:
- Desktop: `1920,1080`
- Laptop: `1280,720`
- Tablet: `768,1024`
- Mobile: `375,667`

### Clean Template CSS Classes

The clean-revealjs template provides these custom classes:
- `.alert` — Default emphasis styling for key points
- `.fg` — Custom foreground color: `style="--col: #hexcode"`
- `.bg` — Custom background color: `style="--col: #hexcode"`
- `.button` — Beamer-like button for cross-references

### Image Sizing Guidelines

- Use fixed pixel heights (`height="400px"`) for consistent results across slides
- Percentage-based heights do not work reliably in reveal.js due to CSS inheritance chain issues
- **Do not change aspect ratios of graphics.** Specify only height (not width) to preserve original proportions. When placing two images side-by-side, check their native dimensions and adjust column widths to accommodate different aspect ratios
- **Crop white space from images** when applying the new template to old slides (remove labels, source citations, excess margins from image files themselves)

## Custom Graphics Style Guide

Custom SVG graphics for this project should follow the style established in `AMimages/grading-own-homework.svg`:

### Color Palette
| Element | Color | Hex |
|---------|-------|-----|
| Background | White | `#ffffff` |
| Paper gradient (top) | Cream | `#fffef8` |
| Paper gradient (bottom) | Light tan | `#f5f0e0` |
| Paper margin line | Light red | `#e8a0a0` |
| Arrows | Medium gray | `#888888` |
| Body text | Dark gray | `#333333` / `#444444` |
| Emphasis/grades | Red | `#cc0000` |

**Role/label colors** (muted, professional tones):
- Ad Platform: `#5c3d3d` (muted brown)
- Ad Agency: `#4a3c50` (muted purple)
- CMO: `#3d3a5c` (muted indigo)
- CFO: `#2d4a3e` (muted teal)

### Typography
| Context | Font | Size | Weight |
|---------|------|------|--------|
| Labels/headers | Georgia, serif | 18px | bold |
| Speech bubbles | Georgia, serif | 12px | normal |
| Handwritten/paper text | Comic Sans MS, cursive | 10-13px | normal |
| Grade marks | Comic Sans MS, cursive | 26-32px | bold |

### Visual Elements
- **Boxes/labels:** Rounded corners (`rx="6"`), 1.5px stroke
- **Speech bubbles:** Rounded rect with triangular pointer
- **Papers:** Slight rotation (-2° to +2°), drop shadow filter
- **Notebook paper effect:** Horizontal line pattern, red margin line, hole punches (white circles)
- **Arrows:** 2px stroke with arrowhead marker

### Layout Principles
- White background for clarity and projection readability
- Horizontal left-to-right flow for process/hierarchy diagrams
- Muted professional colors for structure, playful handwritten elements for content
- Visual hierarchy through size, position, and subtle rotation
- Consistent spacing between elements

### Generator Script
The shell script `AMimages/generate-grading-homework.sh` serves as a reference implementation. New custom graphics should follow this pattern:
- SVG with explicit viewBox and dimensions
- Reusable gradients, filters, and patterns in `<defs>`
- Logical grouping with `<g>` and transform for positioning
- Comments marking major sections

## Workflow Requirements

- **Always re-render after edits:** After any change to `admeas.qmd`, re-render both HTML (`quarto render`) and PDF (Chromium headless), then visually verify the affected slides using `pdftoppm` screenshots
- **Verify before reporting completion:** Do not report a task as done until visual verification confirms the change rendered correctly

## Style Preferences

- Minimize JavaScript beyond reveal.js native requirements; prefer HTML/CSS solutions
- Consistent formatting across all slides
- Better visual hierarchy
- Assertion/evidence/takeaway structure for graphic-heavy slides
- Readable on laptop screens and smartphones
- Source citations in `::: {.source-url}` blocks (left-justified footer)
- Speaker notes in `::: notes` blocks
- **All links must open in new tabs:** Use `{target="_blank"}` for markdown links, or `target="_blank"` attribute for HTML links (e.g., author name in YAML header)

## Slide Layout Patterns

### Standard Slide Structure (Image + Callout)
For slides with a graphic and explanatory text, use this pattern:
```markdown
## Slide Title

![](images/image-file.png){fig-align="center" width="9in"}

::: {.callout-note appearance="minimal"}
Explanatory text describing the graphic. End with "What else do you see?" for discussion slides.
:::

::: {.source-url}
[https://example.com/source-url](https://example.com/source-url){target="_blank"}
:::

::: notes
Speaker notes here.
:::
```

### Vertical Spacing Guidelines
When creating or editing slides, ensure proper vertical spacing:

1. **Image sizing:** Use `height="400px"` as the default for charts/graphics
   - Fixed pixel heights provide consistent results across different image aspect ratios
   - Adjust to 350px or 380px if content is dense or slide has more text
2. **Flexbox layout:** Slides use `flex-direction: column` with `justify-content: flex-start`
   - Elements flow from top to bottom
   - Source URL uses `margin-top: auto` to push to bottom of slide
3. **Callout margin:** The CSS applies `margin: 0.5em 0 0.5em 0` for compact spacing
4. **Source URL position:** Relative positioning within flexbox flow (not absolute), pushed to bottom via `margin-top: auto`
5. **Spacing requirement:** Always ensure visible space between callout text box and source URL link
6. **If content overflows or overlaps:**
   - Reduce image height (e.g., from 400px to 350px)
   - Use `.medium` class on slide header if text is too large
   - Verify via headless browser screenshot before finalizing
7. **Always re-render HTML after adjusting vertical spacing**

### Source URL Style
All source links use the `.source-url` class for consistent footer positioning:
- **Position:** Relative within flexbox, pushed to bottom via `margin-top: auto`
- **Font:** 0.5em, #444444 (dark gray), left-aligned at 5% padding
- **Format:** Clickable markdown link with `{target="_blank"}` to open in new window
- **Syntax:** `[URL](URL){target="_blank"}`

## Change Log

### 2025-01-13
- **Task:** Initial project setup and scoping
- **Actions performed:**
  1. Identified 256 unused images in `images/` folder
  2. Created `images/archive/` subfolder
  3. Moved 256 unused images to archive (verified: 57 remain in `images/`)
  4. Installed `grantmcdermott/quarto-revealjs-clean` extension v1.4.1
  5. Created `test-clean-template.qmd` with 11 representative slides
  6. Rendered test deck to HTML and verified via headless browser
  7. Installed `librsvg2-bin` for SVG-to-PDF conversion
  8. Installed Chromium for headless screenshot capture
- **Verification:** Captured screenshots of slides 0, 1, 2, 5, 6 confirming:
  - Title slide renders cleanly
  - Images display correctly
  - MathJax equations render (with 5s virtual time budget)
  - Template styling (teal accents, progress bar) working
  9. Created `custom.css` with less aggressive `.smaller` class (0.85em vs 0.7em)
  10. Added chalkboard `buttons: false` to hide toolbar; added aside "Press C to annotate slides" to Agenda
  11. Installed `poppler-utils` for PDF inspection
  12. Established reveal.js native PDF export workflow (30s virtual-time-budget required)
  13. Successfully exported test deck to 12-page PDF (test-clean-template-slides.pdf)
  14. Cleaned up temporary files (12 screenshot PNGs, 1 LaTeX PDF)
- **Next steps (planned for next session):**
  - Finalize test template configuration
  - Begin Phase 2: migrate main deck to clean-revealjs

### 2026-01-14 (Morning Session)
- **Task:** Continue template migration and slide refinement
- **Actions performed:**
  1. Updated CSS flexbox layout: changed `justify-content` from `space-between` to `flex-start`
  2. Changed source-url positioning from absolute to relative with `margin-top: auto` for consistent bottom placement
  3. Increased image heights from 300px to 400px across all slides
  4. Cropped white space from St. Louis Fed images (slides 5-6):
     - `stlfed-big4adrevbyyear-cropped.png`: 1012px → 870px height
     - `stlfed-big4profitpct-cropped.png`: 1012px → 770px height
  5. Updated slide 7 (programmatic advertising):
     - Added title: "Online Ads are Transacted by AI"
     - Replaced plain text with callout box
     - Added text: "Programmatic is defined by automation and optimization."
     - Added source URL: https://www.iab.com/insights/glossary-of-terminology/
  6. Updated CLAUDE.md with cropping guideline and revised CSS documentation
- **Verification:** Screenshots confirmed proper rendering of all modified slides
- **Files modified:**
  - `custom.css`: Flexbox layout changes
  - `admeas.qmd`: Slide content updates
  - `images/stlfed-big4adrevbyyear-cropped.png`: Cropped
  - `images/stlfed-big4profitpct-cropped.png`: Cropped

### 2026-01-14 (Afternoon Session)
- **Task:** Complete slides 1-18 with content, images, and formatting
- **Actions performed:**
  1. **Title slide (slide 1):** Added license disclosure and javascript tracking note
  2. **Section header (slide 2):** Changed "Advertising Domain Knowledge" to "Domain Knowledge"; added book reference bullet: "For an industry history, read *Yield* by Ari Paparo (2025)"
  3. **Added Google Analytics tracking:** Created `gtag.html` with GA4 tag (G-MVJF5Z0C5J), included via YAML header
  4. **Slide content updates (slides 3-18):**
     - Standardized all slides with callout boxes, source URLs, and 400px image heights
     - Added new slide "Right ad, right person, right context, right time?" with ad dimensionality table
     - Reordered slides: moved Effective Frequency, Advertising avoidance, Consumer Attention after Ad Tech Ecosystem
  5. **Image replacements and cropping:**
     - Slide 9: Replaced with `supplychainleakage.png`, cropped white space
     - Slide 10: Replaced with `Display-LUMAscape.png`
     - Slide 13: Replaced with `Nielsen-Ad-Avoidance-by-Medium-Dec2023.png`
     - Slide 14: Extracted `ebiquity_lumen_2024_figure4.png` from PDF at 300 DPI, cropped figure title
     - Slide 17: Cropped `adsalesratios2024.png` to remove attribution text while keeping table and black bar
  6. **Slide 12 (Effective Frequency):** Converted to side-by-side layout (60%/40% columns) with text box containing effective frequency theory explanation
  7. **Slide 16 (Brand Safety and Suitability):** Restructured bullets - all sub-bullets under Brand safety, Brand suitability as standalone at bottom
  8. **Slide 17:** Added title "How much should you spend on Advertising?", converted code block to callout box
  9. **Text edits across multiple slides:** Various wording refinements per user requests
- **Verification:** Generated PDF and verified all slides render correctly with proper bullet hierarchy and formatting
- **Files modified:**
  - `admeas.qmd`: Extensive slide content updates
  - `gtag.html`: New file for Google Analytics
  - `custom.css`: Minor refinements
  - `images/supplychainleakage.png`: Cropped
  - `images/ad_dimensionality.png`: Cropped
  - `images/ebiquity_lumen_2024_figure4.png`: Extracted from PDF and cropped
  - `images/adsalesratios2024.png`: Cropped to remove attribution text
- **Next session:** Import remaining slides from the full slide deck into admeas.qmd

### 2026-01-20
- **Task:** Import next 20 slides from archived deck into admeas.qmd
- **Actions performed:**
  1. Identified slides to import from archive/2025mgta451-2-Advertising-Measurement.qmd
  2. Imported and converted 20 slides to new template format (callout boxes, source-url class, 400px image heights):
     - Slide 18: Toy economics of advertising
     - Slide 19: What is Incrementality?
     - Slide 20: Honey: A Case Study in Attribution Fraud
     - Slide 21: Causality (section header)
     - Slide 22: Correlation is not Causation (margarine chart)
     - Slide 23: How Many False Positives?
     - Slide 24: Classic misleading correlations
     - Slide 25: "Revenue too high alert" (Bing)
     - Slide 26: Correlation vs Causation (CvC truck)
     - Slide 27: Four Types of Analytics
     - Slide 28: eBay Search Ad Experiments
     - Slide 29: eBay Results: Click Substitution
     - Slide 30: eBay Results: Attribution vs Reality
     - Slide 31: Fundamental Problem of Causal Inference (section header)
     - Slide 32: Causal Inference Framework
     - Slide 33: Why Care About Causal Effects?
     - Slide 34: The Fundamental Problem
     - Slide 35: So What Can We Do?
     - Slide 36: How Much Does Causality Matter?
     - Slide 37: Advertising Measurement (section header)
  3. Rendered HTML and generated 38-page PDF (admeas-slides.pdf, 14.3 MB)
- **Verification:** PDF page count confirmed at 38 pages (37 slides + title)
- **Files modified:**
  - `admeas.qmd`: Added 20 slides (now 38 total including title)
  - `admeas.html`: Re-rendered
  - `admeas-slides.pdf`: Regenerated (14.3 MB, 38 pages)
- **Note:** Required 60s virtual-time-budget for PDF generation with 38 slides
- **Next session:** Continue importing remaining slides from archive (Correlational Advertising Measurement, Causal Advertising Measurement, Industry Practices, MMM, Career sections)

### 2026-01-20 (Continued)
- **Task:** Import next 20 slides and various text edits
- **Actions performed:**
  1. **Text edits to existing slides:**
     - Slide 11: Updated ad conversion rates text (interruptive vs consumer-pulled)
     - Slide 12: Added retargeting definition
     - Slide 16: Added advertiser boycotts bullet, fixed grammar, updated Brand suitability text
     - Slide 17: Changed title to "How much do firms spend"
     - Slide 18: Updated search ad conversion rate text
     - Slide 19: Added "The word incrementality is only used in marketing"
  2. **Imported 20 slides (now 58 total):**
     - Slide 38: Measurement of What?
     - Slide 39: Why is Advertising Measurement Hard?
     - Slide 40: What Do We Measure? (ROAS formulas)
     - Slide 41: Diminishing Returns
     - Slide 42: Albertsons: ROAS Varies with Measurement Choices
     - Slide 43: Correlational Advertising Measurement (section header)
     - Slide 44: 1. Lift Statistics
     - Slide 45: 2. Regression
     - Slide 46: 3. Multi-Touch Attribution (MTA)
     - Slide 47: Strongest Arguments for Corr(ad,sales)
     - Slide 48: Problem 1 with Corr(ad,sales)
     - Slide 49: Problem 2 with Corr(ad,sales)
     - Slide 50: Problem 3 with Corr(ad,sales)
     - Slide 51: U.S. v Google (2024, Search Case)
     - Slide 52: Does Corr(ad,sales) Work?
     - Slide 53: Gordon, Moakler & Zettelmeyer (2023): Data
     - Slide 54: Gordon, Moakler & Zettelmeyer (2023): Figures
     - Slide 55: Gordon, Moakler & Zettelmeyer (2023): Results
     - Slide 56: Why Are Some Teams OK with Corr(ad,sales)?
     - Slide 57: Why Are Some Teams OK with Corr(ad,sales)? (2)
- **Verification:** PDF generated with 60 pages (some slides span multiple pages), 21.7 MB
- **Note:** Required 120s virtual-time-budget for PDF generation with 58 slides
- **Files modified:**
  - `admeas.qmd`: Text edits + 20 new slides
  - `admeas.html`: Re-rendered
  - `admeas-slides.pdf`: Regenerated (21.7 MB, 60 pages)
- **Next session:** Continue importing remaining slides (Why OK pt 3, Ad measurement trends, Causal measurement, Industry practices, MMM, Career sections)

### 2026-01-20 (Final Import)
- **Task:** Import all remaining slides from archived deck
- **Actions performed:**
  1. Imported 35 additional slides to complete the deck (now 93 slides total):
     - Why Are Some Teams OK? (3) - reasons 6-7
     - 2024 Ad Measurement Trends
     - Google Trends: Ad Experiments
     - **Causal Advertising Measurement** (section header + 10 slides)
       - Ad Experiments: Common Designs
       - Experimental Necessary Conditions
       - Before You Kick Off Your Test
       - Platform Experiments Advisory
       - Productive Experiments
       - Quasi-experiments Vocabulary
       - Ad/Sales: Quasi-experiments (2 slides)
       - DFS TV Ad Effects on Google Search
       - Experiments vs. Quasi-experiments
     - **Industry Practices** (section header + 11 slides)
       - Who Tests the Most?
       - CEO Quotes on Experimentation
       - Advertising Experiment Frequency
       - Advertising Experiment Effectiveness
       - Kantar 2025 (6 slides)
     - **Marketing Mix Models** (section header + 4 slides)
       - MMM definition
       - MMM Components
       - MMM Considerations
       - Open-Source MMM Frameworks
     - **Career Considerations** (section header + 4 slides)
       - LinkedIn Discussion
       - Ken's Take
       - Takeaways
       - Going Deeper
- **Verification:** PDF generated with 95 pages (34.7 MB), all slides render correctly
- **Note:** Required 180s virtual-time-budget for PDF generation with 93 slides
- **Files modified:**
  - `admeas.qmd`: Complete deck (93 slides)
  - `admeas.html`: Re-rendered
  - `admeas-slides.pdf`: Final PDF (34.7 MB, 95 pages)
- **Status:** DECK COMPLETE - All slides imported from archive

### 2026-01-21
- **Task:** Add two new slides summarizing recent papers after eBay case study
- **Actions performed:**
  1. Read two newest papers from articles folder:
     - Simonov, Nosko & Rao (2017): "Competition and Crowd-out for Brand Keywords in Sponsored Search"
     - Simonov & Rao (2018): "Firms' Reactions to Public Information on Business Practices"
  2. Extracted and cropped Figure 8 from Simonov, Nosko & Rao paper (page 20) at 300 DPI
     - Shows focal brand traffic declining from 61% to 45% with 1-4 competitors
     - Saved as `images/simonov_nosko_rao_2017_fig8.png`
  3. Added two new slides after "eBay Results: Attribution vs Reality":
     - Slide: "But What If You Don't Defend Your Brand Keywords?" (Figure 8)
     - Slide: "Did Other Firms Learn from eBay?" (using existing rs18.png)
  4. Re-rendered HTML successfully
- **Verification:** HTML renders without errors, both new slides appear correctly after eBay case study
- **Files modified:**
  - `admeas.qmd`: Added 2 new slides (now 95 slides)
  - `admeas.html`: Re-rendered
  - `images/simonov_nosko_rao_2017_fig8.png`: New cropped figure

### 2026-01-22
- **Task:** Refine slides 31-36 (eBay case study wrap-up and transitions)
- **Actions performed:**
  1. **Slide 31 edits:**
     - Removed "by Microsoft researchers" from callout
     - Added sentence: "The eBay result did not generalize to companies whose competitors bought their own-branded keyword ads."
  2. **Slide 26 edit:** Changed first sentence to "The Correlation guy is silly but he's not harmless."
  3. **Added slide 33** ("eBay Case Study: Key Takeaways"):
     - Added SERP screenshot (`AMimages/SERP_usedguitarlespaul.png`)
     - Callout about eBay returning to advertising in 2026
  4. **Added slide 34** ("Grading Your Own Homework"):
     - Added custom SVG graphic (`AMimages/grading-own-homework.svg`)
     - Added callout about principal/agent problems and CFO reporting
  5. **Slide 35** ("2024 Ad Measurement Trends"): Already complete
  6. **Slide 36** ("Google Trends: Ad Experiments"):
     - Resized image from 350px to 400px
     - Added source URL linking to Google Trends
  7. **Folder rename:** Renamed `/images` to `/AMimages`, updated all image references
  8. **Added Custom Graphics Style Guide** to CLAUDE.md documenting style choices from grading-own-homework.svg
- **Verification:** HTML renders correctly after each change
- **Files modified:**
  - `admeas.qmd`: Multiple slide edits, 2 new slides added
  - `admeas.html`: Re-rendered
  - `CLAUDE.md`: Added Custom Graphics Style Guide section
  - Renamed `images/` → `AMimages/`
- **Next session:** Continue with slides 37+
