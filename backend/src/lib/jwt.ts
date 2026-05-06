import jwt, { SignOptions } from "jsonwebtoken";
import { env } from "../config/env";

export type JwtPayload = {
  userId: string;
  email: string;
};

export const signAuthToken = (payload: JwtPayload): string => {
  const options: SignOptions = {
    expiresIn: env.jwtExpiresIn as SignOptions["expiresIn"],
  };

  return jwt.sign(payload, env.jwtSecret, options);
};

export const verifyAuthToken = (token: string): JwtPayload => {
  return jwt.verify(token, env.jwtSecret) as JwtPayload;
};
