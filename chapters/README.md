# From one agent to a software factory

Start with one agent and add what it needs for the next task. You'll keep working
in `sample-app/` throughout, with the sandbox and team configuration in `factory/`.
Each chapter builds on the previous one, so you can see what each new tool changes.

See [the factory you will build](../README.md#what-you-will-build) for the diagram
connecting the host, sandbox, agent team and task backlog.

| Chapter | What you add | What you can observe |
|---|---|---|
| [Chapter 0: Setup](00-setup/README.md) | SBX, accounts and workshop materials | Two terminals and the sample source on your laptop |
| [Chapter 1: One agent](01-agent/README.md) | Isolated execution and a mounted project | An agent runs containers, changes code and opens the app through a port |
| [Chapter 2: Repeatable environment](02-launcher/README.md) | sbxenv and a Beans task | The same project and its task in a newly created sandbox |
| [Interlude: Shared guidance](02.5-acr/README.md) | A simple kit, then ACR | A reusable installation and a policy-backed review |
| [Chapter 3: Another assistant](03-pi/README.md) | Pi and provider configuration | Try assistants and models against the same code and guidance |
| [Chapter 4: Team](04-team/README.md) | Herdr, roles and file messages | A request passes from coordinator to developer to QA |
| [Chapter 5: Host tools](05-mcp/README.md) | MCP gateway and scoped access | Agents read a host task and append the reviewed result |
| [Chapter 6: Human intervention](06-human/README.md) | SSH and a product answer | The existing team resumes using your decision |
| [Chapter 7: Reuse](07-factory/README.md) | Another project and task | The same factory works in a different mounted repository |
| [Presenter extensions](08-presenter/README.md) | Runtime mounts, cloud and governance | Additional capabilities demonstrated by the presenter |

The third-party tools and workflow are the author's choices, not Docker
endorsements. [About the tool choices](../README.md#about-the-tool-choices).

## The working arrangement

**HOST** stays at the workshop repository root. **SANDBOX** starts there too, then
connects to the agent or shell. Keep that connection open while agents and services
run: a sandbox may stop after its last client disconnects. Your open shell,
Claude session or SSH connection keeps a client connected.

Use one workshop sandbox at a time. At the end of a chapter, leave its session and
remove its environment with the command shown. This stops its processes and removes
its private runtime files. Your mounted app and Git history remain on the host.
The next worker discovers dependencies and starts services inside its new sandbox.
Database-container data is temporary unless you explicitly arrange persistence;
our sample app can recreate its demo data from its setup instructions.

Edit host configuration with your normal editor. Run application code inside SBX.
If you need another diagnostic shell while an assistant is occupied, open a third
tab and use `sbx exec -it SANDBOX-NAME bash`, substituting the current name. That
shell is for a concrete investigation; it is not a permanent part of the workflow.

## Catch-up

The numbered directories contain completed reference configurations. A catch-up
command puts the chosen configuration in **the same `factory/` directory**, so the
next incremental chapter starts from the right state. First, exit the current
sandbox session and follow that chapter's cleanup instructions. In chapters 5–7,
cleanup includes removing the host MCP registration as well as the sandbox.

If you did not complete chapter 2, install Beans and initialize the disposable
workshop backlog before using a catch-up configuration for chapter 3 or later:

```bash
# HOST — from the workshop repository
./scripts/install-beans.sh
./scripts/backlog-init.sh --disposable
```

The later launchers expect both the pinned Beans executable and this host backlog.

For example, to start chapter 3 with the ACR/Pi environment already assembled:

```bash
# HOST
./scripts/use-chapter.sh 03-pi
```

This saves your previous configuration under `.local/` and prints its location.
It replaces the environment definition, chapter settings and task prompt with
the reference versions. Your existing `factory/team.tsv` is kept, so your working
assistant and model choices carry forward. `sample-app/` is unchanged.

If you added your own kits, open the saved `sbxenv.yaml` and compare its `kits`
list with the new `factory/sbxenv.yaml`. Add back the entries you still want.
For example, if you created the browser-access kit in chapter 5, keep its access
rules for future workers by adding this entry under the new file's `kits` list:

```yaml
  - source: ./browser-access
```

The kit directory itself remains in `factory/`; this entry tells SBX to apply it.
The reference file supplies the chapter's standard kits, so keep those too.

For the chapter 3 example above, continue in your SANDBOX tab:

```bash
./scripts/launch-factory.sh wad-ch-03
```

The configuration supplies the ACR kit and opens a shell. A fresh application
checkpoint includes ACR configuration but not the installed workshop policy.
In that sandbox shell, install and verify the policy and review skill before
continuing at chapter 3's provider setup:

```bash
install-guidance
```

If you also need a completed application checkpoint, select it explicitly. To join
the SSH chapter without doing the earlier feature:

```bash
# HOST
./scripts/use-chapter.sh 06-human app-02-feature-solution
```

This also replaces `sample-app/` with the completed feature, saving its previous
contents under `.local/` and printing the backup location. Before launching, check
`factory/team.tsv`. If you have not configured a team before, catch-up supplies
the reference Pi/Anthropic coordinator and two Claude roles. Choose the
[all-Claude configuration](04-team/README.md#2-give-the-assistants-different-responsibilities)
if you have only subscription access. Restore any extra kit entries as described
above. Then launch `wad-ch-06`, run `install-guidance` in its sandbox shell for the
fresh checkpoint, and submit its task as chapter 6 describes.
The path you work in remains `sample-app/`.

## Repeating a chapter

Changing the environment file affects the next creation. To try your changes,
finish the current conversation, exit its session and use the chapter's cleanup
commands in HOST. Read any result or question you need before removal: the mounted
source stays, but the in-sandbox conversation and running services do not.

For example, after chapter 5:

```bash
# HOST
sbx env rm factory/sbxenv.yaml --env-arg name=wad-ch-05
sbx mcp rm wad-ch-05-beans
```

The first command removes the sandbox; the second removes its host tool
registration. The sandbox and host connection are separate resources.
Chapters 6 and 7 show the corresponding names for their environments. Earlier
chapters have no MCP registration to remove.

Then run the chapter's launcher again from the SANDBOX tab, at the workshop root.
It creates the environment from your updated configuration. Your app's current
edits remain; use a checkpoint only if you want to replace them.

If creation failed, run `sbx ls` in HOST to see whether the named workshop sandbox
was created. Follow its cleanup commands before retrying; remove only this
workshop's environment and, where applicable, its MCP registration.

If the error says port 3102 is already in use, check whether you left the previous
chapter's sandbox running. Every chapter uses that same host port so you can keep
one browser address throughout the workshop. Finish and remove the previous
workshop sandbox before launching the next. If none is using it, ask the instructor
to help identify the other local service; do not stop an unrelated process blindly.
