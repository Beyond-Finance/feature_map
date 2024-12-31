export function healthScoreStatus(score) {
  if (score < 50) return "Needs Attention";
  if (score < 80) return "Needs Improvement";
  return "Healthy Feature";
}

export const healthScoreHexColor = (score) => {
  if (score < 33) return '#ef4444'; // red
  if (score < 66) return '#facc15'; // yellow
  return '#22c55e'; // green
}

export const healthScoreBackgroundColor = (score) => {
  if (score < 33) return 'bg-red-100/60';
  if (score < 66) return 'bg-yellow-100/60';
  return 'bg-green-100/60';
}
