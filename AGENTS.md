# AGENTS.md — Istruzioni per agenti che lavorano su EMT

**Scope:** tutto il repository `gulinodesign-maker/EMT`.

## Prima di qualunque modifica

1. Leggere `STATO_PROGETTO.md` integralmente; contiene architettura, scelte, rischi, richieste aperte e prossimo intervento.
2. Consultare `BUILD_HISTORY.md` per la cronologia verificata, inclusi i fallimenti. NON assumere che i test siano riusciti perché un commit è stato creato.
3. Verificare da GitHub `main`, HEAD SHA, branch attivi, PR, nuovi workflow, esiti CI, numero build Debug/Release in `Ecojumbo.xcodeproj/project.pbxproj`; non fidarsi del vecchio README o dei valori statici della documentazione.
4. Ricostruire cosa è completato, cosa manca e quali richieste dell'utente richiedono verifica; confrontare con il contesto corrente prima di operare.
5. Leggere i sorgenti e i test effettivi interessati prima di editarli. Non regredire GPS, BMS, palette, MapKit, trip e UI approvata.

## Durante lo sviluppo

- Operare preferibilmente in branch e PR con modifiche minime; non inserire dati GPS/BMS/meteo fittizi né segreti. Non modificare grafica e telemetria se non richiesto.
- Aggiornare `STATO_PROGETTO.md` **insieme al codice nello stesso commit/PR significativo**: descrivere cosa è cambiato, perché, problemi risolti, prove, aspetti non verificati, lavoro in corso, prossimo passo e nuove richieste utente.
- Se non c'è modifica di codice ma emerge una decisione importante, una richiesta ancora aperta o una scoperta tecnica critica, salvare subito lo stato nel repo con commit documentale.
- Il workflow `Registra esiti build EMT` compila i record tecnici in `BUILD_HISTORY.md` dopo la conclusione di `Compila Ecojumbo (iOS)` e aggiorna soltanto la sezione delimitata del riquadro CI in `STATO_PROGETTO.md` per i run di `main`. Non modificare manualmente i delimitatori `BUILD_HISTORY_AUTO_START/END` e `CI_STATUS_START/END`.
- Verificare se un run è **success**, **failure**, **cancelled** o altro; controllare ciascuno step test/build. Il bot evita loop tramite `GITHUB_TOKEN` e filtri sui soli file documentali. Se non può scrivere `main`, cerca un ramo fallback e segnala chiaramente la mancata registrazione in `main`.
- Non scrivere credenziali, chiavi Apple, token, coordinate personali, log grezzi o identificativi sensibili nella documentazione o nei commit.

## Versionamento, test e pubblicazione

- Build del progetto ricostruita 12/11/2026: `1.0 (67)`. Verificare nuovamente prima di scegliere il prossimo numero; `CURRENT_PROJECT_VERSION` va allineato in Debug e Release e aggiornare i test di versione.
- `.github/workflows/ios-build.yml`: test Python, plist, JK protocol, barre e build simulatore.
- `.github/workflows/testflight.yml`: archivio/upload Apple automatico su cambi dei sorgenti su `main`; workflow autonomo, NON gated dalla CI.
- Distinguere rigorosamente: codice su `main` → CI realmente conclusa → archivio/upload `Upload succeeded` → processing App Store Connect → associazione gruppo/tester → disponibilità TestFlight. Non dedurre gli ultimi due stati dal verde di GitHub.
- L'ultimo screenshot utente mostrava build 67 **Completo** in ASC, ma **senza gruppo**, mentre 66/65 avevano gruppo `TE`. Verificare l'associazione di 67 a `TE` prima di dichiararla disponibile.

## Nuova chat / limiti

Questo file e gli altri documenti sopravvivono a qualunque interruzione della chat **perché sono su GitHub**. Non garantiscono che un nuovo assistente abbia accesso automatico: occorrono collegamento GitHub/strumenti di lettura; in mancanza, chiedere solo le informazioni strettamente necessarie. Le istruzioni da configurare una volta nel Progetto ChatGPT sono in `docs/ISTRUZIONI_PROGETTO_CHATGPT.md`.
