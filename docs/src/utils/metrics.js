import { config } from './config'

const calculate = ({ collection, score }) => {
  const max = Math.max(...collection)
  const percentile = percentileOf(collection, score)
  const percentOfMax = Math.round(score / max * 100)

  return {
    percentile,
    percentOfMax,
    score,
  }
}

const cyclomaticComplexityFor = ({ metrics }) => {
  if (metrics.lines_of_code === null || metrics.cyclomatic_complexity === null) {
    return null
  }

  // Lines of Code per Cyclomatic Complexity (Bigger -> Better)
  return metrics.lines_of_code / metrics.cyclomatic_complexity
}

const encapsulationFor = ({ assignments, metrics }) => {
  if (assignments.files === null || metrics.lines_of_code === null) {
    return null
  }

  // Files per Line of Code
  // Score approaches 1 (when every file has exactly one line of code)
  // Naively we assume closer to 1 is better, but this definitely falls
  // apart if functionality is _too_ encapsulated.
  return assignments.files.length / metrics.lines_of_code
}

const featureSizeFor = ({ assignments, metrics }) => {
  return metrics.lines_of_code
}

const healthScoreComponent = ({
  awardablePoints,
  score,
  scoreThreshold,
  percentOfMax = 0,
  percentOfMaxThreshold = 100,
}) => {
  // NOTE:  If this feature's absolute component score is close to the best
  //        component score across the codebase, regardless of its percentile,
  //        award it full points.
  //        EX:  If the variance between the "best" and "worst" cyclomatic complexity
  //             is only 10%, it's not meaningful to award points for this metric.
  const closeToMaximumScore = percentOfMax >= percentOfMaxThreshold

  // NOTE:  If this feature's component score is above the minimum ideal score,
  //        award it full points.
  //        EX:  Shooting for 100% test coverage may not be very useful, so
  //             award full points if test coverage is at least 95%
  const exceedsScoreThreshold = score >= scoreThreshold

  if (closeToMaximumScore || exceedsScoreThreshold) {
    return {
      awardablePoints,
      healthScore: awardablePoints,
      closeToMaximumScore,
      exceedsScoreThreshold,
    }
  }

  return {
    awardablePoints,
    healthScore: (score / scoreThreshold) * awardablePoints,
    closeToMaximumScore,
    exceedsScoreThreshold,
  }
}

const healthScoreFor = ({
  encapsulation,
  cyclomaticComplexity,
  testCoverage
}) => {
  const {
    cyclomatic_complexity: cyclomaticComplexityConfig,
    encapsulation: encapsulationConfig,
    test_coverage: testCoverageConfig
  } = config.project.documentation_site.health.components

  const testCoverageComponent = healthScoreComponent({
    awardablePoints: testCoverageConfig.weight,
    score: testCoverage.score,
    scoreThreshold: testCoverageConfig.score_threshold,
  })

  const cyclomaticComplexityComponent = healthScoreComponent({
    awardablePoints: cyclomaticComplexityConfig.weight,
    score: cyclomaticComplexity.percentile,
    scoreThreshold: cyclomaticComplexityConfig.score_threshold,
    percentOfMax: cyclomaticComplexity.percentOfMax,
    percentOfMaxThreshold: 100 - cyclomaticComplexityConfig.minimum_variance,
  })

  const encapsulationComponent = healthScoreComponent({
    awardablePoints: encapsulationConfig.weight,
    score: encapsulation.percentile,
    scoreThreshold: encapsulationConfig.score_threshold,
    percentOfMax: encapsulation.percentOfMax,
    percentOfMaxThreshold: 100 - encapsulationConfig.minimum_variance,
  })

  const overall =
    testCoverageComponent.healthScore
      + cyclomaticComplexityComponent.healthScore
      + encapsulationComponent.healthScore

  return {
    testCoverageComponent,
    cyclomaticComplexityComponent,
    encapsulationComponent,
    overall,
  }
}

const metricsFor = ({ features }) => {
  const featureMetrics = Object
    .entries(features)
    .map(([featureName, feature]) => {
      const { assignments, metrics, test_coverage } = feature

      return {
        featureName,
        cyclomaticComplexity: cyclomaticComplexityFor({ metrics }),
        encapsulation: encapsulationFor({ assignments, metrics }),
        featureSize: featureSizeFor({ assignments, metrics }),
        testCoverage: testCoverageFor({ test_coverage }),
      }
    }, {})

  const cyclomaticComplexities = featureMetrics.map(({ cyclomaticComplexity }) => cyclomaticComplexity).filter(v => !!v)
  const encapsulations = featureMetrics.map(({ encapsulation }) => encapsulation).filter(v => !!v)
  const featureSizes = featureMetrics.map(({ featureSize }) => featureSize).filter(v => !!v)
  const testCoverages = featureMetrics.map(({ testCoverage }) => testCoverage).filter(v => !!v)

  return featureMetrics.reduce((accumulatingFeatureMetrics, featureMetric) => {
    return {
      ...accumulatingFeatureMetrics,
      [featureMetric.featureName]: {
        cyclomaticComplexity: calculate({ collection: cyclomaticComplexities, score: featureMetric.cyclomaticComplexity }),
        encapsulation: calculate({ collection: encapsulations, score: featureMetric.encapsulation }),
        featureSize: calculate({ collection: featureSizes, score: featureMetric.featureSize }),
        testCoverage: calculate({ collection: testCoverages, score: featureMetric.testCoverage }),
      }
    }
  }, {})
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
    abcSize: totals.abcSize / totalFeatures,
    linesOfCode: totals.linesOfCode / totalFeatures,
    cyclomaticComplexity: totals.cyclomaticComplexity / totalFeatures,
    totalFeatures: totalFeatures
  }
}

export const annotate = ({ features }) => {
  const metrics = metricsFor({ features })

  return Object.entries(features).reduce((annotatedFeatures, [featureName, feature]) => {
    const { cyclomaticComplexity, encapsulation, featureSize, testCoverage } = metrics[featureName]
    const health = healthScoreFor({ cyclomaticComplexity, encapsulation, testCoverage })

    return {
      ...annotatedFeatures,
      [featureName]: {
        ...feature,
        metrics: {
          ...feature.metrics,
          encapsulation,
          featureSize,
          health,
          cyclomaticComplexity,
          testCoverage,
        }
      }
    }
  }, {})
}
