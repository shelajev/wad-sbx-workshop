# Presenter extensions: explore the boundaries you can change

These notes give the presenter a choice of demonstrations to explore with the
audience: sandbox inspection, live mounts, cloud execution and organization
governance. Choose the ones you have prepared and have access to. For each,
start with a question about the factory the attendees built and show what changes.
Attendees can follow along on screen; completing the workshop doesn't depend on
setting these up on their laptops.

The seeded backlog also contains `wad-104`, an optional take-home or presenter
exercise that adds a service column and filter to the incident table. It is not
part of the chapter 1–7 walkthrough.

## Look at the environment as a whole

Prepare one demo sandbox and keep it connected before presenting. The examples
below use `wad-demo`; substitute your prepared sandbox name throughout. In HOST:

```bash
sbx inspect wad-demo
```

Ask the audience to find the kits, published port and workspace/mount configuration.
Connect each item to the chapter where it was introduced. This is useful when
someone asks “what did we actually create?” or “why can this agent reach that?”
Review the output before projecting it because it can identify host paths and
account configuration. It describes the environment, not the success of a task.

## Grant access to a directory while the sandbox exists

Every workshop chapter shares the application directory. Now suppose a worker
needs an additional
reference file: can we grant that access without rebuilding its environment?

Open a shell in the selected sandbox and leave it open in terminal A:

```bash
# HOST — terminal A
sbx exec -it wad-demo bash
```

This also starts it if it was stopped. In host terminal B, prepare a scratch folder
and a message. Run these commands from the workshop repository root.

```bash
# HOST — terminal B
mkdir -p "./.local/mount-demo"
```

Create `.local/mount-demo/message.txt` in your editor with this content:

```text
A message from the host
```

Share it read-only from HOST:

```bash
sbx mount wad-demo "$(pwd)/.local/mount-demo:/home/agent/mailbox:ro"
```

`sbx mount` shares that directory at the
specified path inside the sandbox. The trailing `ro` makes it read-only. Ask the
audience to predict which of these operations will work, then try them in terminal A:

```bash
# SANDBOX shell — terminal A
cat /home/agent/mailbox/message.txt
echo changed > /home/agent/mailbox/message.txt
```

Reading should succeed and writing should fail. Ask the audience which part of
the mount command explains the difference before pointing back to `ro`.

Back on the host, revoke the mount:

```bash
# HOST — terminal B
sbx umount wad-demo "$(pwd)/.local/mount-demo:/home/agent/mailbox"
```

The spelling is `umount`; the arguments identify the same host directory and target
path. Try `cat /home/agent/mailbox/message.txt` again in the sandbox. The host file
still exists, but it is no longer visible through that mount.

A possible extension is to mount the same scratch directory into two sandboxes so
one can leave files for another. Discuss the idea rather than implementing a second
messaging system now. Sharing storage does not by itself define who reads a message,
when an agent wakes up, or how two writers coordinate. Those are the concerns we
already addressed inside the factory with files and Herdr.

Exit the inspection shell and stop the demo sandbox when finished.

## Run somewhere other than your laptop

Use a prepared cloud sandbox on an account with access. The question for the audience
is what changes when the compute is remote and what remains familiar.

```bash
# HOST
sbx --cloud --help
sbx --cloud ls
```

`--cloud` selects the cloud backend. The help output shows which commands that
backend currently supports; the list shows your remote environments. Select the
prepared demo by its name and open its agent:

```bash
# HOST — replace CLOUD_DEMO_NAME with that actual name
sbx --cloud run --name CLOUD_DEMO_NAME
```

Talk to the agent and ask it to inspect the prepared app/environment. Exit when you
are ready to show its service. If your prepared service listens on port 8080:

```bash
sbx --cloud ports CLOUD_DEMO_NAME --publish 8080
```

Open the URL returned by the cloud service. Unlike a local `3102:8080` mapping,
cloud publishing names a sandbox port and returns a remote URL.

Ask what would happen to our **workshop task-access server running on the host** in this arrangement.
It does not automatically move with the sandbox or become remotely reachable.
Moving the whole factory requires designing that connection; this demo only shows
the remote execution environment.

Remove the published demo port afterward with
`sbx --cloud ports CLOUD_DEMO_NAME --unpublish 8080`, and stop the cloud environment
using the account's supported lifecycle commands. Attendees do not need cloud access
to finish the workshop.

## Add an organization's rules

On an enrolled presenter account, show a prepared rule for a named tool. Ask the
agent to make a harmless allowed call and a harmless denied one. Read the response
together: what was blocked, who owns that rule, and where could an operator change it?

Relate this to the earlier local network decision and the adapter's limited tool
surface. Compare who configures each control and which operations it governs.
