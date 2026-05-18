import { Router } from "express";
import { prisma } from "../lib/prisma";
import { authGuard } from "../middleware/authGuard";

const DEFAULT_HISTORY_LIMIT = 20;
const MAX_HISTORY_LIMIT = 100;
const DEFAULT_ANALYTICS_DAYS = 7;
const MAX_ANALYTICS_DAYS = 90;
const DEFAULT_TOPIC_LIMIT = 10;
const MAX_TOPIC_LIMIT = 50;

type AttemptWithTopic = {
  question_id: string;
  is_correct: boolean;
  question: {
    topic: {
      id: string;
      unit_no: number;
      title: string;
    } | null;
  };
};

const getGrade = (percentage: number) => {
  if (percentage >= 75) {
    return "A";
  }

  if (percentage >= 65) {
    return "B";
  }

  if (percentage >= 55) {
    return "C";
  }

  if (percentage >= 35) {
    return "S";
  }

  return "F";
};

const getPositiveInteger = (value: unknown, fallback: number) => {
  if (typeof value !== "string" || value.trim() === "") {
    return fallback;
  }

  const parsedValue = Number(value);

  return Number.isInteger(parsedValue) && parsedValue > 0 ? parsedValue : NaN;
};

const formatDateKey = (date: Date) => date.toISOString().slice(0, 10);

const buildUtcDayRange = (days: number) => {
  const now = new Date();
  const end = new Date(now);
  end.setUTCHours(23, 59, 59, 999);

  const start = new Date(end);
  start.setUTCDate(start.getUTCDate() - (days - 1));
  start.setUTCHours(0, 0, 0, 0);

  return { start, end };
};

const buildTopicAnalytics = (attempts: AttemptWithTopic[]) => {
  const topicMap = new Map<
    string,
    {
      topic_id: string;
      unit_no: number;
      title: string;
      attempts: number;
      unique_questions: Set<string>;
      correct: number;
      incorrect: number;
    }
  >();

  for (const attempt of attempts) {
    const topic = attempt.question.topic;

    if (!topic) {
      continue;
    }

    const existing = topicMap.get(topic.id) ?? {
      topic_id: topic.id,
      unit_no: topic.unit_no,
      title: topic.title,
      attempts: 0,
      unique_questions: new Set<string>(),
      correct: 0,
      incorrect: 0,
    };

    existing.attempts += 1;
    existing.unique_questions.add(attempt.question_id);

    if (attempt.is_correct) {
      existing.correct += 1;
    } else {
      existing.incorrect += 1;
    }

    topicMap.set(topic.id, existing);
  }

  return [...topicMap.values()]
    .map((topic) => {
      const accuracyPercentage =
        topic.attempts === 0 ? 0 : Math.round((topic.correct / topic.attempts) * 100);

      return {
        topic_id: topic.topic_id,
        unit_no: topic.unit_no,
        title: topic.title,
        attempts: topic.attempts,
        unique_questions_attempted: topic.unique_questions.size,
        correct: topic.correct,
        incorrect: topic.incorrect,
        accuracy_percentage: accuracyPercentage,
        weakness_score: topic.incorrect,
        grade: getGrade(accuracyPercentage),
      };
    })
    .sort((a, b) => {
      if (b.weakness_score !== a.weakness_score) {
        return b.weakness_score - a.weakness_score;
      }

      if (a.accuracy_percentage !== b.accuracy_percentage) {
        return a.accuracy_percentage - b.accuracy_percentage;
      }

      if (b.attempts !== a.attempts) {
        return b.attempts - a.attempts;
      }

      return a.unit_no - b.unit_no;
    });
};

export const userRouter = Router();

