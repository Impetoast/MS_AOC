# MS_AOC

Solutions for the Mainframe Society's Advent of Code.

This repo collects my solutions and experiments around Advent of Code with a focus on **mainframe-related tooling** and a mix of **classic** and **modern** approaches.

---

## Goals

This is **not** a “perfect solutions only” repository.

The idea is to:

- show how Advent of Code style problems can be solved on the **mainframe**,
- use a mix of tools over the course of the event (REXX, JCL, COBOL, Python, ...),
- switch technologies **between days**, not collect every possible variant for each single puzzle,
- keep the code readable enough to be used as **learning material**.

So the focus won’t always be on the single most optimal solution,
but on **illustrating different approaches and trade-offs** across the calendar.

---

## Repo structure

The layout may evolve over time, but roughly:

- `2025/` (or similar year folders)  
  Year-specific solutions.
- Inside each year:
  - `day01/`, `day02/`, … – solution for that day, usually in one chosen language

Check the folder for the day you are interested in;  
run instructions are usually in comments at the top of the source files.

---

## Technologies

You can expect a mix of:

- **REXX** and **JCL** on z/OS
- occasionally **COBOL** for “classic” style solutions
- **Python** or other “modern” helpers where it makes sense

Not every day will use every language – the idea is to **rotate** through them as it fits the problem and my mood.

---

## Inputs

Advent of Code inputs are typically **not committed**,  
because they are tied to individual accounts.

To run a solution, place your own input file as described in the comments of that day’s code.

---

## Disclaimer

This is an unofficial personal project.

It is not affiliated with Advent of Code or with Mainframe Society.
Use at your own risk, enjoy, and feel free to get inspired or adapt parts of the code.
