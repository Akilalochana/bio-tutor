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

type SeedOption = {
  key: "A" | "B" | "C" | "D" | "E";
  text_si: string;
  text_en: string;
};

type SeedQuestionTemplate = {
  question_no: number;
  unit_no: number;
  text_si: string;
  text_en: string;
  options: SeedOption[];
  correct_answer: AnswerOption;
};

const syllabusSeeds = [
  {
    unit_no: 1,
    title: "Introduction to Biology",
    content_chunks: [
      {
        chunk_no: 1,
        content: "Biology is the scientific study of living organisms and their life processes.",
      },
      {
        chunk_no: 2,
        content: "Scientific investigations in biology depend on observation, evidence, and repeatable testing.",
      },
    ],
  },
  {
    unit_no: 2,
    title: "Cell Biology",
    content_chunks: [
      {
        chunk_no: 1,
        content: "Cells are the basic structural and functional units of living organisms.",
      },
      {
        chunk_no: 2,
        content: "Organelles coordinate energy release, protein synthesis, transport, and storage inside the cell.",
      },
    ],
  },
  {
    unit_no: 3,
    title: "Genetics and Evolution",
    content_chunks: [
      {
        chunk_no: 1,
        content: "Inheritance is controlled by genes that are carried on chromosomes.",
      },
      {
        chunk_no: 2,
        content: "Evolution explains long-term biological change through variation and natural selection.",
      },
    ],
  },
  {
    unit_no: 4,
    title: "Ecology",
    content_chunks: [
      {
        chunk_no: 1,
        content: "Ecology studies interactions between living organisms and their environment.",
      },
      {
        chunk_no: 2,
        content: "Energy flow and nutrient cycling are key features of ecosystems.",
      },
    ],
  },
];