userRouter.get("/user/performance", authGuard, async (req, res) => {
  const attempts = await prisma.progress.findMany({
    where: {
      user_id: req.user.userId,
    },
    orderBy: {
      timestamp: "desc",
    },
    select: {
      id: true,
      question_id: true,
      submitted_answer: true,
      is_correct: true,
      timestamp: true,
      question: {
        select: {
          id: true,
          year: true,
          question_no: true,
          topic_id: true,
          topic: {
            select: {
              id: true,
              unit_no: true,
              title: true,
            },
          },
        },
      },
    },
  });

  const totalAttempts = attempts.length;
  const correctAttempts = attempts.filter((attempt) => attempt.is_correct).length;
  const incorrectAttempts = totalAttempts - correctAttempts;
  const percentage =
    totalAttempts === 0 ? 0 : Math.round((correctAttempts / totalAttempts) * 100);
  const grade = getGrade(percentage);
  const uniqueQuestionCount = new Set(attempts.map((attempt) => attempt.question_id)).size;

  const weakTopics = buildTopicAnalytics(attempts).filter((topic) => topic.incorrect > 0);

  const recentAttempts = attempts.slice(0, 10).map((attempt) => ({
    attempt_id: attempt.id,
    question_id: attempt.question_id,
    submitted_answer: attempt.submitted_answer,
    is_correct: attempt.is_correct,
    timestamp: attempt.timestamp,
    question: {
      id: attempt.question.id,
      year: attempt.question.year,
      question_no: attempt.question.question_no,
      topic: attempt.question.topic,
    },
  }));

  res.status(200).json({
    total_attempts: totalAttempts,
    unique_questions_attempted: uniqueQuestionCount,
    correct_attempts: correctAttempts,
    incorrect_attempts: incorrectAttempts,
    percentage,
    grade,
    weak_topics: weakTopics,
    recent_attempts: recentAttempts,
  });
});

userRouter.get("/user/performance/topic-analytics", authGuard, async (req, res) => {
  const limit = getPositiveInteger(req.query.limit, DEFAULT_TOPIC_LIMIT);

  if (!Number.isInteger(limit) || limit < 1 || limit > MAX_TOPIC_LIMIT) {
    res.status(400).json({
      message: `limit must be between 1 and ${MAX_TOPIC_LIMIT}.`,
      default_limit: DEFAULT_TOPIC_LIMIT,
      max_limit: MAX_TOPIC_LIMIT,
    });
    return;
  }

  const attempts = await prisma.progress.findMany({
    where: {
      user_id: req.user.userId,
    },
    orderBy: {
      timestamp: "desc",
    },
    select: {
      question_id: true,
      is_correct: true,
      question: {
        select: {
          topic: {
            select: {
              id: true,
              unit_no: true,
              title: true,
            },
          },
        },
      },
    },
  });

  const topicAnalytics = buildTopicAnalytics(attempts);
  const weakTopics = topicAnalytics.filter((topic) => topic.incorrect > 0).slice(0, limit);
  const strongestTopics = [...topicAnalytics]
    .sort((a, b) => {
      if (b.accuracy_percentage !== a.accuracy_percentage) {
        return b.accuracy_percentage - a.accuracy_percentage;
      }

      if (b.correct !== a.correct) {
        return b.correct - a.correct;
      }

      return a.unit_no - b.unit_no;
    })
    .slice(0, limit);

  res.status(200).json({
    total_topics_attempted: topicAnalytics.length,
    weak_topics: weakTopics,
    strongest_topics: strongestTopics,
    topics: topicAnalytics,
  });
});

