import { NextFunction, Request, Response } from "express";
import { verifyAuthToken } from "../lib/jwt";

export const authGuard = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith("Bearer ")
    ? authHeader.slice("Bearer ".length)
    : undefined;

  if (!token) {
    res.status(401).json({ message: "Authentication token is required." });
    return;
  }

  try {
    req.user = verifyAuthToken(token);
    next();
  } catch (error) {
    res.status(401).json({ message: "Invalid or expired authentication token." });
  }
};
