import "dotenv/config";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../src/generated/prisma/client";
import { AnswerOption } from "../src/generated/prisma/enums";

const connectionString = process.env.DIRECT_URL ?? process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error("DIRECT_URL or DATABASE_URL must be set before running seed.");
}

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString }),
});

const main = async () => {
  const syllabus = await prisma.syllabus.upsert({
    where: { unit_no: 1 },
    update: {
      title: "Introduction to Biology",
      content_chunks: [
        {
          chunk_no: 1,
          content:
            "Biology is the scientific study of living organisms and life processes.",
        },
        {
          chunk_no: 2,
          content:
            "Cell theory explains that organisms are made of cells, cells are the basic unit of life, and new cells arise from existing cells.",
        },
      ],
    },
    create: {
      unit_no: 1,
      title: "Introduction to Biology",
      content_chunks: [
        {
          chunk_no: 1,
          content:
            "Biology is the scientific study of living organisms and life processes.",
        },
        {
          chunk_no: 2,
          content:
            "Cell theory explains that organisms are made of cells, cells are the basic unit of life, and new cells arise from existing cells.",
        },
      ],
    },
  });

  const questions = [
    {
      year: 2023,
      question_no: 1,
      text_si: "ජීව විද්‍යාව යන්නෙන් අදහස් වන්නේ කුමක්ද?",
      text_en: "What is meant by Biology?",
      options: [
        { key: "A", text_si: "ජීවීන් හා ජීව ක්‍රියාවලි පිළිබඳ අධ්‍යයනය", text_en: "Study of living organisms and life processes" },
        { key: "B", text_si: "පෘථිවියේ පාෂාණ පිළිබඳ අධ්‍යයනය", text_en: "Study of rocks of the Earth" },
        { key: "C", text_si: "රසායනික ද්‍රව්‍ය පමණක් පිළිබඳ අධ්‍යයනය", text_en: "Study of only chemical substances" },
        { key: "D", text_si: "ග්‍රහලෝක පිළිබඳ අධ්‍යයනය", text_en: "Study of planets" },
        { key: "E", text_si: "කාලගුණය පිළිබඳ අධ්‍යයනය", text_en: "Study of weather" },
      ],
      correct_answer: AnswerOption.A,
    },
    {
      year: 2023,
      question_no: 2,
      text_si: "සෛල సిద్ధාන්තයට අනුව ජීවයේ මූලික ඒකකය කුමක්ද?",
      text_en: "According to cell theory, what is the basic unit of life?",
      options: [
        { key: "A", text_si: "පරමාණුව", text_en: "Atom" },
        { key: "B", text_si: "සෛලය", text_en: "Cell" },
        { key: "C", text_si: "අවයවය", text_en: "Organ" },
        { key: "D", text_si: "පද්ධතිය", text_en: "System" },
        { key: "E", text_si: "පටකය", text_en: "Tissue" },
      ],
      correct_answer: AnswerOption.B,
    },
    {
      year: 2022,
      question_no: 1,
      text_si: "මයිටොසිස්හි ප්‍රධාන ප්‍රතිඵලය කුමක්ද?",
      text_en: "What is the main result of mitosis?",
      options: [
        { key: "A", text_si: "ගැමිට නිපදවීම", text_en: "Production of gametes" },
        { key: "B", text_si: "ජානමය වශයෙන් වෙනස් සෛල හතරක්", text_en: "Four genetically different cells" },
        { key: "C", text_si: "ජානමය වශයෙන් සමාන දියණි සෛල දෙකක්", text_en: "Two genetically identical daughter cells" },
        { key: "D", text_si: "ක්‍රෝමසෝම සංඛ්‍යාව අඩු වීම", text_en: "Reduction of chromosome number" },
        { key: "E", text_si: "DNA විනාශ වීම", text_en: "Destruction of DNA" },
      ],
      correct_answer: AnswerOption.C,
    },
  ];

  for (const question of questions) {
    await prisma.question.upsert({
      where: {
        year_question_no: {
          year: question.year,
          question_no: question.question_no,
        },
      },
      update: {
        text_si: question.text_si,
        text_en: question.text_en,
        options: question.options,
        correct_answer: question.correct_answer,
        topic_id: syllabus.id,
      },
      create: {
        ...question,
        topic_id: syllabus.id,
      },
    });
  }

  console.log(`Seeded syllabus unit ${syllabus.unit_no} and ${questions.length} questions.`);
};

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
