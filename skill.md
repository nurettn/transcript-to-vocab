# transcript-to-vocab

Convert All Ears English podcast JSON transcripts into vocabulary learning TXT files for B2-C1 level English learners.

## When to use

When the user runs `/transcript-to-vocab` with a JSON file name or asks to process transcript files into vocabulary files.

## Instructions

When invoked, do the following:

### 1. Determine which files to process

- If a file name is given (e.g. `2494.json`), process only that file from `cleaned_transcripts/`
- If no file is given, process all `.json` files in `cleaned_transcripts/` that don't already have a corresponding `.txt`

### 2. For each JSON file

Read the file. It contains:
- `keywords`: array of vocabulary items the course explicitly labels, each with `name` and `definition`
- `fullText`: full podcast transcript

### 3. Build the vocabulary list using both sources

**Step A — From `keywords` list:**
For each keyword, parse its definition field. The format is one of:
- `(part_of_speech) definition text "Example sentence."`
- `alternate form - (part_of_speech) definition text "Example sentence."`

Extract:
- The **definition text** only (drop the part of speech label — but keep `(idiom)` if it is an idiom)
- The **example sentence** from inside the quotes

**Step B — From `fullText` (this is the LLM part):**
Read the fullText carefully. The hosts are English teachers. Identify every word, phrase, or expression they are **actively teaching** — meaning they explain its meaning, contrast it with similar words, or highlight its usage for learners. This includes words **not** in the `keywords` list.

For each such word/phrase found in fullText that is NOT already in the keywords list, add it to the vocabulary list with:
- Definition: write a short, clear definition based strictly on how it is used and explained in the transcript. Do not bring in other meanings or contexts.
- Example: one natural example sentence reflecting the transcript context

### 4. Output format

Write a `.txt` file with the same base name (e.g. `2494.txt`) inside `cleaned_transcripts/`.

Format each entry as:

```
word (idiom): definition
 - Example sentence from definition field or written by you
 - Example sentence from fullText if the word is used naturally there (skip if the sentence is definitional like "the next phrase is X" or "X means Y")

```

Rules:
- Only mark `(idiom)` if it is an idiom. No other part-of-speech labels.
- Each entry is separated by a blank line
- If a fullText sentence just names or defines the word rather than using it naturally, skip it
- Stay faithful to the transcript context. Do not invent unrelated meanings or usages.

### 5. Confirm when done

After writing the file(s), report which files were created and how many vocabulary items each contains (keywords count + additionally found count).
