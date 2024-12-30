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
      healthScore: awardablePoints,
      closeToMaximumScore,
      exceedsScoreThreshold,
    }
  }

  return {
    healthScore: (score / scoreThreshold) * awardablePoints,
    closeToMaximumScore,
    exceedsScoreThreshold,
  }
}

export const healthScore = ({
  encapsulation,
  cyclomaticComplexity,
  testCoverage
}) => {
  const testCoverageComponent = healthScoreComponent({
    awardablePoints: 70,
    score: testCoverage.score,
    scoreThreshold: 95,
  })

  const cyclomaticComplexityComponent = healthScoreComponent({
    awardablePoints: 15,
    score: cyclomaticComplexity.percentile,
    scoreThreshold: 100,
    percentOfMax: cyclomaticComplexity.percentOfMax,
    percentOfMaxThreshold: 95,
  })

  const encapsulationComponent = healthScoreComponent({
    awardablePoints: 15,
    score: encapsulation.percentile,
    scoreThreshold: 100,
    percentOfMax: encapsulation.percentOfMax,
    percentOfMaxThreshold: 95,
  })

  const overall =
    testCoverageComponent.healthScore
      + cyclomaticComplexityComponent.healthScore
      + encapsulationComponent.healthScore

  return {
    testCoverageComponent,
    cyclomaticComplexityComponent,
    encapsulationComponent,
    overall: overall.toFixed(2),
  }
}
