# STATO PROGETTO — Ecojumbo / EMT

> Fonte di continuità per nuove sessioni. Ultima ricostruzione manuale: **12 novembre 2026**. Verificare sempre GitHub prima di utilizzare questi dati: le sezioni descrittive non si aggiornano da sole. Il riquadro CI viene aggiornato automaticamente dal workflow di registrazione. In caso di incoerenza prevalgono sorgenti e risultati GitHub Actions verificati.

## Identità e obiettivo

**Ecojumbo** è un'app nativa iPhone, SwiftUI/iOS, destinata al cockpit e alla telemetria di uno scooter elettrico. Repository: [gulinodesign-maker/EMT](https://github.com/gulinodesign-maker/EMT), ramo di produzione `main`. Bundle ID `it.ecojumbo.battery`, marketing version `1.0`, deployment target iOS **17.0**. Build del progetto verificata durante questa ricostruzione: **67**, sia Debug che Release. La versione reale, più recente, va letta in `Ecojumbo.xcodeproj/project.pbxproj` (NON dal README storico).

## Architettura verificata

- `Ecojumbo/EcojumboApp.swift`: entry point, environment object GPS/Bluetooth, gestione orientamento e ciclo di vita; cockpit GPS in landscape, sezioni di servizio anche portrait.
- `Ecojumbo/Views/EcojumboRootView.swift`: composizione della schermata principale, dock, modalità chiaro/scuro/automatica e routing delle sezioni.
- `Ecojumbo/Views/CockpitComponents.swift`: quadranti, corona luminosa, raccordi superiori/inferiori, telemetria e mappa GPS; lettura Open-Meteo e batteria iPhone.
- `Ecojumbo/Views/CockpitTabs.swift`: sezione viaggi, navigazione e configurazione dei temi/15 ruoli colore; tre palette personalizzate persistenti.
- `Ecojumbo/Views/OtherViews.swift`, `CellsView.swift`: configurazioni, diagnostica BMS, impostazioni e celle.
- `Ecojumbo/Models/GPSRideManager.swift`: coordinate/velocità GPS reali, trip, odometro persistente, dislivello e profilo altimetrico.
- `Ecojumbo/Bluetooth/JKBluetoothManager.swift` e `Models/JKProtocol.swift`: collegamento BLE e decodifica telemetria JK BMS, in sola lettura per i dati del cockpit.
- `Ecojumbo/Models/RideSession.swift`, `CockpitBarMath.swift`: calcolo consumi/sessioni e barre.
- `Ecojumbo/Assets.xcassets/`: risorse grafiche; `RiferimentoGrafico/`: riferimenti, **non** prova della resa effettiva.
- `Tests/`: verifiche Python strutturali e test Swift di protocollo JK e barre. Progetto Xcode: `Ecojumbo.xcodeproj/`.

## Funzioni presenti nel codice

Cockpit tachimetro GPS, mappe Apple MapKit e itinerari, indicazioni svolta, profilo altimetrico/dislivello, trip e odometro, reset controllato, telemetria SOC/tensione/potenza/autonomia derivata da misure JK BMS, cronologia consumi, stili di cockpit con 15 colori modificabili e tre slot, temi day/night, diagnostica GPS, meteo esterno da Open-Meteo e indicatore batteria iPhone da `UIDevice`. Quando una misura non è valida/non disponibile viene mostrato un trattino, non un valore inventato. **Presenza nel sorgente ≠ verifica manuale su dispositivo.**

## Decisioni e motivazioni (da preservare)

1. Niente valori GPS/BMS/meteo simulati: la telemetria presenta solo sorgenti realmente disponibili, per evitare decisioni basate su stime fittizie.
2. GPS e trip derivano da Core Location, BMS da Bluetooth JK; sono dati indipendenti. Nessuna modifica a protezioni o parametri BMS mediante UI.
3. La temperatura è una lettura meteorologica esterna Open-Meteo basata su coordinate GPS approssimate, non un sensore di temperatura dell'iPhone. Una misura mancante è esplicitamente non disponibile.
4. Le curve superiori GPS della build 66 sono speculari rispetto al centro effettivo del quadrante; nella build 67 sono stati eliminati gli effetti di dissolvenza dei raccordi superiori segnati dall'utente, conservando il taglio al bordo del tachimetro.
5. La carica del **telefono** in alto proviene da `UIDevice.current.batteryLevel` e si aggiorna attraverso notifiche iOS e ritorno in primo piano; da non confondere con il SOC della batteria scooter letto dal JK BMS.
6. L'app si prova su simulator via CI e su iPhone reale via TestFlight: compilazione, upload Apple, elaborazione App Store Connect e distribuzione ai gruppi sono **quattro stati differenti**.
7. I workflow di compilazione e upload TestFlight sono indipendenti: il workflow upload non attende la CI. Non inventare approvazioni Apple o disponibilità ai tester.
8. Ogni modifica significativa ai sorgenti va accompagnata **nello stesso commit/PR** dall'aggiornamento di questo diario. Il registro tecnico delle esecuzioni CI è automatico; decisioni e richieste utente restano responsabilità dell'assistente.

