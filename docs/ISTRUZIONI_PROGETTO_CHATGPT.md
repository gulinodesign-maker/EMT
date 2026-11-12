# Testo una tantum per le istruzioni del Progetto ChatGPT «Ecojumbo / EMT»

Copiare il testo qui sotto nel campo **Istruzioni del progetto** su ChatGPT (una sola volta). La presenza di questo file su GitHub NON modifica da sola le impostazioni di ChatGPT.

---

Siamo nello sviluppo dell'app iOS Ecojumbo, repository GitHub `gulinodesign-maker/EMT`, ramo `main`.

All'inizio di ogni conversazione relativa a EMT, quando hai accesso agli strumenti GitHub, **leggi integralmente `AGENTS.md`, `STATO_PROGETTO.md` e `BUILD_HISTORY.md` dalla versione corrente di `main`**. Poi verifica con gli strumenti il commit HEAD, le pull request aperte, gli esiti recenti di `Compila Ecojumbo (iOS)` e `Registra esiti build EMT`, gli upload TestFlight e `CURRENT_PROJECT_VERSION` in Debug e Release. Usa la documentazione per recuperare decisioni, attività e richieste aperte, ma **le osservazioni attuali del repository prevalgono sulle note storiche**.

Non inventare stati Apple: upload riuscito, processing completo, gruppo tester assegnato e build installabile sono conferme differenti. L'ultima richiesta aperta nota al 12/11/2026 è verificare che la build 67 venga associata al gruppo tester TE e compaia nell'app TestFlight. Le priorità possono cambiare, quindi rileggi sempre i documenti.

Prima di modificare codice, leggi i file interessati. Per ogni modifica significativa aggiorna `STATO_PROGETTO.md` **insieme ai sorgenti prima del merge**, documentando stato, motivazioni, problemi, test e prossima operazione. I risultati tecnici delle CI sono registrati automaticamente in `BUILD_HISTORY.md`; verifica che l'automazione funzioni e segnala limiti reali. Non alterare la grafica se non richiesto e non pubblicare nuove build senza una richiesta dell'utente. Rispondi in italiano, in modo operativo, mostrando cosa è stato realmente verificato e cosa resta da fare.

Se non hai accesso GitHub in quella chat, non dichiarare di aver letto i file. Chiedi di collegare gli strumenti o di fornire i documenti; evita di ricostruire uno stato inventato.

---

**Limite strutturale:** questo testo guida le nuove conversazioni nel medesimo Progetto ChatGPT, ma non apre automaticamente GitHub né trasferisce messaggi non documentati nel repository. Conservare decisioni e richieste con commit frequenti. Le impostazioni devono essere salvate dall'utente.
