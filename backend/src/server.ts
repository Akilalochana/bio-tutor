import cors from "cors";
import dotenv from "dotenv";
import express, { Request, Response } from "express";
import { prisma } from "./lib/prisma";

dotenv.config();

const app = express();
const port = process.env.PORT ?? 5000;

app.use(cors());
app.use(express.json());

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

app.listen(port, () => {
  console.log(`Bio Tutor backend is running on port ${port}`);
});
