-- Phase 1: Add category column to courses table
ALTER TABLE courses
  ADD COLUMN IF NOT EXISTS category TEXT
  CHECK (category IN ('yoga', 'general_exercise'));
