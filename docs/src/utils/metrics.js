const collect = ({ featureScores }) => {
  const allScores = featureScores.map(({ score }) => score).filter(score => !!score)
  const maxScore = allScores.reduce((a, b) => Math.max(a, b), -Infinity)

  return featureScores.reduce((annotatedFeatures, featureScore) => {
    const percentile = percentileOf(allScores, featureScore.score)
    const percentOfMax = Math.round(featureScore.score / maxScore * 100)

    return {
      ...annotatedFeatures,
      [featureScore.feature]: {
        percentile,
        percentOfMax,
        score: featureScore.score
      }
    }
  }, {})
}

const cyclomaticComplexityScoreFor = ({ metrics }) => {
  if (metrics.lines_of_code === null || metrics.cyclomatic_complexity === null) {
    return null
  }

  // Lines of Code per Cyclomatic Complexity (Bigger -> Better)
  return (metrics.lines_of_code / metrics.cyclomatic_complexity).toFixed(2)
}

const cyclomaticComplexityScores = ({ features }) => {
  const featureScores = Object
    .entries(features)
    .map(([feature, { metrics }]) => {
      return {
        feature,
        score: cyclomaticComplexityScoreFor({ metrics }),
      }
    })

  return collect({ featureScores })
}

const encapsulationScoreFor = ({ assignments, metrics }) => {
  if (assignments.files === null || metrics.lines_of_code === null) {
    return null
  }

  // Files per Line of Code
  // Score approaches 1 (when every file has exactly one line of code)
  // Naively we assume closer to 1 is better, but this definitely falls
  // apart if functionality is _too_ encapsulated.
  return (assignments.files.length / metrics.lines_of_code).toFixed(8)
}

const encapsulationScores = ({ features }) => {
  const featureScores = Object
    .entries(features)
    .map(([feature, { assignments, metrics }]) => {
      return {
        feature,
        score: encapsulationScoreFor({ assignments, metrics }),
      }
    })

  return collect({ featureScores })
}

const percentileOf = (arr, val) => {
  const ensureArrayOfFloats = arr.map(v => parseFloat(v, 10))
  const ensureFloatValue = parseFloat(val, 10)

  const belowOrEqualCount = ensureArrayOfFloats.reduce((acc, v) => {
    if (v < ensureFloatValue) {
      return acc + 1
    }
    if (v === ensureFloatValue) {
      return acc + 0.5
    }
    return acc
  }, 0)

  return (100 * belowOrEqualCount) / ensureArrayOfFloats.length
}

const testCoverageFor = ({ test_coverage }) => {
  if (test_coverage === null || test_coverage.hits === null || test_coverage.lines === null) {
    return null
  }

  // Percentage of coverage
  // Score approaches 100 (when all lines are covered)
  return Math.round(test_coverage.hits / test_coverage.lines * 100)
}

const testCoverageScores = ({ features }) => {
  const featureScores = Object
    .entries(features)
    .map(([feature, { test_coverage }]) => {
      return {
        feature,
        score: testCoverageFor({ test_coverage }),
      }
    })

  return collect({ featureScores })
}

export const averages = ({ features }) => {
  const totalFeatures = Object.keys(features).length
  const totals = Object.values(features).reduce((acc, feature) => {
    const { abcSize, linesOfCode, cyclomaticComplexity } = acc
    return {
      abcSize: abcSize + feature.metrics.abc_size,
      linesOfCode: linesOfCode + feature.metrics.lines_of_code,
      cyclomaticComplexity: cyclomaticComplexity + feature.metrics.cyclomatic_complexity,
    }
  }, { abcSize: 0, linesOfCode: 0, cyclomaticComplexity: 0 })

  return {
    abcSize: (totals.abcSize / totalFeatures).toFixed(2),
    linesOfCode: (totals.linesOfCode / totalFeatures).toFixed(2),
    cyclomaticComplexity: (totals.cyclomaticComplexity / totalFeatures).toFixed(2),
  }
}

export const scores = ({ features }) => ({
  encapsulationScores: encapsulationScores({ features }),
  cyclomaticComplexityScores: cyclomaticComplexityScores({ features }),
  testCoverageScores: testCoverageScores({ features }),
})
