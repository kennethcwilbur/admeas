#!/bin/bash
# generate-grading-homework.sh
# Generates the "Grading Your Own Homework" advertising measurement hierarchy SVG
# Usage: ./generate-grading-homework.sh [output_file.svg]

OUTPUT="${1:-grading-homework-hierarchy-wide.svg}"

cat > "$OUTPUT" << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 500" width="1200" height="500">
  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#1a1a2e"/>
      <stop offset="100%" style="stop-color:#16213e"/>
    </linearGradient>
    <linearGradient id="paperGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#fffef8"/>
      <stop offset="100%" style="stop-color:#f5f0e0"/>
    </linearGradient>
    <filter id="paperShadow">
      <feDropShadow dx="3" dy="5" stdDeviation="5" flood-opacity="0.35"/>
    </filter>
    <marker id="arrowhead" markerWidth="12" markerHeight="8" refX="11" refY="4" orient="auto">
      <polygon points="0 0, 12 4, 0 8" fill="#888"/>
    </marker>
    <pattern id="lines" patternUnits="userSpaceOnUse" width="100" height="24">
      <line x1="0" y1="24" x2="100" y2="24" stroke="#c8d4e8" stroke-width="1"/>
    </pattern>
  </defs>
  
  <!-- Background -->
  <rect width="1200" height="500" fill="#ffffff"/>
  
  <!-- ===== PLATFORM LEVEL (leftmost) ===== -->
  <g transform="translate(30, 60)">
    <!-- Role label -->
    <rect x="0" y="0" width="120" height="36" rx="6" fill="#ffffff" stroke="#5c3d3d" stroke-width="1.5"/>
    <text x="60" y="24" font-family="Georgia, serif" font-size="18" font-weight="bold" fill="#5c3d3d" text-anchor="middle">Ad Platform</text>
    
    <!-- Speech bubble -->
    <rect x="0" y="50" width="220" height="55" rx="8" fill="#ffffff" stroke="#8a5a5a" stroke-width="1.5"/>
    <polygon points="50,50 60,35 70,50" fill="#ffffff" stroke="#8a5a5a" stroke-width="1.5"/>
    <line x1="50" y1="50" x2="70" y2="50" stroke="#ffffff" stroke-width="3"/>
    <text x="110" y="82" font-family="Georgia, serif" font-size="12" fill="#5c3d3d" text-anchor="middle">"How well did your ads perform?"</text>
    
    <!-- Homework paper - SELF GRADED -->
    <g transform="translate(30, 140) rotate(-2)">
      <rect x="0" y="0" width="180" height="220" rx="2" fill="url(#paperGrad)" filter="url(#paperShadow)"/>
      <rect x="0" y="0" width="180" height="220" rx="2" fill="url(#lines)"/>
      <line x1="30" y1="0" x2="30" y2="220" stroke="#e8a0a0" stroke-width="1"/>
      <circle cx="15" cy="40" r="6" fill="#ffffff"/>
      <circle cx="15" cy="110" r="6" fill="#ffffff"/>
      <circle cx="15" cy="180" r="6" fill="#ffffff"/>
      <text x="105" y="28" font-family="Comic Sans MS, cursive" font-size="13" fill="#333" text-anchor="middle">Platform Report</text>
      <line x1="40" y1="32" x2="170" y2="32" stroke="#333" stroke-width="0.5"/>
      <text x="40" y="55" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">Record engagement!</text>
      <text x="40" y="75" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">10x ROAS</text>
      <text x="40" y="95" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">Super-incrementality</text>
      <text x="40" y="115" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">proven. We can't give</text>
      <text x="40" y="135" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">you the data because</text>
      <text x="40" y="155" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">of user privacy, so</text>
      <text x="40" y="175" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">trust us</text>
      <circle cx="140" cy="198" r="22" fill="none" stroke="#cc0000" stroke-width="3"/>
      <text x="140" y="206" font-family="Comic Sans MS, cursive" font-size="26" font-weight="bold" fill="#cc0000" text-anchor="middle">A+</text>
    </g>
    
  </g>
  
  <!-- Arrow Platform -> Agency -->
  <path d="M 260 280 L 310 165" stroke="#888" stroke-width="2" marker-end="url(#arrowhead)" fill="none"/>
  
  <!-- ===== AGENCY LEVEL ===== -->
  <g transform="translate(310, 60)">
    <!-- Role label -->
    <rect x="0" y="0" width="120" height="36" rx="6" fill="#ffffff" stroke="#4a3c50" stroke-width="1.5"/>
    <text x="60" y="24" font-family="Georgia, serif" font-size="18" font-weight="bold" fill="#4a3c50" text-anchor="middle">Ad Agency</text>
    
    <!-- Speech bubble -->
    <rect x="0" y="50" width="220" height="55" rx="8" fill="#ffffff" stroke="#7a5a7a" stroke-width="1.5"/>
    <polygon points="50,50 60,35 70,50" fill="#ffffff" stroke="#7a5a7a" stroke-width="1.5"/>
    <line x1="50" y1="50" x2="70" y2="50" stroke="#ffffff" stroke-width="3"/>
    <text x="110" y="75" font-family="Georgia, serif" font-size="12" fill="#4a3c50" text-anchor="middle">"Are the platforms</text>
    <text x="110" y="92" font-family="Georgia, serif" font-size="12" fill="#4a3c50" text-anchor="middle">performing well?"</text>
    
    <!-- Homework paper from Platform -->
    <g transform="translate(30, 140) rotate(2)">
      <rect x="0" y="0" width="180" height="220" rx="2" fill="url(#paperGrad)" filter="url(#paperShadow)"/>
      <rect x="0" y="0" width="180" height="220" rx="2" fill="url(#lines)"/>
      <line x1="30" y1="0" x2="30" y2="220" stroke="#e8a0a0" stroke-width="1"/>
      <circle cx="15" cy="40" r="6" fill="#ffffff"/>
      <circle cx="15" cy="110" r="6" fill="#ffffff"/>
      <circle cx="15" cy="180" r="6" fill="#ffffff"/>
      <text x="105" y="28" font-family="Comic Sans MS, cursive" font-size="13" fill="#333" text-anchor="middle">Agency Report</text>
      <line x1="40" y1="32" x2="170" y2="32" stroke="#333" stroke-width="0.5"/>
      <text x="40" y="55" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">Our algorithms</text>
      <text x="40" y="75" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">maximized your reach</text>
      <text x="40" y="95" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">Shoppers love us!</text>
      <text x="40" y="115" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">CTR at all-time high</text>
      <circle cx="140" cy="180" r="28" fill="none" stroke="#cc0000" stroke-width="3"/>
      <text x="140" y="190" font-family="Comic Sans MS, cursive" font-size="32" font-weight="bold" fill="#cc0000" text-anchor="middle">A+</text>
    </g>
  </g>
  
  <!-- Arrow Agency -> CMO -->
  <path d="M 540 280 L 590 165" stroke="#888" stroke-width="2" marker-end="url(#arrowhead)" fill="none"/>
  
  <!-- ===== CMO LEVEL ===== -->
  <g transform="translate(590, 60)">
    <!-- Role label -->
    <rect x="0" y="0" width="90" height="36" rx="6" fill="#ffffff" stroke="#3d3a5c" stroke-width="1.5"/>
    <text x="45" y="24" font-family="Georgia, serif" font-size="18" font-weight="bold" fill="#3d3a5c" text-anchor="middle">CMO</text>
    
    <!-- Speech bubble -->
    <rect x="0" y="50" width="220" height="55" rx="8" fill="#ffffff" stroke="#5a5a8a" stroke-width="1.5"/>
    <polygon points="50,50 60,35 70,50" fill="#ffffff" stroke="#5a5a8a" stroke-width="1.5"/>
    <line x1="50" y1="50" x2="70" y2="50" stroke="#ffffff" stroke-width="3"/>
    <text x="110" y="75" font-family="Georgia, serif" font-size="12" fill="#3d3a5c" text-anchor="middle">"Are our agency partners</text>
    <text x="110" y="92" font-family="Georgia, serif" font-size="12" fill="#3d3a5c" text-anchor="middle">delivering results?"</text>
    
    <!-- Homework paper from Agency -->
    <g transform="translate(30, 140) rotate(-2)">
      <rect x="0" y="0" width="180" height="220" rx="2" fill="url(#paperGrad)" filter="url(#paperShadow)"/>
      <rect x="0" y="0" width="180" height="220" rx="2" fill="url(#lines)"/>
      <line x1="30" y1="0" x2="30" y2="220" stroke="#e8a0a0" stroke-width="1"/>
      <circle cx="15" cy="40" r="6" fill="#ffffff"/>
      <circle cx="15" cy="110" r="6" fill="#ffffff"/>
      <circle cx="15" cy="180" r="6" fill="#ffffff"/>
      <text x="105" y="28" font-family="Comic Sans MS, cursive" font-size="13" fill="#333" text-anchor="middle">Marketing Report</text>
      <line x1="40" y1="32" x2="170" y2="32" stroke="#333" stroke-width="0.5"/>
      <text x="40" y="55" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">Our media strategy</text>
      <text x="40" y="75" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">outperformed benchmarks</text>
      <text x="40" y="95" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">Optimizations drove</text>
      <text x="40" y="115" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">+50% efficiency</text>
      <text x="40" y="135" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">despite headwinds</text>
      <text x="40" y="155" font-family="Comic Sans MS, cursive" font-size="10" fill="#444">CPM down 30%</text>
      <circle cx="140" cy="180" r="28" fill="none" stroke="#cc0000" stroke-width="3"/>
      <text x="140" y="190" font-family="Comic Sans MS, cursive" font-size="32" font-weight="bold" fill="#cc0000" text-anchor="middle">A+</text>
    </g>
  </g>
  
  <!-- Arrow CMO -> CFO -->
  <path d="M 820 280 L 870 165" stroke="#888" stroke-width="2" marker-end="url(#arrowhead)" fill="none"/>
  
  <!-- ===== CFO LEVEL (rightmost) ===== -->
  <g transform="translate(870, 60)">
    <!-- Role label -->
    <rect x="0" y="0" width="90" height="36" rx="6" fill="#ffffff" stroke="#2d4a3e" stroke-width="1.5"/>
    <text x="45" y="24" font-family="Georgia, serif" font-size="18" font-weight="bold" fill="#2d4a3e" text-anchor="middle">CFO</text>
    
    <!-- Speech bubble -->
    <rect x="0" y="50" width="220" height="55" rx="8" fill="#ffffff" stroke="#4a7a6a" stroke-width="1.5"/>
    <polygon points="50,50 60,35 70,50" fill="#ffffff" stroke="#4a7a6a" stroke-width="1.5"/>
    <line x1="50" y1="50" x2="70" y2="50" stroke="#ffffff" stroke-width="3"/>
    <text x="110" y="70" font-family="Georgia, serif" font-size="12" fill="#2d4a3e" text-anchor="middle">"What was our return on</text>
    <text x="110" y="87" font-family="Georgia, serif" font-size="12" fill="#2d4a3e" text-anchor="middle">last year's Marketing budget?"</text>
    
  </g>
</svg>
SVGEOF

echo "Generated: $OUTPUT"