## Cronologia significativa (verificata)

- **Build 65, 12/11/2026:** rifiniture temi e griglia telemetria 2×2/DISL; alcune iterazioni PR inizialmente fallite ai test strutturali, poi corrette; CI su `main` riuscita.
- **Build 66, 12/11/2026:** simmetria raccordi al quadrante GPS e anello metallico concentrico; CI `main` riuscita: [esecuzione](https://github.com/gulinodesign-maker/EMT/actions/runs/43254110364); upload Apple riuscito: [workflow](https://github.com/gulinodesign-maker/EMT/actions/runs/43254110459).
- **Build 67, 12/11/2026:** PR [#53](https://github.com/gulinodesign-maker/EMT/pull/53), merge su `main` (`b48ce3b493923e8e4d785d654fe8a7dcd18c5751`). Rimosso fade nei due raccordi superiori GPS, tolto termometro dall'etichetta °C, migliorate ricezione/ritentativi meteo e rappresentazione della batteria iPhone. CI simulator `main` riuscita: [esecuzione](https://github.com/gulinodesign-maker/EMT/actions/runs/43267365428). Upload TestFlight riuscito: [workflow](https://github.com/gulinodesign-maker/EMT/actions/runs/43267365446); log `Upload succeeded`.
- **App Store Connect 67:** screenshot fornito dall'utente mostra `1.0 (67)` **Completo** fra i caricamenti. Nella tabella `Versione 1.0` la build 67 era senza gruppo; 66 e 65 risultavano assegnate al gruppo **TE**. Non abbiamo conferma successiva che TE abbia ricevuto la 67. Lo screenshot rappresenta uno stato osservato, non un controllo corrente via API.
- **Continuità cross-chat:** aggiunta la documentazione di handoff e predisposta la registrazione dei risultati GitHub Actions nel repository. Verificare l'effettiva automazione dopo l'attivazione del workflow: non considerare attiva fino a una prova su run concluso.

## Ultima compilazione verificata e telemetria CI

<!-- CI_STATUS_START -->
**Ultima CI verificata manualmente su main:** `1.0 (67)`, commit `b48ce3b493923e8e4d785d654fe8a7dcd18c5751`, 12/11/2026; test strutturali Python, test JK, test barre e compilazione simulator tutti riusciti. [CI #168](https://github.com/gulinodesign-maker/EMT/actions/runs/43267365428). **Ultimo upload Apple verificato:** `1.0 (67)`, [TestFlight #62](https://github.com/gulinodesign-maker/EMT/actions/runs/43267365446), riuscito. La conferma di Apple processing e dell'assegnazione ai gruppi non si deduce da CI.
<!-- CI_STATUS_END -->

Per tutti i run successivi, riusciti o falliti, consultare **[BUILD_HISTORY.md](BUILD_HISTORY.md)**. Il riquadro qui sopra è aggiornato solo per i run CI su `main` gestiti dal registratore, **non** per eventi App Store Connect.

## Stato operativo e richieste aperte

**Attività corrente:** implementazione della continuità permanente su GitHub (questo documento, `BUILD_HISTORY.md`, `AGENTS.md`, workflow di monitoraggio); provare esito del workflow registratore dopo merge.

**Richieste utente ancora da completare / da verificare:**
1. **TestFlight 67:** associare la build `1.0 (67)` al gruppo **TE** in App Store Connect e verificare che compaia «Aggiorna» su iPhone. A ultimo screenshot il caricamento era **Completo**, ma il gruppo della build 67 era vuoto. Non dichiarare distribuita senza conferma.
2. **Controllo su dispositivo reale della build 67:** verificare visivamente raccordi, temperatura con GPS+Internet e valore batteria iPhone; test automatici non equivalgono a verifica su hardware.
3. **Continuità GitHub Actions:** verificare almeno un run automatico concluso con inserimento effettivo nel registro dopo il merge; se l'account GitHub limita le scritture, leggere l'errore e il ramo fallback.
4. **ChatGPT Progetto:** inserire una volta il testo di `docs/ISTRUZIONI_PROGETTO_CHATGPT.md` nelle istruzioni del Progetto; non configurabile automaticamente da questo repository.

**Prossima operazione:** controllare il nuovo run `Compila Ecojumbo (iOS)` e il successivo `Registra esiti build EMT`; accertare che `BUILD_HISTORY.md` si aggiorni con SHA, test ed esito anche quando il job fallisce. Dopodiché verificare assegnazione TestFlight gruppo TE senza generare nuove build inutili.

## Procedura di handoff

All'inizio di ogni nuova sessione: leggere [AGENTS.md](AGENTS.md), questo stato e [BUILD_HISTORY.md](BUILD_HISTORY.md); interrogare GitHub per `main`, PR, workflow recenti, numero build effettivo e ultima commit. Controllare eventuali conflitti e richieste aperte; fare modifiche minime in branch+PR, con CI verde, documentare decisioni e problemi **prima del merge**. Non affidarsi alle vecchie versioni indicate in README.
