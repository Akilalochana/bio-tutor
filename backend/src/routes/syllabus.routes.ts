import { Router } from "express";
import { prisma } from "../lib/prisma";

type SyllabusChunk = {
  chunk_no: number;
  content: string;
};

const normalizeChunks = (value: unknown): SyllabusChunk[] => {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((item) => {
      if (
        typeof item === "object" &&
        item !== null &&
        "chunk_no" in item &&
        "content" in item &&
        typeof item.chunk_no === "number" &&
        typeof item.content === "string"
      ) {
        return {
          chunk_no: item.chunk_no,
          content: item.content,
        };
      }

      return null;
    })
    .filter((item): item is SyllabusChunk => item !== null);
};

const countMatches = (text: string, terms: string[]) => {
  const normalizedText = text.toLowerCase();

  return terms.reduce((score, term) => {
    if (normalizedText.includes(term)) {
      return score + 1;
    }

    return score;
  }, 0);
};

export const syllabusRouter = Router();

syllabusRouter.get("/syllabus/:unit(\\d+)", async (req, res) => {
  const unit = Number(req.params.unit);

  const syllabus = await prisma.syllabus.findUnique({
    where: { unit_no: unit },
    select: {
      id: true,
      unit_no: true,
      title: true,
      content_chunks: true,
    },
  });

  if (!syllabus) {
    res.status(404).json({ message: "Syllabus unit not found." });
    return;
  }

  const contentChunks = normalizeChunks(syllabus.content_chunks);

  res.status(200).json({
    unit: {
      id: syllabus.id,
      unit_no: syllabus.unit_no,
      title: syllabus.title,
      content_chunks: contentChunks,
    },
  });
});

syllabusRouter.get("/syllabus/search", async (req, res) => {
  const rawQuery = req.query.query;
  const query = typeof rawQuery === "string" ? rawQuery.trim() : "";

  if (!query) {
    res.status(400).json({
      message: "query is required.",
    });
    return;
  }

  const searchTerms = query
    .toLowerCase()
    .split(/\s+/)
    .map((term) => term.trim())
    .filter(Boolean);

  const syllabusUnits = await prisma.syllabus.findMany({
    select: {
      id: true,
      unit_no: true,
      title: true,
      content_chunks: true,
    },
    orderBy: {
      unit_no: "asc",
    },
  });

  const matches = syllabusUnits
    .flatMap((unit) => {
      const titleScore = countMatches(unit.title, searchTerms);
      const chunks = normalizeChunks(unit.content_chunks);

      return chunks
        .map((chunk) => {
          const chunkScore = countMatches(chunk.content, searchTerms);
          const totalScore = titleScore + chunkScore;

          if (totalScore === 0) {
            return null;
          }

          return {
            unit_id: unit.id,
            unit_no: unit.unit_no,
            title: unit.title,
            chunk_no: chunk.chunk_no,
            content: chunk.content,
            score: totalScore,
          };
        })
        .filter(
          (
            item,
          ): item is {
            unit_id: string;
            unit_no: number;
            title: string;
            chunk_no: number;
            content: string;
            score: number;
          } => item !== null,
        );
    })
    .sort((a, b) => {
      if (b.score !== a.score) {
        return b.score - a.score;
      }

      if (a.unit_no !== b.unit_no) {
        return a.unit_no - b.unit_no;
      }

      return a.chunk_no - b.chunk_no;
    });

  res.status(200).json({
    query,
    count: matches.length,
    results: matches,
  });
});
