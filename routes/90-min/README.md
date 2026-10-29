# From one coding agent to a useful workflow — 90 minutes

Give an agent somewhere to work, connect it to a real task, and inspect what it
returns. In this session you will run a small application inside Docker Sandboxes,
test what the agent can access, and connect a host task backlog through SBX's MCP
gateway. You will leave with a running change and a repeatable environment you can
extend into the software factory afterward.

Use one Claude subscription and one agent conversation at a time. The exercises
use the same sample application and backlog as the full workshop. You can continue
with kits, coding guidance and the all-Claude team later.

| Time | Exercise | Checkpoint |
|---|---|---|
| 15 min | Setup and authentication | Claude answers a message |
| 25 min | Run the app and test isolation | The app opens through a published port |
| 15 min | Beans and the environment file | You can read the host task and inspect the SBX plan |
| 25 min | MCP task, implementation and result | Claude retrieves the task through MCP; you inspect the change |
| 10 min | Result note, questions and continuation | You know what to keep and where to go next |

Treat these as timeboxes. If setup runs long, pair with someone whose app is
running. A successful MCP task read is a useful stopping point; do not rush past
verification to claim a completed feature.

## 1. Get ready

Follow [chapter 0](../../chapters/00-setup/README.md) to install SBX **0.50.0**, sign
in to Docker, clone this repository and run `./scripts/get-materials.sh`. Complete
that preparation before the session when possible. You need neither Docker Desktop
nor additional model-provider accounts.

Use the two terminals from chapter 0. **HOST** stays at the workshop repository
root. **SANDBOX** starts there and connects to Claude when you run SBX. Configuration
edits and SBX controls happen on HOST; application commands run inside SBX.

If you previously completed the warm-up, keep your work. The MCP exercise below
will verify it rather than implement it twice. A fresh `sample-app/` is the normal
starting point; do not reset an existing copy just to follow this route.

## 2. Run one agent and observe its boundaries

