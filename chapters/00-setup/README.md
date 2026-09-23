# Chapter 0: Set up your laptop

Let's get your laptop ready. You'll install Docker Sandboxes, check which agent
account you'll use, and download the sample application and workshop tools.

The sample app has a browser UI, an API and a PostgreSQL database for tracking
service incidents. You'll ask the agents to extend it as we build the factory,
keeping the source and tasks on your laptop. The app and its database container
will run inside a sandbox, so you won't need Docker Desktop.

Commands marked **HOST** run in a terminal on your laptop. In chapter 1, you'll
open a second terminal tab marked **SANDBOX**; it starts on your laptop and connects
to the sandbox when you run `sbx`. After cloning, start both tabs at the workshop
repository root. Quoted prompts are messages to the assistant, not commands.

## 1. Install the host prerequisites

Use the [standalone SBX installation instructions](https://docs.docker.com/ai/sandboxes/install/).
No host Docker engine or Docker Desktop is required. Docker containers will run
**inside** the sandbox.

This workshop's attendee instructions are tested and supported on macOS with
Apple silicon and Windows x64 with Git Bash. Experienced Linux users are welcome
to try the exercises on a best-effort, self-supported basis. The helper scripts
recognize Linux, but the full Linux setup path is not documented, and the
instructor may not be able to troubleshoot Linux-specific differences during the
session.

### macOS on Apple silicon

These commands assume [Homebrew](https://brew.sh) is installed. Run them in your
terminal to install SBX and the host utilities, check its version, and sign in:

```bash
# HOST
brew install docker/tap/sbx@rc git jq coreutils
sbx version
sbx login
```

`sbx login` signs in to Docker; Claude's model-account login happens separately
in chapter 1. The other packages supply Git, JSON reading and checksums.

### Windows x64

Install [Git for Windows](https://gitforwindows.org/), which includes Git Bash.
Install [jq](https://jqlang.org/download/), the command-line JSON reader
used by our host scripts. With WinGet, run this in **PowerShell**:

```powershell
winget install jqlang.jq
```

Download and run `DockerSandboxes.msi` from the
[v0.45.0-rc2 release](https://github.com/docker/sbx-releases/releases/tag/v0.45.0-rc2).
Follow the Windows prerequisites in the SBX installation guide linked above.

Open new **Git Bash** tabs after installation and use them for both workshop
terminals from here onward. Git Bash supplies the shell and Unix utilities used
by the host scripts. SBX runs on Windows; the agents and application code run
inside its Linux sandbox.

Check the version and sign in from Git Bash:

```bash
sbx version
sbx login
```

Use **Windows OpenSSH Client** for chapter 6. In Git Bash its executable is
`/c/Windows/System32/OpenSSH/ssh.exe`. If it is missing, follow Microsoft's
[OpenSSH installation instructions](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse)
to add the **client**. [Chapter 6](../06-human/README.md#2-reach-the-existing-team-through-ssh)
shows how to use it to join your running team.

### Check the version and tools

Check that `sbx version` reports **v0.45.0-rc2**, the version used by these
instructions. If Homebrew installed a different RC, use the installer for your
platform from the [SBX release](https://github.com/docker/sbx-releases/releases/tag/v0.45.0-rc2).

You also need a browser, SSH, internet access and enough available memory for a
4-CPU/8-GB sandbox. Run one workshop sandbox at a time when resources are limited.
Check the host utilities in your terminal:

```bash
# HOST
command -v sbx git jq curl tar unzip
command -v sha256sum || command -v shasum
```

You should see a path for each tool above. If one is missing, install it before
continuing. Either checksum command is sufficient.

## 2. Have an agent account ready

For chapter 1, use your Claude subscription: we will sign in with `/login` inside
Claude Code. You do not need to create an API key for that chapter. If SBX already
has an Anthropic API credential configured, it may use that instead.

Chapter 3 uses Pi with an **Anthropic API key**; a Claude subscription alone does
not provide API access. If you only have the subscription, you can follow that
model exercise with a partner or presenter and run your own team with Claude Code
in all three roles. You'll still build the kits and configure the roles yourself.
Never put keys or OAuth tokens in workshop files.

## 3. Clone the workshop and get its materials

Choose where you want to keep the workshop on your laptop. Open your terminal
there, then clone the repository:

```bash
# HOST
git clone https://github.com/shelajev/wad-sbx-workshop.git
cd wad-sbx-workshop
```

### Download the application and the prebuilt tool

Run this from the repository you just cloned:

```bash
# HOST — from the workshop repository
./scripts/get-materials.sh
```

When it finishes, open `sample-app/README.md` in your editor. This is the app
you and the agents will work on. You should also find `host-only.txt` at the
workshop root; you'll use it to test what a sandbox can see.

The script downloads the app and its catch-up checkpoints from the pinned
[materials-v0.1.0 GitHub release](https://github.com/shelajev/wad-sbx-workshop/releases/tag/materials-v0.1.0).
It verifies the download, keeps the checkpoint repository in `.local/app/`, and
creates your editable copy in `sample-app/`. It also downloads the prebuilt Beans
MCP adapter into `dist/` for chapter 5. You do not need to open or edit `.local/app/`.

If the download is interrupted, run `./scripts/get-materials.sh` again; it
preserves an existing `sample-app/`. If the download completed but `sample-app/`
is missing, recreate it without downloading again:

```bash
# HOST — from the workshop repository
./scripts/prepare-app.sh
```

Later catch-up commands make a backup before replacing `sample-app/` with a
checkpoint. In chapter 2, you'll create `factory/` for sandbox and team settings;
keep application changes in `sample-app/`.

## Set up your two terminals

Before chapter 1, open a second tab at the workshop repository root. You now have:

- **HOST** stays on your laptop. Use it for SBX controls, task tracking and editing
  the workshop configuration.
- **SANDBOX** starts as another host shell at the same repository root. You run
  `sbx run` or our launcher there; it becomes your connection to an agent or a
  shell inside SBX. Keep it open while work is running. Exiting returns to the host.

Code blocks also use **CLAUDE**, **PI**, or **SANDBOX shell** when you are inside
those programs. Edit configuration files with your normal editor.

We use one sandbox at a time and one application directory, `sample-app/`, through
chapters 1–6. The directory is mounted read/write: edits, commits and deletions
inside it are visible on your host. The rest of this workshop repository—including
the host task backlog—is outside that mount. Run application code and containers
inside SBX, not on the host.

A chapter's sandbox is temporary; your source and its Git history remain. We will
remove each sandbox before creating the next one with its new capabilities.

You are ready when `sbx version` reports the intended version, Docker login is
complete, and you can open `sample-app/README.md` in your editor.

Next: [run one agent](../01-agent/README.md).