userRouter.get("/user/performance/history", authGuard, async (req, res) => {
  const limit = getPositiveInteger(req.query.limit, DEFAULT_HISTORY_LIMIT);
  const page = getPositiveInteger(req.query.page, 1);

  if (
    !Number.isInteger(limit) ||
    limit < 1 ||
    limit > MAX_HISTORY_LIMIT ||
    !Number.isInteger(page) ||
    page < 1
  ) {
    res.status(400).json({
      message: `limit must be between 1 and ${MAX_HISTORY_LIMIT}, and page must be at least 1.`,
      default_limit: DEFAULT_HISTORY_LIMIT,
      max_limit: MAX_HISTORY_LIMIT,
    });
    return;
  }

  const skip = (page - 1) * limit;

  const [totalAttempts, attempts] = await Promise.all([
    prisma.progress.count({
      where: {
        user_id: req.user.userId,
      },
    }),
    prisma.progress.findMany({
      where: {
        user_id: req.user.userId,
      },
      orderBy: {
        timestamp: "desc",
      },
      skip,
      take: limit,
      select: {
        id: true,
        question_id: true,
        submitted_answer: true,
        is_correct: true,
        timestamp: true,
        question: {
          select: {
            id: true,
            year: true,
            question_no: true,
            text_en: true,
            text_si: true,
            correct_answer: true,
            topic: {
              select: {
                id: true,
                unit_no: true,
                title: true,
              },
            },
          },
        },
      },
    }),
  ]);

  const totalPages = totalAttempts === 0 ? 0 : Math.ceil(totalAttempts / limit);

  res.status(200).json({
    pagination: {
      page,
      limit,
      total_attempts: totalAttempts,
      total_pages: totalPages,
      has_next_page: page < totalPages,
      has_previous_page: page > 1,
    },
    history: attempts.map((attempt) => ({
      attempt_id: attempt.id,
      question_id: attempt.question_id,
      submitted_answer: attempt.submitted_answer,
      correct_answer: attempt.question.correct_answer,
      is_correct: attempt.is_correct,
      timestamp: attempt.timestamp,
      question: {
        id: attempt.question.id,
        year: attempt.question.year,
        question_no: attempt.question.question_no,
        text_en: attempt.question.text_en,
        text_si: attempt.question.text_si,
        topic: attempt.question.topic,
      },
    })),
  });
});

userRouter.get("/user/performance/daily-analytics", authGuard, async (req, res) => {
  const days = getPositiveInteger(req.query.days, DEFAULT_ANALYTICS_DAYS);

  if (!Number.isInteger(days) || days < 1 || days > MAX_ANALYTICS_DAYS) {
    res.status(400).json({
      message: `days must be between 1 and ${MAX_ANALYTICS_DAYS}.`,
      default_days: DEFAULT_ANALYTICS_DAYS,
      max_days: MAX_ANALYTICS_DAYS,
    });
    return;
  }

  const { start, end } = buildUtcDayRange(days);
  const attempts = await prisma.progress.findMany({
    where: {
      user_id: req.user.userId,
      timestamp: {
        gte: start,
        lte: end,
      },
    },
    orderBy: {
      timestamp: "asc",
    },
    select: {
      id: true,
      is_correct: true,
      timestamp: true,
    },
  });

  const analyticsMap = new Map<
    string,
    {
      date: string;
      attempts: number;
      correct: number;
      incorrect: number;
    }
  >();

  for (let index = 0; index < days; index += 1) {
    const date = new Date(start);
    date.setUTCDate(start.getUTCDate() + index);
    const key = formatDateKey(date);

    analyticsMap.set(key, {
      date: key,
      attempts: 0,
      correct: 0,
      incorrect: 0,
    });
  }

  for (const attempt of attempts) {
    const key = formatDateKey(attempt.timestamp);
    const currentDay = analyticsMap.get(key);

    if (!currentDay) {
      continue;
    }

    currentDay.attempts += 1;

    if (attempt.is_correct) {
      currentDay.correct += 1;
    } else {
      currentDay.incorrect += 1;
    }
  }

  const dailyAnalytics = [...analyticsMap.values()].map((day) => ({
    ...day,
    percentage: day.attempts === 0 ? 0 : Math.round((day.correct / day.attempts) * 100),
  }));

  const totals = dailyAnalytics.reduce(
    (summary, day) => {
      summary.attempts += day.attempts;
      summary.correct += day.correct;
      summary.incorrect += day.incorrect;
      return summary;
    },
    {
      attempts: 0,
      correct: 0,
      incorrect: 0,
    },
  );

  res.status(200).json({
    range: {
      days,
      from: formatDateKey(start),
      to: formatDateKey(end),
    },
    totals: {
      attempts: totals.attempts,
      correct: totals.correct,
      incorrect: totals.incorrect,
      percentage:
        totals.attempts === 0 ? 0 : Math.round((totals.correct / totals.attempts) * 100),
      grade:
        totals.attempts === 0
          ? getGrade(0)
          : getGrade(Math.round((totals.correct / totals.attempts) * 100)),
    },
    daily: dailyAnalytics,
  });
});
