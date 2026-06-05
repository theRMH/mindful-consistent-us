import prisma from './prisma';

/**
 * Checks if a specific course day is unlocked for a user.
 * Day 1 is always unlocked once enrolled.
 * Day N unlocks when CURRENT_DATE >= purchase_date + (N-1) days.
 */
export async function isDayUnlocked(userId: string, courseId: string, dayNumber: number): Promise<boolean> {
  // Day 1 is always unlocked immediately
  if (dayNumber <= 1) {
    return true;
  }

  // Get active enrollment
  const enrollment = await prisma.enrollment.findUnique({
    where: {
      userId_courseId: {
        userId,
        courseId,
      },
    },
  });

  if (!enrollment || !enrollment.isActive) {
    return false;
  }

  const purchaseDate = new Date(enrollment.purchaseDate);
  // Clear time components to compare calendar dates
  purchaseDate.setHours(0, 0, 0, 0);

  const currentDate = new Date();
  currentDate.setHours(0, 0, 0, 0);

  // Difference in time
  const diffTime = currentDate.getTime() - purchaseDate.getTime();
  // Convert difference to calendar days
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

  // Day N unlocks when days elapsed >= N - 1
  return diffDays >= (dayNumber - 1);
}