const questionTemplates: SeedQuestionTemplate[] = [
  {
    question_no: 1,
    unit_no: 1,
    text_si: "ජීව විද්‍යාව ලෙස හඳුන්වන්නේ කුමක්ද?",
    text_en: "What is meant by Biology?",
    options: [
      { key: "A", text_si: "ජීවීන් හා ජීව ක්‍රියාවලි පිළිබඳ අධ්‍යයනය", text_en: "Study of living organisms and life processes" },
      { key: "B", text_si: "පෘථිවි පාෂාණ පිළිබඳ අධ්‍යයනය", text_en: "Study of rocks of Earth" },
      { key: "C", text_si: "ග්‍රහලෝක පිළිබඳ අධ්‍යයනය", text_en: "Study of planets" },
      { key: "D", text_si: "කාලගුණය පිළිබඳ අධ්‍යයනය", text_en: "Study of weather" },
      { key: "E", text_si: "ශබ්ද තරංග පිළිබඳ අධ්‍යයනය", text_en: "Study of sound waves" },
    ],
    correct_answer: AnswerOption.A,
  },
  {
    question_no: 2,
    unit_no: 2,
    text_si: "සෛල සංකල්පය අනුව ජීවයේ මූලික ඒකකය කුමක්ද?",
    text_en: "According to cell theory, what is the basic unit of life?",
    options: [
      { key: "A", text_si: "පටකය", text_en: "Tissue" },
      { key: "B", text_si: "සෛලය", text_en: "Cell" },
      { key: "C", text_si: "අවයවය", text_en: "Organ" },
      { key: "D", text_si: "පද්ධතිය", text_en: "System" },
      { key: "E", text_si: "ජීවිය", text_en: "Organism" },
    ],
    correct_answer: AnswerOption.B,
  },
  {
    question_no: 3,
    unit_no: 2,
    text_si: "මයිටොකොන්ඩ්‍රියාවේ ප්‍රධාන කාර්යය කුමක්ද?",
    text_en: "What is the main function of mitochondria?",
    options: [
      { key: "A", text_si: "ප්‍රෝටීන සංස්ලේෂණය", text_en: "Protein synthesis" },
      { key: "B", text_si: "ATP නිපදවීම", text_en: "ATP production" },
      { key: "C", text_si: "ලවණ ගබඩා කිරීම", text_en: "Salt storage" },
      { key: "D", text_si: "වර්ණක සෑදීම", text_en: "Pigment formation" },
      { key: "E", text_si: "ක්‍රෝමොසෝම වෙන් කිරීම", text_en: "Chromosome separation" },
    ],
    correct_answer: AnswerOption.B,
  },
  {
    question_no: 4,
    unit_no: 2,
    text_si: "රයිබෝසෝමවල ප්‍රධාන කාර්යය කුමක්ද?",
    text_en: "What is the main function of ribosomes?",
    options: [
      { key: "A", text_si: "ප්‍රෝටීන සංස්ලේෂණය", text_en: "Protein synthesis" },
      { key: "B", text_si: "ලිපිඩ් සංස්ලේෂණය", text_en: "Lipid synthesis" },
      { key: "C", text_si: "ATP නිපදවීම", text_en: "ATP production" },
      { key: "D", text_si: "ජල ප්‍රවාහනය", text_en: "Water transport" },
      { key: "E", text_si: "DNA ගබඩා කිරීම", text_en: "DNA storage" },
    ],
    correct_answer: AnswerOption.A,
  },
  {
    question_no: 5,
    unit_no: 2,
    text_si: "DNA හි සීනි සංරචකය කුමක්ද?",
    text_en: "Which sugar is present in DNA?",
    options: [
      { key: "A", text_si: "ග්ලූකෝස්", text_en: "Glucose" },
      { key: "B", text_si: "ෆ්‍රක්ටෝස්", text_en: "Fructose" },
      { key: "C", text_si: "රයිබෝස්", text_en: "Ribose" },
      { key: "D", text_si: "ඩියොක්සිරයිබෝස්", text_en: "Deoxyribose" },
      { key: "E", text_si: "සුක්‍රෝස්", text_en: "Sucrose" },
    ],
    correct_answer: AnswerOption.D,
  },
  {
    question_no: 6,
    unit_no: 2,
    text_si: "ඔස්මෝසිය සිදු වන්නේ කුමන පටලයක් හරහාද?",
    text_en: "Osmosis occurs through which type of membrane?",
    options: [
      { key: "A", text_si: "සම්පූර්ණයෙන් විනිවිද නොයන පටලයක්", text_en: "Completely impermeable membrane" },
      { key: "B", text_si: "අර්ධ පාරගම්‍ය පටලයක්", text_en: "Partially permeable membrane" },
      { key: "C", text_si: "ලෝහ පටලයක්", text_en: "Metal membrane" },
      { key: "D", text_si: "ඝන සෙලියුලෝස් පටලයක් පමණක්", text_en: "Only a thick cellulose membrane" },
      { key: "E", text_si: "ප්‍රෝටීන රහිත පටලයක්", text_en: "A membrane without proteins" },
    ],
    correct_answer: AnswerOption.B,
  },
  {
    question_no: 7,
    unit_no: 2,
    text_si: "මයිටොසිසයෙන් අවසානයේ ලැබෙන්නේ කුමක්ද?",
    text_en: "What is produced at the end of mitosis?",
    options: [
      { key: "A", text_si: "ජානමය වශයෙන් සමාන දියණි සෛල දෙකක්", text_en: "Two genetically identical daughter cells" },
      { key: "B", text_si: "ජානමය වශයෙන් වෙනස් සෛල හතරක්", text_en: "Four genetically different cells" },
      { key: "C", text_si: "ගැමීට දෙකක්", text_en: "Two gametes" },
      { key: "D", text_si: "ක්‍රෝමොසෝම රහිත සෛල", text_en: "Cells without chromosomes" },
      { key: "E", text_si: "නියුක්ලියස් රහිත සෛල", text_en: "Cells without nuclei" },
    ],
    correct_answer: AnswerOption.A,
  },
  {
    question_no: 8,
    unit_no: 3,
    text_si: "මෙන්ඩල්ගේ වෙන්වීමේ නියමය අනුව ගැමීටයකට යන්නේ කුමක්ද?",
    text_en: "According to Mendel's law of segregation, what enters one gamete?",
    options: [
      { key: "A", text_si: "එක ජානයක ඇලීල දෙකම", text_en: "Both alleles of one gene" },
      { key: "B", text_si: "එක ජානයක එක් ඇලීලයක් පමණි", text_en: "Only one allele of a gene" },
      { key: "C", text_si: "ක්‍රෝමොසෝම කිසිවක් නැත", text_en: "No chromosomes" },
      { key: "D", text_si: "අමතර DNA", text_en: "Extra DNA" },
      { key: "E", text_si: "ප්ලාස්මිඩ් පමණි", text_en: "Plasmids only" },
    ],
    correct_answer: AnswerOption.B,
  },
  {
    question_no: 9,
    unit_no: 3,
    text_si: "මියෝසියේ වැදගත්කම කුමක්ද?",
    text_en: "What is the importance of meiosis?",
    options: [
      { key: "A", text_si: "ශරීර සෛල සංඛ්‍යාව වැඩි කිරීම", text_en: "Increasing body cell number" },
      { key: "B", text_si: "ගැමීට නිපදවීම සහ ක්‍රෝමොසෝම සංඛ්‍යාව අඩු කිරීම", text_en: "Producing gametes and reducing chromosome number" },
      { key: "C", text_si: "ආහාර නිෂ්පාදනය", text_en: "Food production" },
      { key: "D", text_si: "ශ්වසනය නතර කිරීම", text_en: "Stopping respiration" },
      { key: "E", text_si: "පටක මරණය", text_en: "Tissue death" },
    ],
    correct_answer: AnswerOption.B,
  },
  {
    question_no: 10,
    unit_no: 3,
    text_si: "ස්වාභාවික වරණය පිළිබඳ නිවැරදි ප්‍රකාශය කුමක්ද?",
    text_en: "Which statement about natural selection is correct?",
    options: [
      { key: "A", text_si: "සියලු ජීවීන් සමාන ලෙස දිවි ගලවයි", text_en: "All organisms survive equally" },
      { key: "B", text_si: "අනුවර්තනයට උපකාරී ලක්ෂණ ඇති ජීවීන්ට වාසියක් ලැබේ", text_en: "Organisms with advantageous traits are more likely to survive and reproduce" },
      { key: "C", text_si: "ස්වාභාවික වරණය DNA විනාශ කරයි", text_en: "Natural selection destroys DNA" },
      { key: "D", text_si: "එය සිදුවන්නේ එක් පරම්පරාවක් තුළ පමණි", text_en: "It happens only within one generation" },
      { key: "E", text_si: "එය ප්‍රභේදතාවය අඩු නොකරයි හෝ වැඩි නොකරයි", text_en: "It never affects variation" },
    ],
    correct_answer: AnswerOption.B,
  },
  {
    question_no: 11,
    unit_no: 3,
    text_si: "හෝමොසයිගස් ප්‍රබල ජානුක ප්‍රතිරූපයක් කුමක්ද?",
    text_en: "Which is a homozygous dominant genotype?",
    options: [
      { key: "A", text_si: "Aa", text_en: "Aa" },
      { key: "B", text_si: "aa", text_en: "aa" },
      { key: "C", text_si: "AA", text_en: "AA" },
      { key: "D", text_si: "A0", text_en: "A0" },
      { key: "E", text_si: "ab", text_en: "ab" },
    ],
    correct_answer: AnswerOption.C,
  },
  {
    question_no: 12,
    unit_no: 3,
    text_si: "DNA ප්‍රතිලේඛනය ප්‍රධාන වශයෙන් සිදු වන්නේ කවදාද?",
    text_en: "DNA replication mainly occurs during which stage of the cell cycle?",
    options: [
      { key: "A", text_si: "G1 අවස්ථාව", text_en: "G1 phase" },
      { key: "B", text_si: "S අවස්ථාව", text_en: "S phase" },
      { key: "C", text_si: "G2 අවස්ථාව", text_en: "G2 phase" },
      { key: "D", text_si: "M අවස්ථාව", text_en: "M phase" },
      { key: "E", text_si: "Cytokinesis", text_en: "Cytokinesis" },
    ],
    correct_answer: AnswerOption.B,
  },
  {
    question_no: 13,
    unit_no: 4,
    text_si: "පරිසර පද්ධතියක නිෂ්පාදකයන් කවුරුන්ද?",
    text_en: "Who are the producers in an ecosystem?",
    options: [
      { key: "A", text_si: "මාංසභක්ෂකයින්", text_en: "Carnivores" },
      { key: "B", text_si: "වියෝජකයින්", text_en: "Decomposers" },
      { key: "C", text_si: "ස්වයංපෝෂක ජීවීන්", text_en: "Autotrophic organisms" },
      { key: "D", text_si: "පරාජීවීන්", text_en: "Parasites" },
      { key: "E", text_si: "සර්වභක්ෂකයින්", text_en: "Omnivores" },
    ],
    correct_answer: AnswerOption.C,
  },
  {
    question_no: 14,
    unit_no: 4,
    text_si: "ආහාර ශෘංඛලාවේදී එක් පෝෂක මට්ටමකින් ඊළඟට මාරුවන ශක්තිය සාමාන්‍යයෙන්",
    text_en: "In a food chain, the energy transferred from one trophic level to the next is usually",
    options: [
      { key: "A", text_si: "සම්පූර්ණයෙන්ම 100%", text_en: "100%" },
      { key: "B", text_si: "ඉතා සුළු ප්‍රමාණයක් පමණි", text_en: "Only a small fraction" },
      { key: "C", text_si: "සෑම විටම වැඩිවේ", text_en: "Always increases" },
      { key: "D", text_si: "ශුන්‍ය වේ", text_en: "Zero" },
      { key: "E", text_si: "අසීමිත වේ", text_en: "Unlimited" },
    ],
    correct_answer: AnswerOption.B,
  },
  {
    question_no: 15,
    unit_no: 4,
    text_si: "වියෝජකයන්ගේ ප්‍රධාන භූමිකාව කුමක්ද?",
    text_en: "What is the main role of decomposers?",
    options: [
      { key: "A", text_si: "ආලෝකය ශක්තියට පරිවර්තනය කිරීම", text_en: "Converting light into energy" },
      { key: "B", text_si: "ජීව ද්‍රව්‍ය බිඳ දමා පෝෂක නැවත පරිසරයට ලබා දීම", text_en: "Breaking down dead matter and returning nutrients to the environment" },
      { key: "C", text_si: "ක්‍රෝමොසෝම ගණන වැඩි කිරීම", text_en: "Increasing chromosome number" },
      { key: "D", text_si: "වලසුන් දඩයම් කිරීම", text_en: "Hunting predators" },
      { key: "E", text_si: "ඔක්සිජන් පරිභෝජනය නතර කිරීම", text_en: "Stopping oxygen consumption" },
    ],
    correct_answer: AnswerOption.B,
  },
  {
    question_no: 16,
    unit_no: 4,
    text_si: "ජල දූෂණය නිසා ඉතා ඉක්මනින් බලපෑම් දක්නට ලැබිය හැකි කණ්ඩායම කුමක්ද?",
    text_en: "Which group is often quickly affected by water pollution?",
    options: [
      { key: "A", text_si: "ජලජ ජීවීන්", text_en: "Aquatic organisms" },
      { key: "B", text_si: "අභ්‍යවකාශ ජීවීන්", text_en: "Space organisms" },
      { key: "C", text_si: "කාන්තාර පඳුරු පමණි", text_en: "Only desert shrubs" },
      { key: "D", text_si: "ගිරි මුදුන් බූමිකා පමණි", text_en: "Only mountain peaks" },
      { key: "E", text_si: "අජීවී සාධක නොවේ", text_en: "Not living groups" },
    ],
    correct_answer: AnswerOption.A,
  },
  {
    question_no: 17,
    unit_no: 1,
    text_si: "ජීව විද්‍යාත්මක අධ්‍යයනයකදී උපකල්පනයක් යනු කුමක්ද?",
    text_en: "In a biological investigation, what is a hypothesis?",
    options: [
      { key: "A", text_si: "පරීක්ෂා කළ නොහැකි මතයක්", text_en: "An untestable idea" },
      { key: "B", text_si: "පරීක්ෂා කළ හැකි තාවකාලික විස්තරයක්", text_en: "A testable tentative explanation" },
      { key: "C", text_si: "අවසන් නිගමනය", text_en: "The final conclusion" },
      { key: "D", text_si: "අනවශ්‍ය දත්ත", text_en: "Irrelevant data" },
      { key: "E", text_si: "පොත් නාම ලැයිස්තුව", text_en: "A bibliography" },
    ],
    correct_answer: AnswerOption.B,
  },
  {
    question_no: 18,
    unit_no: 1,
    text_si: "ජීවීන්ට පොදු ලක්ෂණයක් නොවන්නේ කුමක්ද?",
    text_en: "Which is not a universal characteristic of living organisms?",
    options: [
      { key: "A", text_si: "වර්ධනය", text_en: "Growth" },
      { key: "B", text_si: "ප්‍රජනනය", text_en: "Reproduction" },
      { key: "C", text_si: "පරිවෘත්තීය", text_en: "Metabolism" },
      { key: "D", text_si: "පෝෂණය", text_en: "Nutrition" },
      { key: "E", text_si: "සෑම විටම ගමන් කිරීම", text_en: "Always moving from place to place" },
    ],
    correct_answer: AnswerOption.E,
  },
  {
    question_no: 19,
    unit_no: 2,
    text_si: "ශාක සෛලයකට සත්ව සෛලයකට සාපේක්ෂව විශේෂිත ලක්ෂණයක් කුමක්ද?",
    text_en: "Which feature is characteristic of plant cells compared with animal cells?",
    options: [
      { key: "A", text_si: "සෛල පටලය", text_en: "Cell membrane" },
      { key: "B", text_si: "සයිටෝප්ලාස්මය", text_en: "Cytoplasm" },
      { key: "C", text_si: "නියුක්ලියස්", text_en: "Nucleus" },
      { key: "D", text_si: "සෛල බිත්තිය", text_en: "Cell wall" },
      { key: "E", text_si: "රයිබෝසෝම", text_en: "Ribosome" },
    ],
    correct_answer: AnswerOption.D,
  },
  {
    question_no: 20,
    unit_no: 4,
    text_si: "ජෛව විවිධත්ව සංරක්ෂණයේ වැදගත්කමක් කුමක්ද?",
    text_en: "Why is biodiversity conservation important?",
    options: [
      { key: "A", text_si: "පරිසර පද්ධති ස්ථාවරතාවයට උපකාරී වීම", text_en: "It supports ecosystem stability" },
      { key: "B", text_si: "සියලුම ප්‍රභේද එකම ලෙස වෙනස් කිරීම", text_en: "It makes all species identical" },
      { key: "C", text_si: "අලුත් රෝග සෑදීම", text_en: "It creates new diseases" },
      { key: "D", text_si: "ප්‍රභේදනාශය වේගවත් කිරීම", text_en: "It speeds extinction" },
      { key: "E", text_si: "ජලය අතුරුදන් කිරීම", text_en: "It removes water" },
    ],
    correct_answer: AnswerOption.A,
  },
];

