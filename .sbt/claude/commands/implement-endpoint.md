# Implement REST Endpoint

Implement a new REST endpoint following this project's conventions and the SBT
toolkit standards.

## Steps

1. **Examine existing patterns**: Read the existing controllers, services, and
   repositories in `src/main/java/` to understand the project's conventions.

2. **Create the layers**:
   - Controller with `@RestController` and proper request/response DTOs
   - Service interface and implementation with `@Transactional` where needed
   - Repository using Spring Data JPA
   - DTOs for request and response bodies with validation annotations

3. **Add database migration** if new tables or columns are needed:
   - Run `just db::new-migration <descriptive-name>` to generate a migration file
   - Write the SQL migration

4. **Write tests**:
   - Unit tests for the service layer using Mockito
   - Integration tests for the controller using `@SpringBootTest` + `@AutoConfigureMockMvc`
   - Name tests: `should_expectedBehavior_when_condition`

5. **Verify**:
   - Run `just test::unit` — all unit tests must pass
   - Run `just test::integration` — all integration tests must pass
   - Run `just docker::build` — image must build successfully

6. **Report**: Summarize what was created and the test results.
