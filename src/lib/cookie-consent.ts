"use client";

import { useSyncExternalStore } from "react";

export interface CookieConsent {
  necessary: true;
  analytics: boolean;
  marketing: boolean;
  updatedAt: string;
}

const STORAGE_KEY = "krueger-cookie-consent";

let cachedRaw: string | null = null;
let cachedValue: CookieConsent | null = null;

// Returns a stable object reference when the underlying storage value hasn't
// changed, which useSyncExternalStore requires to avoid re-render loops.
export function readConsent(): CookieConsent | null {
  if (typeof window === "undefined") return null;
  let raw: string | null;
  try {
    raw = window.localStorage.getItem(STORAGE_KEY);
  } catch {
    raw = null;
  }
  if (raw === cachedRaw) return cachedValue;
  cachedRaw = raw;
  try {
    cachedValue = raw ? (JSON.parse(raw) as CookieConsent) : null;
  } catch {
    cachedValue = null;
  }
  return cachedValue;
}

export function writeConsent(consent: Omit<CookieConsent, "necessary" | "updatedAt">) {
  const value: CookieConsent = {
    necessary: true,
    analytics: consent.analytics,
    marketing: consent.marketing,
    updatedAt: new Date().toISOString(),
  };
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(value));
  window.dispatchEvent(new Event("cookie-consent-changed"));
  return value;
}

function subscribeConsent(callback: () => void) {
  window.addEventListener("storage", callback);
  window.addEventListener("cookie-consent-changed", callback);
  return () => {
    window.removeEventListener("storage", callback);
    window.removeEventListener("cookie-consent-changed", callback);
  };
}

const getServerConsentSnapshot = () => null;

export function useCookieConsent() {
  return useSyncExternalStore(
    subscribeConsent,
    readConsent,
    getServerConsentSnapshot,
  );
}
