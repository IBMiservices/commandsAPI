# Copilot Instructions for commandsAPI

## Project Overview
**commandsAPI** is an IBM i service program that provides APIs to execute CL commands and programs. It wraps the QCMDEXC API in a simplified `execCommand` procedure for easier integration.

## Architecture

### Core Components
- **[core/commands.sqlrpgle](core/commands.sqlrpgle)**: Main service program module with `execCommand` procedure
- **[reference/commands.RPGLEINC](reference/commands.RPGLEINC)**: Prototypes for QCMDEXC API and wrapper procedures
- **Service Program**: Built as `COMMANDS.SRVPGM` and exported via `COMMANDS.BND`
- **Binding Directory**: `SERVICES.BNDDIR` contains references to the service program

### Dependencies
External dependency managed via `dependencies.json`:
- **APIIBMi** (v0.0.1): Core IBM i API library from https://github.com/IBMiservices/API.git

## Build System

### Build Commands
- **Primary build**: `makei build` (defined in [iproj.json](iproj.json))
- Uses **Rules.mk** based build system with subdirectory traversal
- Build targets in [core/Rules.mk](core/Rules.mk):
  - `COMMANDS.MODULE` ← [commands.sqlrpgle](core/commands.sqlrpgle)
  - `COMMANDS.SRVPGM` ← `COMMANDS.BND` + `COMMANDS.MODULE`
  - `$(BNDDIR_NAME).BNDDIR` ← Service program + binding directory

### Dependency Installation
```bash
python install_deps.py
```
- Clones dependencies from Git repositories defined in `dependencies.json`
- Checks out specific refs/tags (e.g., `v0.0.1`)
- Cleans up metadata files (`.vscode/`, `iproj.json`, `Rules.mk`, `.git/`) from dependencies

## Code Conventions

### RPGLE Style
- **Free-format RPG**: All source files use `**FREE` directive
- **No main module**: Service programs use `ctl-opt nomain;`
- **Include paths**: Use bare filenames without path: `/include 'commands.RPGLEINC'` (includePath configured in [iproj.json](iproj.json))
- **Export procedures**: Mark with `export` keyword and list in `.BND` files

### Error Handling
Simple `monitor`/`on-error`/`endMon` blocks that suppress errors:
```rpgle
monitor;
    qcmdexc( %trim(commandString) : %len(commandString) );
on-error;
endMon;
```
**Note**: Current implementation silently catches all errors. Consider whether error handling needs enhancement for your use case.

### Naming Conventions
- **Mixed case for procedures**: `execCommand`, not `EXECCOMMAND`
- **Uppercase for constants/IBM APIs**: `QCMDEXC`, `EXTPGM`
- **Service programs**: `.SRVPGM` suffix
- **Binding directories**: `.BNDDIR` suffix

## VS Code Integration
- **Include paths**: `reference/` directory configured in [iproj.json](iproj.json)
- **Current library**: Uses `&CURLIB` variable substitution
- Actions and tasks available for build and dependency management

## Key Patterns

### Adding New Procedures
1. Add procedure to [core/commands.sqlrpgle](core/commands.sqlrpgle) with `export` keyword
2. Add prototype to [reference/commands.RPGLEINC](reference/commands.RPGLEINC)
3. Update [core/COMMANDS.BND](core/COMMANDS.BND) to export the symbol:
   ```bnd
   EXPORT SYMBOL(yourNewProcedure)
   ```
4. Rebuild with `makei build`

### Using the API
Include the prototypes in consumer code:
```rpgle
/include 'commands.RPGLEINC'

// Then call:
execCommand('DSPLIBL');
```

## Important Notes
- This is a **library/service program project**, not a standalone application
- The `curlib` setting uses `&CURLIB` for flexible library targeting
- Binding directory creation in [SERVICES.BNDDIR](core/SERVICES.BNDDIR) deletes/recreates to ensure correct timestamps
- All IBM i specific files compile on the IBM i system, not locally
