# Short-route review and rehearsal

Recorded October 29, 2026.

## Gemini review

Gemini CLI 0.65.0 reviewed the full attendee guide, environment file and Beans
wrapper in a dedicated Docker Sandbox with no host filesystem mounts. It received
the review material as copied files and ran in read-only plan mode. No Gemini
process ran on the host.

Gemini reported no blocking issues. Its suggestion to clarify the repeated shell
variable assignment in the two terminals was applied. Its cloud-account advice
was not applied to this local-sandbox route, and its optional suggestion to revert
struggling learners' changes was rejected to preserve their work.

## Runtime verification

- Both read-only and note-enabled reference environment plans passed.
- Real wrapper protocol tests passed for default read-only, explicit `--read-only`
  and `--allow-notes` modes. Read-only mode exposed only the two task-read tools.
- Claude retrieved the actual task through SBX's MCP gateway and confirmed that
  the note tool was absent before permission was expanded.
- In a disposable application copy, Claude implemented the task and committed it.
  A separate verification run passed typecheck, 7 unit tests and 8 integration
  tests. The starter application's full 19-test non-browser suite also passed.
- Reapplying an SBX environment with `access=--allow-notes` reconciled the server
  command. Claude appended a result note through the gateway and read it back;
  the task remained `todo`.
- Existing helper and handoff tests, Go vet, Go formatting and local documentation
  links passed.

The runtime rehearsal used the installed SBX 0.49.2; the guide targets 0.50.0.
To honor this machine's host-execution policy, the gateway's test command used
`sbx exec -i` to run the Beans adapter in a separate SBX. It did not run the adapter
on the host. This exercises a real gateway and environment reconciliation, but
does not establish a native-host adapter or Windows SBX runtime rehearsal.
No browser automation was run; manual browser access and Windows setup still
need checking on the presenter's target installation.
