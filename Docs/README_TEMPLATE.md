# Portfolio README Template Standard

## Purpose

This document defines the structure and writing standards for recruiter-facing README files across this software-development portfolio.

It is intended for course projects, personal projects, capstone projects, and other repositories used to demonstrate engineering ability. It is not a universal template for open-source libraries, internal documentation, or commercial product documentation.

Every README should be tailored to its project while maintaining a consistent level of clarity, accuracy, and professional quality. Within one minute, a recruiter should be able to understand:

1. What was built
2. What the author personally contributed
3. What engineering ability the project demonstrates

---

# README Structure

Use the core sections below as the default order. Keep the strongest evidence, especially the project summary and visuals, near the top.

Omit any section that does not apply or cannot be supported by repository evidence. Add optional sections only when they improve a recruiter's understanding of the project. Never include empty sections, placeholder text, or content added only to make the README appear longer.

## Core Sections

### 1. Project Title and Summary

Use the repository or product name as the title.

Follow it with a summary of no more than 30 words that identifies:

* what the project is
* who it serves or what problem it addresses
* its most important technical or functional characteristic

Mention that the project was created for a course when that context is relevant, but do not let the course name replace the project description.

---

### 2. Demo

Place visual evidence immediately after the summary whenever it is available.

Prefer:

* three to five screenshots showing distinct workflows
* one short GIF or video showing the primary interaction flow
* a verified live demo when the project is deployed

Use short captions that explain what each visual demonstrates. Show the actual product and meaningful user states rather than decorative or redundant images.

Never reference missing assets or unavailable links. If no demonstration assets exist, omit this section, but treat their absence as a portfolio-readiness gap to address before publishing.

---

### 3. Project Context and Personal Scope

Use one short paragraph or a compact list to establish:

* whether the project is individual or collaborative
* whether it is a course, capstone, or independent project
* the author's specific responsibilities and contributions
* the current project status when it prevents misunderstanding

For an individual project, state that it was designed and implemented independently only when accurate.

For a team project, describe the author's contribution without claiming the work of others.

For a course project, distinguish assignment requirements from independently designed features and engineering decisions. Do not present required coursework as original product innovation.

For a tutorial, fork, or derivative project, identify the original source and clearly explain the author's additions or changes.

---

### 4. Key Workflows

Highlight approximately five to seven implemented capabilities that best demonstrate the project.

Describe complete user or system workflows rather than listing every screen, endpoint, or minor feature. When useful, group workflows by user role or domain.

Each item should briefly communicate:

* who or what performs the action
* what the action accomplishes
* why it matters to the overall project

Avoid generic claims such as:

* Easy to use
* User-friendly
* Fast and reliable

---

### 5. Technical Highlights

Select three to five implementation decisions that best demonstrate engineering judgment.

For each highlight, explain:

* the technical decision or approach
* why it was appropriate for the project
* the resulting benefit or tradeoff

Possible subjects include architecture, state management, asynchronous work, persistence, API integration, security, error handling, accessibility, performance, or dependency management.

Technology names and architecture labels are not explanations by themselves. Do not claim patterns such as MVVM or dependency injection unless the repository actually implements them.

When a meaningful challenge is supported by evidence, explain the problem, solution, and reasoning as part of the relevant technical highlight. Avoid separate, generic "Challenges" or "Lessons Learned" sections that read like coursework filler.

---

### 6. Architecture

Give a concise explanation of how the major parts of the project interact.

Describe only what is useful for understanding the implementation, such as:

* major layers or modules
* state and data flow
* external services and persistence boundaries
* important ownership or dependency relationships

Use a small directory tree or diagram when it communicates the structure more clearly than prose. Do not document every file or inflate ordinary folder organization into an unsupported architecture pattern.

---

### 7. Tech Stack

List only technologies that are actually used. A compact table is preferred when it improves scanning.

Useful categories may include:

* Language
* UI or application framework
* Database or persistence
* Libraries and SDKs
* APIs and external services
* Development and build tools

Explain the role of a technology when its relevance is not obvious. Do not include tools merely because they were installed or briefly evaluated.

---

### 8. Running the Project

Keep setup instructions concise while making the project reproducible.

Include only the parts that apply:

#### Prerequisites

State verified platform, toolchain, runtime, or account requirements.

#### Configuration

Describe required environment variables, configuration files, or external services without exposing credentials or private data.

#### Running

Provide verified commands or development-tool steps using accurate schemes, targets, paths, and filenames.

Do not provide speculative setup instructions. If the project cannot be run without private infrastructure, say so briefly and explain what can still be reviewed.

---

### 9. Author

Use:

Name: Chuhan Shang

GitHub: https://github.com/shangc97

Include a portfolio or LinkedIn profile only when a valid URL has been provided.

---

## Optional Sections

Use the following sections only when they are relevant and supported by evidence.

### Project Status and Known Limitations

Use this section when readers need additional context about project completeness, production readiness, unavailable infrastructure, or meaningful limitations.

Keep it brief and factual. Do not manufacture limitations merely to fill the section, and do not place a long list of negatives near the top of the README.

---

### Testing

Include only when executable automated tests exist in the repository.

Describe the test scope and provide verified commands for running the tests. Mention coverage only when a verifiable coverage report or configuration exists.

Do not present previews, sample data, manual checks, or successful builds as automated tests.

---

### Deployment

Include only when a working deployment, release, or distribution method can be verified.

Provide the relevant link and any essential access requirements. Do not reference expired builds, unavailable environments, or private deployment details.

---

### API Documentation

Include when a public or project-defining API is an important part of the work.

Document the most important endpoints, inputs, outputs, authentication requirements, or link to accurate API documentation. Do not reproduce an entire API specification when a concise overview is enough.

---

### Data Model

Include when the data model is important to understanding the project's complexity or engineering decisions.

Show only the principal entities and relationships. Prefer a concise diagram or table over exhaustive schema documentation.

---

### Roadmap

List only planned work documented in the repository or explicitly provided by the project owner.

Clearly distinguish planned work from implemented functionality. Do not repeat completed features or add speculative ideas to make the project appear active.

---

### License

Include only when a license file or other explicit licensing information exists in the repository.

Reference the existing license accurately and preserve all required attribution.

---

# Writing Style

Always write in professional English for a recruiter audience.

Use:

* concise paragraphs
* descriptive headings
* short, high-signal bullet lists
* tables and diagrams when they improve scanning
* code blocks only for commands or useful technical examples
* outcome-oriented explanations that remain understandable to non-specialists

Avoid:

* emojis
* excessive badges
* marketing language
* AI-sounding filler
* repeated information
* assignment-rubric narration
* exhaustive inventories of screens, files, classes, or endpoints
* resume bullets duplicated inside the README
* unstable vanity metrics such as source-line or file counts

Keep technical language precise, but provide enough context that a recruiter can understand why a decision matters.

---

# Accuracy Rules

Inspect the repository before writing or updating the README.

Never invent:

* features or workflows
* personal contributions
* screenshots or demos
* commands or prerequisites
* benchmarks or performance claims
* test coverage
* architecture patterns
* deployment links
* APIs or integrations
* project status or roadmap items

Everything must be supported by repository evidence or explicit, reliable information supplied by the project owner.

Quantitative claims must be verified, meaningful to a recruiter, and reasonably durable. Avoid metrics that become inaccurate after routine code changes.

Clearly separate implemented functionality from planned work. If something cannot be verified, omit it.

Never expose credentials, API keys, secrets, private data, or sensitive infrastructure details.
