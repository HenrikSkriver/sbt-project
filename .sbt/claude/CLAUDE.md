# SBT Toolkit Instructions

This project uses the **SBT** (Spring Boot Toolkit) for common operations.
The toolkit is installed at `.sbt/` and provides recipes for building, testing,
deploying, and managing Spring Boot services.

## Available Operations

Run `just` in the project root to see all available commands.
Commands are organized into modules:

- `just docker::<recipe>` — Container image build, push, run
- `just db::<recipe>` — Database migrations, seeding, reset
- `just test::<recipe>` — Unit tests, integration tests, coverage
- `just deploy::<recipe>` — Deployment to staging/production
- `just deps::<recipe>` — Dependency checks, updates, analysis

## Project Conventions

- **Docker images** are built using Spring Boot buildpacks (`spring-boot:build-image`)
- **Database migrations** use Flyway, located in `src/main/resources/db/migration/`
- **Test execution order**: unit → integration → contract
- **Profiles**: `local` for development, `test` for CI, `prod` for production builds
- **Java version**: 21 (override `java_version` in the root justfile if different)

## When Implementing New Features

1. Follow existing controller/service/repository patterns in `src/main/java/`
2. Always create integration tests using `@SpringBootTest`
3. Run `just test::unit` to verify unit tests pass
4. Run `just test::integration` to verify integration tests pass
5. Run `just docker::build` to verify the image builds successfully

## When Working With Dependencies

1. Use `just deps::tree` to inspect the current dependency graph
2. Use `just deps::updates` to check for available updates
3. Use `just deps::analyze` to find unused or undeclared dependencies

## Coding Standards

- Use constructor injection, not field injection
- DTOs for API boundaries, entities for persistence
- Validation annotations on DTOs (`@NotNull`, `@Valid`, etc.)
- Use `@Transactional` at the service layer
- Test naming: `should_expectedBehavior_when_condition`
