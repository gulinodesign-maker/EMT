#!/usr/bin/env python3
"""Persist verified EMT iOS CI outcomes without copying logs or executing PR code."""
import argparse
import base64
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[2]
AUTO_START = "<!-- BUILD_HISTORY_AUTO_START -->"
AUTO_END = "<!-- BUILD_HISTORY_AUTO_END -->"
STATUS_START = "<!-- CI_STATUS_START -->"
STATUS_END = "<!-- CI_STATUS_END -->"
TEST_STEPS = (
    "Controlli strutturali Python",
    "Test protocollo JK Bluetooth (sola lettura)",
    "Test barre dinamiche",
)
BUILD_STEP = "Compila app per simulatore iOS (senza firma Apple)"


def api(repo, token, path):
    request = Request(
        "https://api.github.com/repos/" + repo + "/" + path,
        headers={"Authorization": "Bearer " + token,
                 "Accept": "application/vnd.github+json",
                 "X-GitHub-Api-Version": "2022-11-28",
                 "User-Agent": "Ecojumbo-build-history"})
    try:
        with urlopen(request, timeout=35) as response:
            return json.load(response)
    except HTTPError as exc:
        if exc.code in (404, 422):
            return None
        raise RuntimeError("GitHub API HTTP " + str(exc.code)) from None
    except URLError:
        raise RuntimeError("GitHub API unavailable") from None


def jobs_for(repo, token, run_id):
    jobs = []
    for page in range(1, 21):
        result = api(repo, token, "actions/runs/" + str(run_id) +
                     "/jobs?per_page=100&page=" + str(page))
        if not result or not isinstance(result.get("jobs"), list):
            raise RuntimeError("Cannot verify CI jobs")
        chunk = result["jobs"]
        jobs.extend(chunk)
        if len(chunk) < 100:
            break
    else:
        raise RuntimeError("Too many jobs: incomplete verification")
    if not jobs:
        raise RuntimeError("No CI jobs: refusing guessed success")
    return jobs


def version_at(repo, token, sha):
    if not re.fullmatch("[0-9a-f]{40}", sha):
        return "non disponibile", "non disponibile"
    response = api(repo, token, "contents/Ecojumbo.xcodeproj/project.pbxproj?ref=" + sha)
    if not response or response.get("encoding") != "base64":
        return "non disponibile", "non disponibile"
    try:
        source = base64.b64decode(response["content"]).decode("utf-8")
    except (KeyError, ValueError, UnicodeError):
        return "non disponibile", "non disponibile"
    numbers = re.findall(r"CURRENT_PROJECT_VERSION\s*=\s*(\d+);", source)
    versions = re.findall(r"MARKETING_VERSION\s*=\s*([0-9]+(?:\.[0-9]+)*);", source)
    number = numbers[0] if len(numbers) == 2 and len(set(numbers)) == 1 else "non disponibile"
    version = versions[0] if len(versions) == 2 and len(set(versions)) == 1 else "non disponibile"
    return version, number


def commit_files(repo, token, sha):
    if not re.fullmatch("[0-9a-f]{40}", sha):
        return None
    commit = api(repo, token, "commits/" + sha)
    if not commit or not isinstance(commit.get("files"), list):
        return None
    return [entry["filename"] for entry in commit["files"]
            if isinstance(entry.get("filename"), str)]


def clean(value, limit=160):
    value = str(value).replace("\r", " ").replace("\n", " ")
    for a, b in (("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"),
                 ("|", "&#124;"), (chr(96), "'")):
        value = value.replace(a, b)
    return value[:limit]


def steps_from(jobs):
    result = {}
    for job in jobs:
        for step in job.get("steps") or []:
            if step.get("name") in TEST_STEPS + (BUILD_STEP,):
                result[step["name"]] = step.get("conclusion") or "non concluso"
    return result


def verdict(run, step, states):
    result = states.get(step, "non presente")
    if (run.get("status") == "completed" and run.get("conclusion") == "success"
            and result == "success"):
        return "RIUSCITO"
    if result == "skipped":
        return "NON ESEGUITO"
    if result == "success":
        return "fase riuscita, workflow complessivo " + clean(run.get("conclusion"))
    return clean(result).upper()


def errors_for(run, jobs):
    failed = []
    bad = ("failure", "cancelled", "timed_out", "action_required")
    for job in jobs:
        steps = job.get("steps") or []
        for step in steps:
            if step.get("conclusion") in bad:
                failed.append(clean(step.get("name", "passaggio sconosciuto")))
        if job.get("conclusion") in bad and not any(
                s.get("conclusion") in bad for s in steps):
            failed.append("job: " + clean(job.get("name", "sconosciuto")))
    if failed:
        return "; ".join(dict.fromkeys(failed)) + ". Dettagli nei log GitHub."
    if run.get("conclusion") != "success":
        return "Workflow " + clean(run.get("conclusion")) + "; vedere log."
    return "Nessun passaggio fallito riportato dall'API GitHub."


