# Advertising Measurement Presentation - Change Log

## 2026-01-28

### Session Summary
Extensive edits to `admeas.qmd` Quarto revealjs presentation for MGTA 451 Marketing course.

### Key Changes Made

**Title slide:**
- Added "Professor of Marketing and Analytics" to author affiliations
- Reorganized date-format text

**Section headers (slides 37, 43, 49, 65):**
- Added preview sub-bullets to all major section headers:
  - "Domain Knowledge" → "Broad context to motivate and interpret advertising measurement"
  - "Causality" → "Examples, fallacies and motivations"
  - "Fundamental Problem of Causal Inference" → "Why causal effects are estimable but not directly measurable"
  - "Correlational Advertising Measurement" → "Analytical frameworks, Facebook study, Why Correlations Persist"
  - "Causal Advertising Measurement" → "Experimental designs, necessary conditions, quasi-experiments"

**Correlational Ad Measurement section (slides 50-57):**
- Created new slide 50 with correlational ad measurement definition and callout
- Applied consistent bullet styling to slides 53-57 (MTA, Steel-manning, Problems 1-3)
- Added callout to slide 56 about simultaneity with Bass (1969) citation
- Positioned circularity image using `.absolute` positioning

**Gordon et al. study slides (59-62):**
- Added callouts summarizing key findings from the research
- Adjusted image sizes for consistent citation positioning

**"Why Are Some Teams OK with Corr(ad,sales)?" slides (originally 63-65):**
- Consolidated from 3 slides to 2 slides by merging content
- Reorganized points for better flow

**New Causal section header slide (65):**
- Added new section header for Causal Advertising Measurement to match Correlational section structure
- Includes preview sub-bullet: "Experimental designs, necessary conditions, quasi-experiments"

**Ad Measurement slide (45):**
- Deleted redundant last sub-bullet

### Verification
- All edits verified by reading file content
- Slide 56 layout confirmed: callout visible in normal position, circularity image positioned at bottom-right using `.absolute` CSS

## 2026-01-30

### Session Summary
Fixed PDF export to use landscape orientation.

### Changes Made
- Added `@media print` CSS rules to `custom.css` forcing landscape page size (11in × 8.5in)
- Re-rendered HTML and regenerated PDF

### Verification
- `pdfinfo` confirms page size: 865.92 × 577.92 pts (landscape)
- Visual verification of slides 1, 10, 45, 47 via `pdftoppm` screenshots
- Title slide, images, callout boxes, and MathJax formulas render correctly
- PDF: 98 pages, 35.1 MB

### Files Modified
- `custom.css`: Added print media query with landscape page size
- `admeas.html`: Re-rendered
- `admeas-slides.pdf`: Regenerated in landscape orientation

## 2026-02-04

### Session Summary
Extensive text edits across 24 slides to improve clarity, precision, and accuracy of content.

### Changes Made

**Slide 19 (Ad spending by sector):**
- Added note about 2 missing data points withheld for confidentiality
- Increased callout font size from 0.6em to 0.75em

**Slide 24 (How Many False Positives?):**
- Added "No causal ordering or reason for co-movement can be inferred from a correlation alone."

**Slide 35 ("Grading Your Own Homework"):**
- Put title in quotes
- Changed "It can help" to "It may help"

**Slide 38 (Fundamental Problem section header):**
- Changed "directly measurable" to "directly observable"

**Slide 40 (Why Care About Causal Effects?):**
- Added treatment effect approximation formula: Yi(Ti=1) - Yi(Ti=0)

**Slide 43 (How Much Does Causality Matter?):**
- Removed .smaller class to increase font size

**Slide 45 (Measurement of What?):**
- Added explanation of paid media publisher role
- Changed "and sales" to "and/or sales"

**Slide 47 (What Do We Measure?):**
- Simplified opening to "Often, Return on Advertising Spend (ROAS)"
- Added .smaller class for better fit

**Slide 49 (Albertsons ROAS):**
- Added "(2025)" to source citation

**Slide 50 (Correlational Advertising Measurement header):**
- Changed "Analytical frameworks" to "Frameworks"

**Slide 52 (Lift Statistics):**
- Changed "this may backfire when" to "often"

**Slide 53 (Regression):**
- Changed title to "2. Regression, usually controlling for other observables"

**Slide 54 (Multi-Touch Attribution):**
- Added "though limited to data within each walled garden;"

**Slide 55 (Steel-manning Corr(ad,sales)):**
- Added "; it could be that the ads got shown to the most loyal customers"

**Slide 58 (Problem 3 with Corr(ad,sales)):**
- Changed "To balance platform power, you have to know" to "The only way to balance platform power is to know"

**Slide 64 (Why Are Some Teams OK?):**
- Added "and find cheaper sources of sales"
- Changed "vs. 100%" to "vs. 150%"

**Slide 65 (Why Are Some Teams OK? continued):**
- Removed extra quote after [Amazon, Google, Meta]

**Slide 67 (Causal Ad Measurement):**
- Deleted sentence "Causality is a property of the data, not the model."

**Slide 71 (Platform Experiments Advisory):**
- Rewrote Meta A/B Test description for clarity
- Added "across time and targeting criteria" to DIY experiments bullet

**Slide 74 (Diff-in-Diffs Cholera):**
- Rewrote callout text for clarity about Southwark/Vauxhall counterfactual
- Changed "widespread understanding" to "modern development"
- Added "(What are the two diffs?)"

**Slide 77 (Ad/Sales Quasi-experiments 2):**
- Changed "arbitrarily" to "based on broadcast signal patterns based on differences from city centers,"

**Slide 80 (Marketing Mix Models):**
- Changed "relates sales to marketing mix variables" to "typically uses marketing mix variables to explain sales"
- Changed "past marketing efforts" to "past marketing ROAS by channel"

**Slide 81 (MMM Components):**
- Changed "known demand shifters" to "known category-specific demand shifters"
- Changed "long-lasting" to "possibly long-lasting"

**Slide 96 (Acknowledgements):**
- Changed "slide deck design" to "assertion-evidence slide format"

**CLAUDE.md updates:**
- Added slide numbering convention note (slide numbers refer to bottom-right corner, starting at 1)

### Verification
- All edits verified via Chromium headless screenshots
- HTML re-rendered after each edit
- No overflow issues detected

### Files Modified
- `admeas.qmd`: 24 slides edited
- `admeas.html`: Re-rendered
- `CLAUDE.md`: Added slide numbering convention

## 2026-02-06

### Session Summary
Enhanced slide #37 with two-column layout and IAB survey graphic.

### Changes Made
1. **Slide 37 (Google Trends: Ad Experiments):** Added second source "IAB (2026)" with Google Drive link, separated by pipe character
2. **Slide 37 layout:** Converted to two-column layout (45%/55%) with:
   - Left: Google Trends graphic (280px height, 16:9 aspect ratio preserved)
   - Right: IAB admeas survey 2026.png (280px height, ~2:1 aspect ratio preserved)
3. **Slide 37 title:** Changed from "Google Trends: Ad Experiments" to "Ad Experiments in GTrends and Buy-side Surveys"

### Verification
- Screenshot confirms both graphics display side by side with callout and sources below

### Files Modified
- `admeas.qmd`: Two-column layout for slide 37
- `admeas.html`: Re-rendered
- `admeas-slides.pdf`: Regenerated (37.3 MB, 98 pages)