const startYear = 2006;
const endYear = 2025;

const main = async () => {
  const syllabusByUnit = new Map<number, string>();

  for (const syllabusSeed of syllabusSeeds) {
    const syllabus = await prisma.syllabus.upsert({
      where: { unit_no: syllabusSeed.unit_no },
      update: {
        title: syllabusSeed.title,
        content_chunks: syllabusSeed.content_chunks,
      },
      create: syllabusSeed,
      select: {
        id: true,
        unit_no: true,
      },
    });

    syllabusByUnit.set(syllabus.unit_no, syllabus.id);
  }

  let totalSeededQuestions = 0;

  for (let year = startYear; year <= endYear; year += 1) {
    for (const question of questionTemplates) {
      const topicId = syllabusByUnit.get(question.unit_no);

      if (!topicId) {
        throw new Error(`Syllabus unit ${question.unit_no} was not found while seeding questions.`);
      }

      await prisma.question.upsert({
        where: {
          year_question_no: {
            year,
            question_no: question.question_no,
          },
        },
        update: {
          text_si: question.text_si,
          text_en: question.text_en,
          options: question.options,
          correct_answer: question.correct_answer,
          topic_id: topicId,
        },
        create: {
          year,
          question_no: question.question_no,
          text_si: question.text_si,
          text_en: question.text_en,
          options: question.options,
          correct_answer: question.correct_answer,
          topic_id: topicId,
        },
      });

      totalSeededQuestions += 1;
    }
  }

  console.log(
    `Seeded ${syllabusSeeds.length} syllabus units and ${totalSeededQuestions} questions for years ${startYear}-${endYear}.`,
  );
};

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
