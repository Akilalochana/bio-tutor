import bcrypt from "bcrypt";
import { Router } from "express";
import { authGuard } from "../middleware/authGuard";
import { signAuthToken } from "../lib/jwt";
import { prisma } from "../lib/prisma";

const SALT_ROUNDS = 12;

export const authRouter = Router();

authRouter.post("/signup", async (req, res) => {
  const { name, email, password } = req.body as {
    name?: string;
    email?: string;
    password?: string;
  };

  if (!name || !email || !password) {
    res.status(400).json({ message: "Name, email, and password are required." });
    return;
  }

  if (password.length < 8) {
    res.status(400).json({ message: "Password must be at least 8 characters." });
    return;
  }

  const normalizedEmail = email.trim().toLowerCase();
  const existingUser = await prisma.user.findUnique({
    where: { email: normalizedEmail },
  });

  if (existingUser) {
    res.status(409).json({ message: "Email is already registered." });
    return;
  }

  const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);
  const user = await prisma.user.create({
    data: {
      name: name.trim(),
      email: normalizedEmail,
      password: hashedPassword,
    },
    select: {
      id: true,
      name: true,
      email: true,
      created_at: true,
    },
  });

  const token = signAuthToken({ userId: user.id, email: user.email });

  res.status(201).json({ user, token });
});

authRouter.post("/login", async (req, res) => {
  const { email, password } = req.body as {
    email?: string;
    password?: string;
  };

  if (!email || !password) {
    res.status(400).json({ message: "Email and password are required." });
    return;
  }

  const normalizedEmail = email.trim().toLowerCase();
  const user = await prisma.user.findUnique({
    where: { email: normalizedEmail },
  });

  if (!user) {
    res.status(401).json({ message: "Invalid email or password." });
    return;
  }

  const passwordMatches = await bcrypt.compare(password, user.password);

  if (!passwordMatches) {
    res.status(401).json({ message: "Invalid email or password." });
    return;
  }

  const token = signAuthToken({ userId: user.id, email: user.email });

  res.status(200).json({
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      created_at: user.created_at,
    },
    token,
  });
});

authRouter.get("/me", authGuard, async (req, res) => {
  const user = await prisma.user.findUnique({
    where: { id: req.user.userId },
    select: {
      id: true,
      name: true,
      email: true,
      created_at: true,
      updated_at: true,
    },
  });

  if (!user) {
    res.status(404).json({ message: "User not found." });
    return;
  }

  res.status(200).json({ user });
});
