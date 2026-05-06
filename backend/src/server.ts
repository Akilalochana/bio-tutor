import cors from "cors";
import express, { Request, Response } from "express";
import { env } from "./config/env";
import { prisma } from "./lib/prisma";
import { authRouter } from "./routes/auth.routes";
import { questionRouter } from "./routes/question.routes";

const app = express();

app.use(cors());
app.use(express.json());

app.use("/auth", authRouter);
app.use(questionRouter);

app.get("/health", (_req: Request, res: Response) => {
  res.status(200).json({
    status: "ok",
    service: "bio-tutor-backend",
  });
});

app.get("/health/db", async (_req: Request, res: Response) => {
  try {
    await prisma.$queryRaw`SELECT 1`;

    res.status(200).json({
      status: "ok",
      database: "connected",
    });
  } catch (error) {
    res.status(503).json({
      status: "error",
      database: "disconnected",
    });
  }
});

app.listen(env.port, () => {
  console.log(`Bio Tutor backend is running on port ${env.port}`);
});
