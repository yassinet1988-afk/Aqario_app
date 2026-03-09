// ============================================================
//  lib/duplicate-detection.ts
//  Aqario – Duplicate Detection Engine (Full Implementation)
// ============================================================

import { supabaseServer } from './supabase'

// ── Types ─────────────────────────────────────────────────────
export interface NewPropertyInput {
  city_id:      number
  type_id:      number
  operation:    'sale' | 'rent' | 'both'
  title_ar:     string
  description_ar?: string
  latitude?:    number
  longitude?:   number
  price:        number
  area_total?:  number
  bedrooms?:    number
  bathrooms?:   number
  floor?:       number
  image_hashes?: string[]   // pHash strings from uploaded images
}

export interface DuplicateResult {
  isDuplicate:       boolean   // score ≥ 80 → auto-reject
  needsReview:       boolean   // score 50–79 → human review
  score:             number    // 0–100
  breakdown: {
    image:  number
    geo:    number
    text:   number
    specs:  number
  }
  matchedPropertyId?: string
  matchedRefCode?:    string
}

interface Candidate {
  id:            string
  ref_code:      string
  title_ar:      string
  description_ar?: string
  price:         number
  area_total?:   number
  bedrooms?:     number
  bathrooms?:    number
  floor?:        number
  latitude?:     number
  longitude?:    number
  image_hash?:   string[]
}

// ── Weights & Thresholds ──────────────────────────────────────
const W = { image: 0.40, geo: 0.30, text: 0.20, specs: 0.10 }

const THRESHOLD = {
  AUTO_REJECT:  80,
  HUMAN_REVIEW: 50,
}

// ─────────────────────────────────────────────────────────────
//  MAIN FUNCTION
// ─────────────────────────────────────────────────────────────
export async function checkDuplicate(
  input: NewPropertyInput
): Promise<DuplicateResult> {

  // Step 1: Pull candidate properties from DB
  const candidates = await fetchCandidates(input)

  if (!candidates.length) return makeClean()

  let best: DuplicateResult = makeClean()

  for (const c of candidates) {
    const imageScore = scoreImages(input.image_hashes ?? [], c.image_hash ?? [])
    const geoScore   = scoreGeo(input.latitude, input.longitude, c.latitude, c.longitude)
    const textScore  = scoreText(input.title_ar, input.description_ar, c.title_ar, c.description_ar)
    const specsScore = scoreSpecs(input, c)

    const total = Math.round(
      imageScore  * W.image +
      geoScore    * W.geo   +
      textScore   * W.text  +
      specsScore  * W.specs
    )

    if (total > best.score) {
      best = {
        isDuplicate:       total >= THRESHOLD.AUTO_REJECT,
        needsReview:       total >= THRESHOLD.HUMAN_REVIEW && total < THRESHOLD.AUTO_REJECT,
        score:             total,
        breakdown:         { image: imageScore, geo: geoScore, text: textScore, specs: specsScore },
        matchedPropertyId: c.id,
        matchedRefCode:    c.ref_code,
      }
    }
  }

  return best
}

// ─────────────────────────────────────────────────────────────
//  LAYER 1 — IMAGE HASHING  (weight: 40%)
//  Uses perceptual hash (pHash) stored as hex strings.
//  Hamming distance ≤ 8 bits out of 64 = very similar image.
// ─────────────────────────────────────────────────────────────
export function scoreImages(newHashes: string[], existingHashes: string[]): number {
  if (!newHashes.length || !existingHashes.length) return 0

  let maxSimilarity = 0

  for (const h1 of newHashes) {
    for (const h2 of existingHashes) {
      const dist = hammingDistance(h1, h2)      // 0–64
      const sim  = (1 - dist / 64) * 100        // 0–100
      if (sim > maxSimilarity) maxSimilarity = sim
    }
  }

  return Math.round(maxSimilarity)
}

// Hamming distance between two hex-encoded 64-bit hashes
function hammingDistance(hex1: string, hex2: string): number {
  const b1 = BigInt('0x' + hex1)
  const b2 = BigInt('0x' + hex2)
  let xor = b1 ^ b2
  let dist = 0
  while (xor > 0n) {
    dist += Number(xor & 1n)
    xor >>= 1n
  }
  return dist
}

// ─────────────────────────────────────────────────────────────
//  LAYER 2 — GEO PROXIMITY  (weight: 30%)
//  PostGIS handles the heavy lifting; we score the distance.
// ─────────────────────────────────────────────────────────────
export function scoreGeo(
  lat1?: number, lng1?: number,
  lat2?: number, lng2?: number
): number {
  if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) return 0

  const dist = haversineMeters(lat1, lng1, lat2, lng2)

  if (dist <  50)  return 100   // same building
  if (dist < 100)  return 85    // same block
  if (dist < 200)  return 60    // same street
  if (dist < 500)  return 30    // same neighbourhood
  return 0
}

function haversineMeters(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R  = 6_371_000
  const φ1 = (lat1 * Math.PI) / 180
  const φ2 = (lat2 * Math.PI) / 180
  const Δφ = ((lat2 - lat1) * Math.PI) / 180
  const Δλ = ((lng2 - lng1) * Math.PI) / 180
  const a  = Math.sin(Δφ / 2) ** 2 + Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) ** 2
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
}