def make_entry(run, jobs, version, number, files, repo):
    run_id = int(run["id"])
    attempt = int(run.get("run_attempt") or 1)
    sha = run.get("head_sha") or ""
    valid_sha = bool(re.fullmatch("[0-9a-f]{40}", sha))
    started = clean(run.get("run_started_at") or run.get("created_at") or "non disponibile")
    finished = clean(run.get("updated_at") or "non disponibile")
    recorded = datetime.now(timezone.utc).isoformat(timespec="seconds")
    if files is None:
        names = "non disponibili dall'API GitHub"
    elif not files:
        names = "nessun file restituito dall'API GitHub"
    else:
        names = ", ".join(clean(name, 240) for name in files[:100])
        if len(files) > 100:
            names += "; altri " + str(len(files) - 100) + " file: consultare il commit"
    result = steps_from(jobs)
    tests = "; ".join(clean(name) + ": **" + verdict(run, name, result) + "**"
                      for name in TEST_STEPS)
    url = "https://github.com/" + repo + "/actions/runs/" + str(run_id)
    commit_url = ("[" + sha[:12] + "](https://github.com/" + repo + "/commit/" + sha + ")"
                  if valid_sha else "non disponibile")
    return (
        "<!-- EMT_RUN:" + str(run_id) + ":ATTEMPT:" + str(attempt) + " -->\n"
        + "### " + started + " — CI #" + clean(run.get("run_number"))
        + " · " + clean(run.get("head_branch")) + " · tentativo " + str(attempt) + "\n\n"
        + "- **Esecuzione:** [GitHub Actions " + str(run_id) + "](" + url + ")"
        + "; avvio " + started + " UTC; aggiornamento finale " + finished
        + " UTC; registrazione " + recorded + " UTC; evento " + clean(run.get("event")) + ".\n"
        + "- **Commit:** " + commit_url + "; versione **" + clean(version)
        + "**; build **" + clean(number) + "**.\n"
        + "- **Esito workflow:** **" + clean(run.get("conclusion")).upper() + "**.\n"
        + "- **Test automatici:** " + tests + ".\n"
        + "- **Compilazione simulatore:** **" + verdict(run, BUILD_STEP, result) + "**.\n"
        + "- **Errori rilevati:** " + errors_for(run, jobs) + "\n"
        + "- **File modificati nel commit:** " + names + ".\n"
    )


def append_once(text, entry, run_id, attempt):
    marker = "<!-- EMT_RUN:" + str(run_id) + ":ATTEMPT:" + str(attempt) + " -->"
    if marker in text:
        return text, False
    if text.count(AUTO_START) != 1 or text.count(AUTO_END) != 1:
        raise RuntimeError("Missing/duplicated BUILD_HISTORY section markers")
    head, remainder = text.split(AUTO_START, 1)
    old, foot = remainder.split(AUTO_END, 1)
    placeholder = ("_Nessun evento automatico ancora registrato. Il primo evento verificato "
                   "dopo l'installazione del workflow sarà aggiunto qui._")
    old = old.replace(placeholder, "").strip()
    new_text = head + AUTO_START + "\n" + entry.strip() + "\n"
    if old:
        new_text += "\n" + old + "\n"
    return new_text + AUTO_END + foot, True


def update_status(text, run, version, number, repo):
    if run.get("head_branch") != "main" or run.get("event") not in ("push", "workflow_dispatch"):
        return text
    if text.count(STATUS_START) != 1 or text.count(STATUS_END) != 1:
        raise RuntimeError("Missing/duplicated STATO_PROGETTO section markers")
    head, remainder = text.split(STATUS_START, 1)
    prior, foot = remainder.split(STATUS_END, 1)
    started = clean(run.get("run_started_at") or run.get("created_at") or "")
    earlier = re.search(r"<!-- CI_SOURCE_STARTED:([^\s<>]+) -->", prior)
    if earlier and earlier.group(1) > started:
        return text
    url = ("https://github.com/" + repo + "/actions/runs/" + str(int(run["id"])))
    return (
        head + STATUS_START + "\n<!-- CI_SOURCE_STARTED:" + started + " -->\n"
        + "**Ultimo run CI main registrato automaticamente:** versione **"
        + clean(version) + " (" + clean(number) + ")**, commit "
        + clean((run.get("head_sha") or "")[:12]) + ", avvio " + started
        + " UTC, esito workflow **" + clean(run.get("conclusion")).upper() + "**. "
        + "[Passaggi verificabili e dettagli](" + url + "). Consultare BUILD_HISTORY.md "
        + "per esito effettivo di test e compilazione. Questo NON certifica upload, "
        + "processing o distribuzione ai tester.\n"
        + STATUS_END + foot
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-id", required=True, type=int)
    args = parser.parse_args()
    repo = os.environ.get("GITHUB_REPOSITORY", "")
    token = os.environ.get("GH_TOKEN", "")
    if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repo):
        raise RuntimeError("Invalid repository")
    if not token:
        raise RuntimeError("Missing GitHub token")
    run = api(repo, token, "actions/runs/" + str(args.run_id))
    if not run or run.get("status") != "completed":
        raise RuntimeError("Source CI not completed; cannot record success")
    if run.get("name") != "Compila Ecojumbo (iOS)":
        raise RuntimeError("Wrong source workflow")
    if (run.get("head_repository") or {}).get("full_name") != repo:
        raise RuntimeError("Source repository not verified")
    jobs = jobs_for(repo, token, args.run_id)
    sha = run.get("head_sha") or ""
    version, number = version_at(repo, token, sha)
    files = commit_files(repo, token, sha)
    entry = make_entry(run, jobs, version, number, files, repo)
    history_file = ROOT / "BUILD_HISTORY.md"
    new, written = append_once(
        history_file.read_text(encoding="utf-8"), entry,
        int(run["id"]), int(run.get("run_attempt") or 1))
    if written:
        history_file.write_text(new, encoding="utf-8")
    state_file = ROOT / "STATO_PROGETTO.md"
    old_state = state_file.read_text(encoding="utf-8")
    state = update_status(old_state, run, version, number, repo)
    if state != old_state:
        state_file.write_text(state, encoding="utf-8")
    print("Recorded CI #" + str(args.run_id) + "; new=" + str(written)
          + "; workflow=" + str(run.get("conclusion"))
          + "; simulator=" + verdict(run, BUILD_STEP, steps_from(jobs)))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print("::error::History recording failed: " + str(exc), file=sys.stderr)
        sys.exit(1)
