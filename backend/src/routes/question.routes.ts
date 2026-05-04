import { Router } from "express";
import { prisma } from "../lib/prisma";
import { authGuard } from "../middleware/authGuard";

const answerOptions = new Set(["A", "B", "C", "D", "E"]);
const PAPER_YEAR_LIMIT = 20;

type SubmittedAnswer = {
  question_id?: string;
  answer?: string;
};

export const questionRouter = Router();

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
    select: {
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
    },
  });

  res.status(200).json({ year, count: questions.length, questions });
});

questionRouter.get("/questions/:id", async (req, res) => {
  const question = await prisma.question.findUnique({
    where: { id: req.params.id },
    select: {
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
    },
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
    };
  });

  await prisma.$transaction(
    results
      .filter((result) => result.found)
      .map((result) =>
        prisma.progress.upsert({
          where: {
            user_id_question_id: {
              user_id: req.user.userId,
              question_id: result.question_id,
            },
          },
          update: {
            is_correct: result.is_correct,
          },
          create: {
            user_id: req.user.userId,
            question_id: result.question_id,
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
