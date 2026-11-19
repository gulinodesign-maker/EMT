"""Build-history automation regression checks, no network or credentials required."""
from pathlib import Path
import importlib.util

root = Path(__file__).resolve().parents[1]
modpath = root / ".github/scripts/record_build_history.py"
ci = (root / ".github/workflows/ios-build.yml").read_text()
logger = (root / ".github/workflows/record-build-history.yml").read_text()
history = (root / "BUILD_HISTORY.md").read_text()
state = (root / "STATO_PROGETTO.md").read_text()
assert modpath.is_file()
assert "workflow_run:" in logger and "types: [completed]" in logger
assert "actions: read" in logger and "contents: write" in logger
assert "ref: main" in logger and "ci/history-fallback-" in logger
assert "git push origin HEAD:refs/heads/main" in logger
assert "paths-ignore:" in ci and "'BUILD_HISTORY.md'" in ci
assert "macos-15-intel" in ci and "pull_request:" in ci
assert "BUILD_HISTORY_AUTO_START" in history
assert "CI_STATUS_START" in state

spec = importlib.util.spec_from_file_location("emt_history", modpath)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
# Synthetic timestamp must be newer than all real CI history markers.
run = {
    "id": 1234567, "run_number": 171, "run_attempt": 1,
    "event": "push", "head_branch": "main", "head_sha": "a" * 40,
    "status": "completed", "conclusion": "success",
    "run_started_at": "2099-01-01T12:00:00Z",
    "updated_at": "2026-11-12T19:05:00Z",
}
steps = [{"name": name, "conclusion": "success"}
         for name in module.TEST_STEPS + (module.BUILD_STEP,)]
jobs = [{"name": "Test sorgenti + build simulatore", "conclusion": "success",
         "steps": steps}]
results = module.steps_from(jobs)
for name in module.TEST_STEPS + (module.BUILD_STEP,):
    assert module.verdict(run, name, results) == "RIUSCITO"
entry = module.make_entry(run, jobs, "1.0", "67", ["Ecojumbo/Foo.swift"],
                          "gulinodesign-maker/EMT")
assert "1234567" in entry and "Ecojumbo/Foo.swift" in entry
first, fresh = module.append_once(history, entry, 1234567, 1)
assert fresh and first.count("EMT_RUN:1234567:ATTEMPT:1") == 1
second, fresh = module.append_once(first, entry, 1234567, 1)
assert not fresh and second == first

# Failed steps and skipped compilation MUST NOT be recorded as passing.
failed_run = dict(run, conclusion="failure")
failed_jobs = [{"name": "Test sorgenti + build simulatore", "conclusion": "failure",
                "steps": [{"name": module.TEST_STEPS[0], "conclusion": "failure"},
                          {"name": module.BUILD_STEP, "conclusion": "skipped"}]}]
result = module.steps_from(failed_jobs)
assert module.verdict(failed_run, module.BUILD_STEP, result) == "NON ESEGUITO"
assert module.verdict(failed_run, module.TEST_STEPS[0], result) != "RIUSCITO"
assert module.TEST_STEPS[0] in module.errors_for(failed_run, failed_jobs)
assert "FAILURE" in module.make_entry(failed_run, failed_jobs, "1.0", "67",
                                       None, "gulinodesign-maker/EMT")
pr_run = dict(run, event="pull_request", head_branch="feature/fix")
assert module.update_status(state, pr_run, "1.0", "68", "gulinodesign-maker/EMT") == state
new_state = module.update_status(state, run, "1.0", "67", "gulinodesign-maker/EMT")
assert "CI_SOURCE_STARTED:2099-01-01T12:00:00Z" in new_state
older = dict(run, run_started_at="2099-01-01T11:00:00Z")
assert module.update_status(new_state, older, "1.0", "67", "gulinodesign-maker/EMT") == new_state
print("OK — history workflow success/failure, idempotency, version and main guard")
