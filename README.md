# Component Refactoring Script (`refactor_components.sh`)

This script is an automation tool to assist in development, aligned with the modular philosophy of the VRPG project. It converts Single-File Components (`.vue`) into a multi-file structure, separating the template, styles, and logic into their own files (`.html`, `.css`, `.ts` / `.js`).

The original `.vue` file is transformed into an "aggregator" that imports these parts, maintaining the project's organization and the simplicity of imports.

## The Philosophy Behind the Tool

In our **Builder's Manifesto**, we believe in "Slicing Before Stacking." Although Vue's Single-File Components are excellent, in very large components, it can be beneficial to slice responsibilities even further:

1.  **Separation of Concerns:** Completely isolates HTML, CSS, and TypeScript, allowing a developer to focus on a single language at a time.
2.  **Tooling Improvements:** Code editors and linters can offer deeper support and analysis for pure `.html`, `.css`, and `.ts` files.
3.  **Readability:** Makes it easier to navigate components with hundreds of lines by breaking them down into smaller, more focused files.

This tool automates this "slicing," ensuring consistency and saving manual work.

## How It Works

The script performs the following actions for each `.vue` file found within `src/components/`:

1.  **Analysis:** Identifies the path and base name of the component (e.g., `Player` from `Player.vue`).
2.  **Subfolder Creation:** Creates a new folder with the base name alongside the component (e.g., `src/components/game/Player/`).
3.  **Template Extraction:** The content of the `<template>` block is saved to `Player/Player.html`.
4.  **Style Extraction:** The content of the `<style>` block is saved to `Player/Player.css`. The script preserves the `scoped` attribute if it exists.
5.  **Script Logic (Important\!):**
      * **If the component uses `<script setup>`:** The script recognizes that this logic is intrinsically linked to the Vue compiler. **It keeps the `<script setup>` block intact within the original `.vue` file** to ensure everything continues to work correctly.
      * **If it's a normal `<script>` (without `setup`):** The content is extracted to `Player/Player.ts` or `Player/Player.js`.
6.  **Component Rewrite:** The original `.vue` file is overwritten to become an aggregator, using the `src` syntax to import the external files.

**Main Advantage:** Since the original `.vue` file does not change its location, **no other file in the project that imports it needs to be modified**.

-----

## ⚠️ IMPORTANT WARNING ⚠️

> **This is a destructive operation that modifies the source files directly.**
>
> **ALWAYS** run this script in a Git repository with a clean state (no uncommitted changes). This ensures that you can easily revert all modifications with the command `git checkout -- .` if something does not go as expected.

-----

## How to Use

1.  **Ensure a Clean Git State:**

    ```sh
    git status # Should show "nothing to commit, working tree clean"
    ```

2.  **Make the Script Executable:**
    (You only need to do this once)

    ```sh
    chmod +x refactor_components.sh
    ```

3.  **Run the Script:**
    In the project root, run:

    ```sh
    ./refactor_components.sh
    ```

    The script will ask for confirmation before starting.

4.  **Review the Changes:**
    Use Git tools to see exactly what has changed:

    ```sh
    git diff
    ```

5.  **Test the Application:**
    Start the development server to confirm that all components render and function as before.

    ```sh
    npm run dev
    ```
