export const meta = {
  name: 'math-router',
  description: 'Route math tasks to Haiku/Sonnet/Opus based on complexity tier',
  phases: [
    { title: 'Analyze', detail: 'Evaluate task complexity against custom rules' },
    { title: 'Execute', detail: 'Solve in recommended model with Wolfram' },
  ],
}

// Validate input
if (!args || typeof args !== 'string') {
  throw new Error('Usage: /math <your math problem or question>')
}

const userProblem = args

phase('Analyze')

// Route the problem to the correct model tier
const analysis = await agent(
  `You are a Math Advisor tasked with routing problems to the correct model tier.

**PROBLEM TO ANALYZE:**
${userProblem}

**YOUR TASK:**
Carefully analyze this problem and decide which model should solve it.

Apply these categorization rules STRICTLY:

**HAIKU + WOLFRAM** (Simple algebra — cost efficient):
- Linear equations: 1-2 steps
- Basic arithmetic, factoring, simplification
- Conceptual math questions (no calculations)
- Function evaluations at specific points
- Examples: "Solve x+5=10", "Factor x²-4", "What is a derivative?"

**SONNET + WOLFRAM** (Advanced algebra & calculus — reasoning + computation):
- Multi-step algebraic equations or functions (3+ steps, fractions, radicals)
- Calculus: derivatives, integrals, limits, optimization
- Algebraic geometry: line intersections, parametric equations, coordinate forms
- Problem decomposition and structured solutions
- Examples: "Find d/dx[e^(2x)sin(x)]", "Compute ∫x³e^x dx", "Find where line y=2x intersects circle x²+y²=4"

**OPUS + WOLFRAM** (Complex geometry — spatial reasoning required):
- Coordinate geometry: circles, tangent lines, intersections, centers, radii
- Geometric theorems and proofs requiring spatial understanding
- Power of a point, loci of points, circumscribed circles
- Problems combining multiple geometric concepts
- Geometric constructions and validity checks
- Examples: "Find tangent lines from point P(1,2) to circle (x-3)²+(y-1)²=5", "Prove this locus is a circle", "Find the circumcircle of triangle ABC"

**DECISION LOGIC:**
1. Is ANY geometry beyond simple lines? → OPUS
2. Does it involve calculus or integrals? → SONNET
3. Is it multi-step (3+) algebra with fractions/radicals? → SONNET
4. Otherwise (simple, 1-2 steps, conceptual)? → HAIKU

**RETURN** a JSON object:
{
  "model": "haiku" or "sonnet" or "opus",
  "reasoning": "Concise explanation of choice",
  "classification": "The tier this belongs to"
}

Be conservative: when in doubt between Sonnet and Opus, choose Opus. When in doubt between Haiku and Sonnet, choose Sonnet.`,
  {
    label: 'math-advisor-route',
    phase: 'Analyze',
    schema: {
      type: 'object',
      properties: {
        model: {
          type: 'string',
          enum: ['haiku', 'sonnet', 'opus'],
          description: 'Target model tier'
        },
        reasoning: {
          type: 'string',
          description: 'Why this model was selected'
        },
        classification: {
          type: 'string',
          description: 'Tier category (Simple Algebra / Advanced Algebra & Calculus / Complex Geometry)'
        }
      },
      required: ['model', 'reasoning', 'classification']
    }
  }
)

log(`📊 Tier: ${analysis.classification}`)
log(`🎯 Model: ${analysis.model.toUpperCase()} — ${analysis.reasoning}`)

phase('Execute')

// Solve in the recommended model with Wolfram integration
const solution = await agent(
  `**MATH PROBLEM:**
${userProblem}

**SOLVE COMPLETELY:**
1. Break down the problem into clear steps
2. For ALL calculations (arithmetic, algebra, calculus, integrals, limits):
   - Use Wolfram Alpha via available tools
   - Show the Wolfram steps/reasoning in your solution
3. Use proper mathematical notation ($...$)
4. Verify your final answer satisfies all conditions
5. Provide clear reasoning at each step

Return your complete worked solution:`,
  {
    label: `math-solve-${analysis.model}`,
    phase: 'Execute',
    model: analysis.model
  }
)

log(`✅ Solution computed using ${analysis.model.toUpperCase()}`)

return {
  model_used: analysis.model,
  tier: analysis.classification,
  advisor_note: analysis.reasoning,
  solution: solution
}
