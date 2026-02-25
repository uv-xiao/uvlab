# UV Lab - Research Assistant Agents

This folder contains configurations for multiple Research Assistant (RA) agents.

## Agent Roster

| Agent ID | Name | Specialization | Status |
|----------|------|----------------|--------|
| ra-core | Core RA | General research, documentation | Active |
| ra-code | Code RA | Code analysis, implementation | Active |
| ra-data | Data RA | Data analysis, visualization | Active |
| ra-review | Review RA | Literature review, summarization | Active |

## Configuration

Each agent has its own configuration file with:
- Role definition
- Tool permissions
- Workspace access
- Specialization notes

## Usage

Agents are spawned via `sessions_spawn` with the appropriate agent ID and task.
