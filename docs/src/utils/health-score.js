export const healthScores = {
  needsAttention: 50,
  needsImprovement: 80,
  healthy: 100
}

export const getHealthScoreColor = (score) => {
  if (!score) return { hex: 'transparent', class: 'bg-transparent' }
  if (score <= healthScores.needsAttention) return { hex: '#ef4444', class: 'bg-red-500' };
  if (score <= healthScores.needsImprovement) return { hex: '#eab308', class: 'bg-yellow-500' };
  return {
    hex: '#22c55e',
    class: 'bg-green-500'
  };
}

export const getHealthScoreLabel = (score) => {
  if (score < healthScores.needsAttention) return 'needsAttention';
  if (score < healthScores.needsImprovement) return 'needsImprovement';
  return 'healthy';
}

export const healthScoreBackgroundColor = (score) => {
  if (!score) return 'bg-gray-100'
  if (score < healthScores.needsAttention) return 'bg-red-100/60';
  if (score < healthScores.needsImprovement) return 'bg-yellow-100/60';
  return 'bg-green-100/60';
}
