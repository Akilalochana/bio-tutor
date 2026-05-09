import { Router } from "express";
import { prisma } from "../lib/prisma";
import { authGuard } from "../middleware/authGuard";
import { AnswerOption } from "../generated/prisma/enums";

const answerOptions = new Set(["A", "B", "C", "D", "E"]);
const PAPER_YEAR_LIMIT = 20;
const DEFAULT_RANDOM_QUESTION_LIMIT = 10;
const MAX_RANDOM_QUESTION_LIMIT = 30;

const questionSelect = {
  id: true,
  year: true,
  question_no: true,
  text_si: true,
  text_en: true,
  options: true,
  topic_id: true,
  topic: {
    select: {
      id: true,
      unit_no: true,
      title: true,
    },
  },
} as const;

type SubmittedAnswer = {
  question_id?: string;
  answer?: string;
};

export const questionRouter = Router();

const shuffleItems = <T>(items: T[]) => {
  const shuffled = [...items];

  for (let i = shuffled.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }

  return shuffled;
};

questionRouter.get("/questions/random", async (req, res) => {
  const currentYear = new Date().getFullYear();
  const earliestAllowedYear = currentYear - PAPER_YEAR_LIMIT;
  const rawLimit = req.query.limit;
  const limit =
    typeof rawLimit === "string" && rawLimit.trim() !== ""
      ? Number(rawLimit)
      : DEFAULT_RANDOM_QUESTION_LIMIT;

  if (!Number.isInteger(limit) || limit < 1 || limit > MAX_RANDOM_QUESTION_LIMIT) {
    res.status(400).json({
      message: `limit must be an integer between 1 and ${MAX_RANDOM_QUESTION_LIMIT}.`,
      default_limit: DEFAULT_RANDOM_QUESTION_LIMIT,
      max_limit: MAX_RANDOM_QUESTION_LIMIT,
    });
    return;
  }

  const availableQuestions = await prisma.question.findMany({
    where: {
      year: {
        gte: earliestAllowedYear,
        lte: currentYear,
      },
    },
    select: questionSelect,
  });

  const questions = shuffleItems(availableQuestions).slice(0, limit);

  res.status(200).json({
    count: questions.length,
    requested_limit: limit,
    available_count: availableQuestions.length,
    earliest_year: earliestAllowedYear,
    latest_year: currentYear,
    questions,
  });
});

questionRouter.get("/questions/:year(\\d+)", async (req, res) => {
  const year = Number(req.params.year);
  const currentYear = new Date().getFullYear();
  const earliestAllowedYear = currentYear - PAPER_YEAR_LIMIT;

  if (year < earliestAllowedYear || year > currentYear) {
    res.status(400).json({
      message: `Questions are available only from ${earliestAllowedYear} to ${currentYear}.`,
      earliest_year: earliestAllowedYear,
      latest_year: currentYear,
    });
    return;
  }

  const questions = await prisma.question.findMany({
    where: { year },
    orderBy: { question_no: "asc" },
    select: questionSelect,
  });

  res.status(200).json({ year, count: questions.length, questions });
});

questionRouter.get("/questions/:id", async (req, res) => {
  const question = await prisma.question.findUnique({
    where: { id: req.params.id },
    select: questionSelect,
  });

  if (!question) {
    res.status(404).json({ message: "Question not found." });
    return;
  }

  res.status(200).json({ question });
});

questionRouter.post("/submit-answers", authGuard, async (req, res) => {
  const answers = req.body.answers as SubmittedAnswer[] | undefined;

  if (!Array.isArray(answers) || answers.length === 0) {
    res.status(400).json({ message: "answers must be a non-empty array." });
    return;
  }

  const invalidAnswer = answers.find(
    (item) =>
      !item.question_id ||
      !item.answer ||
      !answerOptions.has(item.answer.trim().toUpperCase()),
  );

  if (invalidAnswer) {
    res.status(400).json({
      message: "Each answer needs question_id and answer as A, B, C, D, or E.",
    });
    return;
  }

  const normalizedAnswers = answers.map((item) => ({
    question_id: item.question_id as string,
    answer: (item.answer as string).trim().toUpperCase(),
  }));

  const uniqueQuestionIds = [...new Set(normalizedAnswers.map((item) => item.question_id))];
  const questions = await prisma.question.findMany({
    where: { id: { in: uniqueQuestionIds } },
    select: {
      id: true,
      correct_answer: true,
      topic_id: true,
      topic: {
        select: {
          id: true,
          unit_no: true,
          title: true,
        },
      },
    },
  });
  const questionsById = new Map(questions.map((question) => [question.id, question]));

  const results = normalizedAnswers.map((item) => {
    const question = questionsById.get(item.question_id);
    const isCorrect = question?.correct_answer === item.answer;

    return {
      question_id: item.question_id,
      submitted_answer: item.answer,
      correct_answer: question?.correct_answer ?? null,
      is_correct: Boolean(question && isCorrect),
      found: Boolean(question),
      topic_id: question?.topic_id ?? null,
      topic: question?.topic ?? null,
    };
  });

  await prisma.$transaction(
    results
      .filter((result) => result.found)
      .map((result) =>
        prisma.progress.create({
          data: {
            user_id: req.user.userId,
            question_id: result.question_id,
            submitted_answer: result.submitted_answer as AnswerOption,
            is_correct: result.is_correct,
          },
        }),
      ),
  );

  const total = results.length;
  const answered = results.filter((result) => result.found).length;
  const correct = results.filter((result) => result.is_correct).length;

  res.status(200).json({
    score: correct,
    total,
    answered,
    percentage: total === 0 ? 0 : Math.round((correct / total) * 100),
    results,
  });
});
