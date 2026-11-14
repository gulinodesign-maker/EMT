# Istruzioni Copilot per Ecojumbo / EMT

Questo repository è un'app iOS SwiftUI con tachimetro GPS, letture JK BMS Bluetooth, mappa, trip e pubblicazione TestFlight tramite GitHub Actions.

1. **Leggi sempre `AGENTS.md` prima di modificare il repository**. È la fonte autorevole per regole tecniche, versionamento, registrazione dello stato e pubblicazione.
2. Consulta `STATO_PROGETTO.md`, `BUILD_HISTORY.md` e i sorgenti/test della parte coinvolta. Non dare per scontato che la documentazione sia aggiornata se GitHub o la CI mostrano altro.
3. Lavora con modifiche minime e verificabili. Non introdurre telemetria falsa, dati statici in sostituzione di GPS/BMS, segreti o regressioni grafiche non richieste.
4. Se il compito è solo di analisi, configurazione di Agent o revisione, **non modificare il numero build né l'app**, e non avviare un rilascio.
5. Se l'utente richiede esplicitamente una nuova build iOS, segui la politica di rilascio di `AGENTS.md`: test → build Xcode verificata → pubblicazione autorizzata → conferma del log Apple, distinguendo upload da disponibilità tester.
6. L'utente richiede **nessun costo aggiuntivo**: usa soltanto funzionalità gratuite già disponibili. Non configurare abbonamenti Copilot a pagamento, API esterne con tariffazione, chiavi cloud o runner a pagamento. Fermati se un compito richiede servizi fatturabili.
7. Gli Agent del progetto in `.github/agents/` sono profili locali riutilizzabili. I file non avviano Copilot Cloud Agent, non abilitano Copilot Free sull'account e non sostituiscono l'autorizzazione dell'utente.
