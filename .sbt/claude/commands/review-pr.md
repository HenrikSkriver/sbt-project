# Review Pull Request

Perform a thorough code review of the current changes, applying this project's
conventions and the SBT toolkit standards.

## Steps

1. **Identify changes**: Run `git diff main...HEAD --stat` to see which files changed.

2. **Read the diff**: Run `git diff main...HEAD` and analyze each change.

3. **Check for issues** in these categories:
   - **Correctness**: Logic errors, edge cases, null safety
   - **Testing**: Are new paths covered by tests? Are tests meaningful?
   - **Conventions**: Constructor injection, DTO boundaries, `@Transactional` placement
   - **Security**: Input validation, SQL injection, auth checks
   - **Performance**: N+1 queries, missing indexes, unnecessary eager loading

4. **Run the test suite**:
   - `just test::unit` — verify unit tests pass
   - `just test::integration` — verify integration tests pass

5. **Check dependencies** if `pom.xml` changed:
   - `just deps::analyze` — check for unused/undeclared dependencies

6. **Report findings**: Organize by severity (critical, warning, suggestion).
   Be specific about file, line, and the recommended fix.