// ─────────────────────────────────────────────────────────────
//  LAYER 3 — TEXT SIMILARITY  (weight: 20%)
//  TF-IDF vectorisation + cosine similarity on Arabic text.
//  Includes Arabic normalisation (hamza, tatweel, diacritics).
// ─────────────────────────────────────────────────────────────
export function scoreText(
  title1: string, desc1 = '',
  title2: string, desc2 = ''
): number {
  // Title gets 2× weight in the combined string
  const t1 = normalizeArabic(`${title1} ${title1} ${desc1}`)
  const t2 = normalizeArabic(`${title2} ${title2} ${desc2}`)

  const vec1 = tfidfVector(t1)
  const vec2 = tfidfVector(t2)

  return Math.round(cosine(vec1, vec2) * 100)
}

// Arabic text normalisation
function normalizeArabic(text: string): string {
  return text
    .replace(/[أإآا]/g, 'ا')       // normalise hamza
    .replace(/ة/g, 'ه')             // ta marbuta → ha
    .replace(/ى/g, 'ي')             // alef maqsura → ya
    .replace(/[\u064B-\u065F]/g, '') // strip diacritics
    .replace(/ـ/g, '')              // strip tatweel
    .replace(/[^\u0620-\u064A\s]/g, '')
    .toLowerCase()
    .trim()
}

// Simple TF-IDF vector (token → frequency map, normalised)
function tfidfVector(text: string): Map<string, number> {
  const STOP_WORDS = new Set([
    'في','من','على','إلى','مع','عن','هذا','هذه','التي','الذي',
    'وفي','ومن','أو','و','ب','لل','ال','هو','هي','كان','يكون',
  ])

  const tokens = text.split(/\s+/).filter(t => t.length > 1 && !STOP_WORDS.has(t))
  const freq   = new Map<string, number>()
  for (const t of tokens) freq.set(t, (freq.get(t) ?? 0) + 1)

  // TF normalisation
  const total = tokens.length || 1
  freq.forEach((v, k) => freq.set(k, v / total))
  return freq
}

// Cosine similarity between two TF vectors
function cosine(a: Map<string, number>, b: Map<string, number>): number {
  let dot = 0, normA = 0, normB = 0
  a.forEach((v, k) => { dot += v * (b.get(k) ?? 0); normA += v * v })
  b.forEach(v => { normB += v * v })
  const denom = Math.sqrt(normA) * Math.sqrt(normB)
  return denom === 0 ? 0 : dot / denom
}

// ─────────────────────────────────────────────────────────────
//  LAYER 4 — SPECS MATCHING  (weight: 10%)
//  Price ±5%, area ±10%, same rooms / floor = match
// ─────────────────────────────────────────────────────────────
export function scoreSpecs(a: NewPropertyInput, b: Candidate): number {
  type Check = { got: boolean; weight: number }
  const checks: Check[] = []

  const pctNear = (v1: number, v2: number, pct: number) =>
    Math.abs(v1 - v2) / Math.max(v1, v2) <= pct

  if (a.price      && b.price)      checks.push({ got: pctNear(a.price, b.price, 0.05), weight: 3 })
  if (a.area_total && b.area_total) checks.push({ got: pctNear(a.area_total, b.area_total, 0.10), weight: 2 })
  if (a.bedrooms   && b.bedrooms)   checks.push({ got: a.bedrooms  === b.bedrooms,  weight: 2 })
  if (a.bathrooms  && b.bathrooms)  checks.push({ got: a.bathrooms === b.bathrooms, weight: 1 })
  if (a.floor      && b.floor)      checks.push({ got: a.floor     === b.floor,     weight: 1 })

  if (!checks.length) return 0

  const totalWeight = checks.reduce((s, c) => s + c.weight, 0)
  const hitWeight   = checks.filter(c => c.got).reduce((s, c) => s + c.weight, 0)

  return Math.round((hitWeight / totalWeight) * 100)
}

// ─────────────────────────────────────────────────────────────
//  DB QUERY — fetch nearby candidates via PostGIS
// ─────────────────────────────────────────────────────────────
async function fetchCandidates(input: NewPropertyInput): Promise<Candidate[]> {
  const { data, error } = await supabaseServer.rpc('get_duplicate_candidates', {
    p_city_id:   input.city_id,
    p_type_id:   input.type_id,
    p_operation: input.operation,
    p_lat:       input.latitude  ?? null,
    p_lng:       input.longitude ?? null,
    p_radius_m:  500,
    p_limit:     50,
  })

  if (error) {
    console.error('[duplicate] fetchCandidates error', error)
    return []
  }
  return (data ?? []) as Candidate[]
}

// ─────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────
function makeClean(): DuplicateResult {
  return {
    isDuplicate: false,
    needsReview: false,
    score:       0,
    breakdown:   { image: 0, geo: 0, text: 0, specs: 0 },
  }
}

// ─────────────────────────────────────────────────────────────
//  SAVE RESULT TO DB
// ─────────────────────────────────────────────────────────────
export async function saveDuplicateReport(
  propertyId:   string,
  result:       DuplicateResult,
  reporterId?:  string
) {
  if (!result.isDuplicate && !result.needsReview) return

  await supabaseServer.from('duplicate_reports').insert({
    property_id:     propertyId,
    duplicate_of_id: result.matchedPropertyId,
    reporter_id:     reporterId ?? null,
    reason:          `Auto-detected. Score: ${result.score}/100`,
    status:          result.isDuplicate ? 'confirmed' : 'pending',
  })
}
