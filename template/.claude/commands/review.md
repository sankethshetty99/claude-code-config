Review the most recent code changes against project standards.

1. Run `git diff HEAD` to see uncommitted changes. If there are none, use `git diff HEAD~1` for the last commit.
2. Delegate the review to the `code-reviewer` agent using the Task tool, passing the full diff.
3. Present findings organized by priority: Critical first, then Warning, then Suggestion.
4. For each issue, include file path, line number, what's wrong, and a concrete fix.
