# 0. Get ready to build a software factory

Let's get your laptop ready. You'll install Docker Sandboxes, check which agent
account you'll use, and download the sample application and workshop tools.

The sample app has a browser UI, an API and a PostgreSQL database for tracking
service incidents. You'll ask the agents to extend it as we build the factory,
keeping the source and tasks on your laptop. The app and its database container
will run inside a sandbox, so you won't need Docker Desktop.

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

These commands assume [Homebrew](https://brew.sh) is installed. Install the
release-candidate channel and host utilities:

```bash
# HOST
brew install docker/tap/sbx@rc git jq coreutils
sbx version
sbx login
```

`brew install` installs the host tools: SBX for environments, Git for source,
jq for reading JSON, and coreutils for checksums. Downloads use `curl`.
`sbx version` tells you which CLI you are running. `sbx login` signs in to Docker;
Claude's model-account login happens separately in chapter 1.

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

Check the version and sign in:

```bash
sbx version
sbx login
```

Use **Windows OpenSSH Client** for chapter 06. In Git Bash its executable is
`/c/Windows/System32/OpenSSH/ssh.exe`. If it is missing, follow Microsoft's
[OpenSSH installation instructions](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse)
to add the **client**. [Chapter 06](../06-human/README.md#2-reach-the-existing-team-through-ssh)
shows how to use it to join your running team.

### Check the version and tools

Check that `sbx version` reports **v0.45.0-rc2**, the version used by these
instructions. If Homebrew installed a different RC, use the installer for your
platform from the [SBX release](https://github.com/docker/sbx-releases/releases/tag/v0.45.0-rc2).

You also need a browser, SSH, a Bash-compatible terminal, internet access and enough
available memory for a 4-CPU/8-GB sandbox. Run one main chapter sandbox at a time
when resources are limited. Check the host utilities in each workshop terminal:

```bash
# HOST
command -v sbx git jq curl tar unzip
command -v sha256sum || command -v shasum
```

You should see a path for each tool above. A missing path means that
tool is not available in this terminal; fix its installation before continuing.
Either checksum command is sufficient: GNU systems commonly provide `sha256sum`,
while macOS provides `shasum` and the workshop scripts use `shasum -a 256`.

## 2. Have an agent account ready

For chapter 1, use your Claude subscription: we will sign in with `/login` inside
Claude Code. You do not need to create an API key for that chapter. If SBX already
has an Anthropic API credential configured, it may use that instead.

In chapter 03 you will also try Pi, an open-source assistant. The main Pi example
uses an **Anthropic API key**, configured on the host through SBX. A Claude
subscription alone does not supply that API access. If you only have a Claude
subscription, you can build all three team roles with Claude Code; chapter 04
provides that configuration. You can still install Pi and explore its interface,
or pair with someone who has provider access for the Pi conversation. Chapter 03
marks the model exercises to follow with a partner or presenter, then brings
everyone back together for team setup. You will still build the kits and configure
each role yourself.

With additional accounts, you can choose different models for development and
review. Configure the roles even if you initially give them the same model.
Never put actual keys or OAuth tokens in the workshop's files.

## 3. Clone the workshop and get its materials

Choose where you want to keep the workshop on your laptop. Open your terminal
there, then clone the repository:

```bash
# HOST
git clone https://github.com/shelajev/wad-sbx-workshop.git
cd wad-sbx-workshop
```

### Download the application and the prebuilt tool

The workshop's `get-materials.sh` script downloads
`incident-triage-board.bundle` from the pinned
[materials-v0.1.0 GitHub release](https://github.com/shelajev/wad-sbx-workshop/releases/tag/materials-v0.1.0)
and verifies its checksum. That Git bundle contains the sample application and
the saved checkpoints used to catch up later. The script clones the bundle into
`.local/app/`, then creates your editable working copy at `sample-app/` from the
`app-00-starter` checkpoint.

The script also downloads and verifies the Beans MCP adapter into `dist/`. The
adapter will let agents in the sandbox read tasks from your host backlog in
chapter 05. You'll start the sample application in chapter 01.

```bash
# HOST — from the workshop repository
./scripts/get-materials.sh
```

When it finishes, open `sample-app/README.md` in your editor. This is the project
your agents will work on. You should also find `host-only.txt` at the workshop
root; we'll use it to explore which files a sandbox can see.

Running `./scripts/get-materials.sh` again is safe: it preserves both the cached
`.local/app/` repository and an existing `sample-app/` working copy. If
`.local/app/` exists but `sample-app/` is missing, recreate the starter working
copy without another download:

```bash
# HOST — from the workshop repository
./scripts/prepare-app.sh
```

Later catch-up commands name a checkpoint explicitly. In that mode,
`prepare-app.sh` first saves the current working copy under `.local/`, then
replaces `sample-app/` with a fresh copy of the requested checkpoint.

### Find your workshop files

| Path | What you use it for |
|---|---|
| `sample-app/` | Your application source and its Git history, shared with each sandbox. |
| `chapters/` | The instructions you are following. |
| `.local/app/` | Internal Git repository containing the downloaded application checkpoints. Do not edit it directly. |
| `dist/` | The downloaded MCP tool, ready to install in chapter 05. |

In chapter 02, you'll create `factory/` for the sandbox settings and team
configuration. Keep application changes in `sample-app/` and factory settings in
`factory/`; the chapters will name each file as you need it.

**Run host commands from the workshop repository root.** The sample application's
code is in `sample-app/`. In each new host terminal, open the workshop repository.

## Set up your two terminals

Open two tabs or windows, each at the workshop repository root. Name them if your
terminal supports it:

- **HOST** stays on your laptop. Use it for SBX controls, task tracking and editing
  the workshop configuration.
- **SANDBOX** starts as another host shell at the same repository root. You run
  `sbx run` or our launcher there; it becomes your connection to an agent or a
  shell inside SBX. Keep it open while work is running. Exiting returns to the host.

Code blocks say **HOST**, **SANDBOX tab — before connecting**, **CLAUDE**, **PI**,
or **SANDBOX shell**. A prompt shown as a quotation is something to say to the
assistant, not a shell command. Edit configuration files with your normal editor.

We use one sandbox at a time and one application directory, `sample-app/`, through
chapters 01–06. The directory is mounted read/write: edits, commits and deletions
inside it are visible on your host. The rest of this workshop repository—including
the host task backlog—is outside that mount. Run application code and containers
inside SBX, not on the host.

A chapter's sandbox is temporary; your source and its Git history remain. We will
remove each sandbox before creating the next one with its new capabilities.

You are ready when `sbx version` reports the intended version, Docker login is
complete, and you can open `sample-app/README.md` in your editor.

Next: [run one agent](../01-agent/README.md).