Follow [chapter 1, sections 1–3](../../chapters/01-agent/README.md#1-start-claude-in-your-application):

1. Start `wad-manual`, authenticate Claude and wait for a successful response.
2. Create a file in the shared app and read it on HOST. Check that Claude cannot
   read the neighbouring `host-only.txt`, then remove the demonstration file.
3. Ask Claude to start the app and its PostgreSQL container inside SBX. Verify
   `/healthz`, publish the port and open <http://127.0.0.1:3102>.

On Windows, include chapter 1's `prepare-workspace.sh` step before npm installs.
Stop **before chapter 1, section 4**: we will retrieve that coding task through MCP.

Before moving on, explain what runs where: your browser is on HOST; the agent,
application and database container run inside SBX. Only `sample-app/` is shared.
The sandbox boundary does not protect that mounted directory from edits or deletion.

Type `/exit` in Claude. In HOST, remove the practice sandbox:

```bash
sbx rm wad-manual
```

This frees port 3102. The source and Git history stay in `sample-app/`; the database
and running app will be recreated in the next sandbox.

## 3. Put the task outside the sandbox

Install the pinned tools and seed the workshop backlog in HOST:

```bash
./scripts/install-beans.sh
./scripts/install-mcp.sh --from-local
./scripts/backlog-init.sh --disposable
./scripts/beans list
./scripts/beans show wad-101
```

`--from-local` uses the adapter downloaded by chapter 0. No Go compiler is needed.
Beans stores the tasks under `.local/chapters/beans/.beans/`. Open that directory
in your host editor and find the warm-up task. It asks for the result-count label
to reflect the active filter, with tests covering zero, one and many results.

The backlog is outside `sample-app/` and will not be mounted into Claude's sandbox.
The disposable marker permits the adapter's optional note operation later; it
does not enable that tool by itself.

## 4. Describe the environment and its MCP connection

Open [sbxenv.yaml](sbxenv.yaml) beside this guide. Its workspace and port settings
repeat the manual setup. The `mcp` section adds the Beans server to SBX's gateway:

```text
Claude inside SBX → SBX MCP gateway → Beans MCP adapter on HOST → host backlog
```

This is [SBX-managed MCP](https://docs.docker.com/ai/sandboxes/mcp-gateway/).
We do not install Beans in Claude's environment or configure an agent-specific
MCP server. SBX configures Claude's connection to the gateway; the adapter supplies
the small tool surface. Its Bash entry point is `scripts/beans-mcp` on HOST.

In HOST, set the shell path for the following commands. On macOS or Linux:

```bash
workshop_shell="$(command -v bash)"
```

On Windows, use Git Bash and convert its executable path for SBX:

```bash
workshop_shell="$(cygpath -am "$(command -v bash)")"
```

Keep that HOST tab open so the variable remains available. Preview the environment:

```bash
sbx env plan routes/90-min/sbxenv.yaml --env-arg "host_shell=$workshop_shell"
```

Find the `sample-app/` mount, the 3102 → 8080 mapping and `wad-short-beans` command.
The adapter runs with your host user's permissions. Inspect the wrapper before
approving it: the adapter's code restricts requests to the selected backlog and
named operations. MCP connectivity is not a general host-filesystem permission.

In the SANDBOX tab, still at the repository root, run the exact same
platform-specific `workshop_shell=...` command you just used in HOST. Variables
are local to each terminal. Then start the environment:

```bash
sbx env run routes/90-min/sbxenv.yaml --env-arg "host_shell=$workshop_shell"
```

Review and approve the plan, including the host MCP command. Do not use
`--skip-host-commands`; it disables this connection. This opens Claude in the
same application directory, without Herdr, role tables or the factory launcher.

On Windows, run this in HOST before asking Claude to install app dependencies:

```bash
./scripts/prepare-workspace.sh wad-short
```

## 5. Read the task through MCP and make the change

In Claude, type `/mcp` to inspect the gateway connection. Then ask:

> Use the Beans MCP tools to list the workshop tasks and retrieve wad-101 with
> get_task. Use the tool response, not the local WORKSHOP-TASK.md copy. Summarize
> the acceptance criteria and report the returned task version. Do not change
> files or write a note yet.

Compare the response with `./scripts/beans show wad-101` in HOST. Look for the
actual tool calls, not just a plausible description of the task. At this point
the adapter exposes `list_tasks` and `get_task`; `add_task_note` is absent.
The gateway may expose its own discovery tools as well.

Now ask Claude:

> Implement wad-101 from the MCP response. If the change is already present,
> verify it instead of implementing it again. Follow the app's setup instructions
> inside SBX and run the acceptance checks. Commit the change, using Workshop
> learner and workshop@example.invalid as the Git author if none is configured.
> Start or refresh the app on 0.0.0.0:8080. Report the commit, actual check outcomes
> and how I can try the result. Do not write a backlog note yet.

Open <http://127.0.0.1:3102> and try the filters. Ask Claude to show the diff and
test output. In HOST, inspect the commit:

```bash
git -C sample-app log -1 --oneline
git -C sample-app status --short
```

The code and commit are already in your working copy. A model's “done” message
is not verification: compare the label against the task and review which checks
actually ran. The task stays open until you decide to accept it.

## 6. Explicitly enable a result note

If there is time, let the agent report its evidence back to the backlog. This
expands the tool surface from reads to appending notes; it does not grant task
deletion or an arbitrary host shell.

Type `/exit` in Claude. In the SANDBOX tab, keep the same shell variable and run:

```bash
sbx env run routes/90-min/sbxenv.yaml --env-arg "host_shell=$workshop_shell" --env-arg access=--allow-notes
```

Review and approve the changed MCP command. SBX reconciles the connection for the
same named environment. Inspect `/mcp` again and start a fresh conversation if it
still shows the old tools. Then ask:

> Read wad-101 through MCP, inspect the current commit and the verification
> evidence from this session, and use add_task_note to append a concise result.
> Include the commit and checks that actually ran; rerun checks if their evidence
> is unavailable. Do not claim an independent review, and leave the task open.

In HOST, read the task again:

```bash
./scripts/beans show wad-101
```

Find the new note. If the adapter refuses the write, check that the changed MCP
command includes `--allow-notes` and the backlog was initialized with `--disposable`.
Do not add broader host access to work around a refused operation.

Exit Claude when finished. In HOST:

```bash
sbx env rm routes/90-min/sbxenv.yaml --env-arg "host_shell=$workshop_shell" --env-arg access=--allow-notes
```

Review the destroy plan. SBX 0.50.0 removes the sandbox and its environment-defined
local MCP command. If you stopped before enabling notes, omit the `access`
argument. On an older release, inspect `sbx mcp ls` and remove only a remaining
`wad-short-beans` registration with `sbx mcp rm wad-short-beans`. Your code, commits
and host backlog remain.

## Continue building the factory

Keep this checkout. There is no second repository or application to migrate to.

- Read [chapter 2](../../chapters/02-launcher/README.md) to build the longer
  workshop's `factory/` configuration and task launcher. The warm-up is already
  done, so verify it rather than implementing it twice.
- Continue with the [small kit and coding-guidance interlude](../../chapters/02.5-acr/README.md).
- Build the [all-Claude team](../../chapters/04-team/README.md), then use
  [chapter 5](../../chapters/05-mcp/README.md) for the larger feature and network
  access exercise, and [chapter 6](../../chapters/06-human/README.md) for a human
  product decision through SSH.

If you only reached the MCP read, continue section 5 here first. If a coding task
takes too long, keep the task read and inspection as today's result. The full
workshop's [catch-up instructions](../../chapters/README.md#catch-up) explain how
to select a completed application checkpoint without losing your existing copy.
