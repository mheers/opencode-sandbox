---
name: showboat
description: Use showboat to create an executable demo document (demo.md) that demonstrates the feature you just built
---

## What I do

I help you create a `demo.md` document using showboat that demonstrates a feature you just built. The document mixes commentary, executable code blocks, and captured output — serving as both readable documentation and reproducible proof of work.

## When to use me

After completing a feature, use this skill to produce a showboat demo document that proves the feature works.

## Steps

1. Run `showboat --help` to review the available commands.
2. Run `showboat init demo.md "<Title>"` to create a new demo document. Choose a descriptive title for the feature you just built.
3. Use `showboat note demo.md "<text>"` to add commentary explaining what the feature does and how it works.
4. Use `showboat exec demo.md bash "<command>"` to run commands that exercise the feature and capture their output.
5. Use `showboat exec demo.md <lang> "<code>"` to run code snippets in the appropriate language if needed.
6. Use `showboat image demo.md <path>` to include screenshots if relevant.
7. If a command fails or produces unwanted output, use `showboat pop demo.md` to remove the last entry and redo it.
8. When finished, run `showboat verify demo.md` to confirm all outputs are still reproducible.

## Tips

- Each `showboat exec` prints the captured output to stdout so you can see what happened and react to errors.
- Keep the demo focused — demonstrate the key user-facing behavior of the feature.
- Add notes between exec blocks to explain what each step proves.
- The resulting `demo.md` is a standard markdown file that can be committed to the repo.
