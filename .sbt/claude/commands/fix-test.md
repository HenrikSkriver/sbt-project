# Fix Failing Test

Diagnose and fix a failing test in this Spring Boot project.

## Steps

1. **Run the failing test** to see the current error:
   - If you know the class: `just test::single <TestClassName>`
   - If you know a pattern: `just test::matching <pattern>`
   - Otherwise: `just test::unit` or `just test::integration`

2. **Analyze the failure**:
   - Read the full stack trace
   - Identify whether it's a unit test or integration test
   - Determine root cause: assertion failure, null pointer, missing bean,
     database issue, or test configuration problem

3. **Examine the test and the code under test**:
   - Read the test class
   - Read the production class being tested
   - Check for recent changes: `git log --oneline -10 -- <file>`

4. **Fix the issue**:
   - If the test is correct and the code is wrong → fix the code
   - If the code is correct and the test is outdated → update the test
   - If the test setup is wrong → fix the test configuration

5. **Verify the fix**:
   - Run the specific test again
   - Run `just test::unit` to make sure nothing else broke
   - Run `just test::integration` for integration test changes

6. **Report**: Explain what was wrong and how it was fixed.
