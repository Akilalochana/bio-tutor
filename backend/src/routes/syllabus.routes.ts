import { Router } from "express";
import { prisma } from "../lib/prisma";

type SyllabusChunk = {
  chunk_no: number;
  content: string;
};

type SearchResult = {
  unit_id: string;
  unit_no: number;
  title: string;
  chunk_no: number;
  content: string;
  score: number;
  matched_terms: string[];
};

const DEFAULT_SEARCH_LIMIT = 10;
const MAX_SEARCH_LIMIT = 25;

const searchSynonyms: Record<string, string[]> = {
  biology: ["biology", "biological", "ජීව", "ජීව විද්‍යාව"],
  cell: ["cell", "cells", "සෛල", "සෛලය"],
  dna: ["dna", "ඩීඑන්ඒ", "ඩිඑන්ඒ"],
  gene: ["gene", "genes", "ජානය", "ජාන"],
  genetics: ["genetics", "inheritance", "ජාන විද්‍යාව", "උරුමය"],
  evolution: ["evolution", "natural selection", "පරිණාමය", "ස්වාභාවික වරණය"],
  ecology: ["ecology", "ecosystem", "environment", "පරිසරය", "පරිසර පද්ධති"],
  producer: ["producer", "producers", "autotroph", "නිෂ්පාදක", "ස්වයංපෝෂක"],
  meiosis: ["meiosis", "මියෝසිය"],
  mitosis: ["mitosis", "මයිටොසිස", "මයිටෝසිස"],
  respiration: ["respiration", "ATP", "ශ්වසනය"],
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

const normalizeText = (text: string) =>
  text
    .normalize("NFKC")
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s]/gu, " ")
    .replace(/\s+/g, " ")
    .trim();

const buildExpandedTerms = (query: string) => {
  const normalizedQuery = normalizeText(query);
  const baseTerms = normalizedQuery.split(" ").filter(Boolean);
  const expandedTerms = new Set<string>(baseTerms);

  for (const term of baseTerms) {
    for (const [key, synonyms] of Object.entries(searchSynonyms)) {
      const normalizedKey = normalizeText(key);
      const normalizedSynonyms = synonyms.map((item) => normalizeText(item));

      if (term === normalizedKey || normalizedSynonyms.includes(term)) {
        expandedTerms.add(normalizedKey);

        for (const synonym of normalizedSynonyms) {
          expandedTerms.add(synonym);
        }
      }
    }
  }

  return {
    normalizedQuery,
    baseTerms,
    expandedTerms: [...expandedTerms],
  };
};

const countOccurrences = (text: string, term: string) => {
  if (!term) {
    return 0;
  }

  let count = 0;
  let startIndex = 0;

  while (true) {
    const matchIndex = text.indexOf(term, startIndex);

    if (matchIndex === -1) {
      break;
    }

    count += 1;
    startIndex = matchIndex + term.length;
  }

  return count;
};

const scoreMatch = (title: string, content: string, normalizedQuery: string, baseTerms: string[], expandedTerms: string[]) => {
  const normalizedTitle = normalizeText(title);
  const normalizedContent = normalizeText(content);
  const matchedTerms = new Set<string>();
  let score = 0;

  if (normalizedQuery.length > 0) {
    if (normalizedTitle.includes(normalizedQuery)) {
      score += 8;
    }

    if (normalizedContent.includes(normalizedQuery)) {
      score += 12;
    }
  }

  for (const term of expandedTerms) {
    const titleOccurrences = countOccurrences(normalizedTitle, term);
    const contentOccurrences = countOccurrences(normalizedContent, term);

    if (titleOccurrences > 0 || contentOccurrences > 0) {
      matchedTerms.add(term);
      score += titleOccurrences * 4;
      score += contentOccurrences * 2;
    }
  }

  const matchedBaseTerms = baseTerms.filter(
    (term) => normalizedTitle.includes(term) || normalizedContent.includes(term),
  );

  if (baseTerms.length > 1) {
    score += matchedBaseTerms.length * 3;

    if (matchedBaseTerms.length === baseTerms.length) {
      score += 10;
    }
  }

  return {
    score,
    matchedTerms: [...matchedTerms],
  };
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
  const rawLimit = req.query.limit;
  const limit =
    typeof rawLimit === "string" && rawLimit.trim() !== ""
      ? Number(rawLimit)
      : DEFAULT_SEARCH_LIMIT;

  if (!query) {
    res.status(400).json({
      message: "query is required.",
    });
    return;
  }

  if (!Number.isInteger(limit) || limit < 1 || limit > MAX_SEARCH_LIMIT) {
    res.status(400).json({
      message: `limit must be an integer between 1 and ${MAX_SEARCH_LIMIT}.`,
      default_limit: DEFAULT_SEARCH_LIMIT,
      max_limit: MAX_SEARCH_LIMIT,
    });
    return;
  }

  const { normalizedQuery, baseTerms, expandedTerms } = buildExpandedTerms(query);

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

  const matches: SearchResult[] = syllabusUnits
    .flatMap((unit) => {
      const chunks = normalizeChunks(unit.content_chunks);

      return chunks
        .map((chunk) => {
          const { score, matchedTerms } = scoreMatch(
            unit.title,
            chunk.content,
            normalizedQuery,
            baseTerms,
            expandedTerms,
          );

          if (score === 0) {
            return null;
          }

          return {
            unit_id: unit.id,
            unit_no: unit.unit_no,
            title: unit.title,
            chunk_no: chunk.chunk_no,
            content: chunk.content,
            score,
            matched_terms: matchedTerms,
          };
        })
        .filter((item): item is SearchResult => item !== null);
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
    normalized_query: normalizedQuery,
    limit,
    count: Math.min(matches.length, limit),
    total_matches: matches.length,
    results: matches.slice(0, limit),
  });
});
