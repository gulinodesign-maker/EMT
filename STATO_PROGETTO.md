# STATO PROGETTO — Ecojumbo / EMT

> Fonte di continuità per nuove sessioni. Ultima ricostruzione manuale: **12 novembre 2026**. Verificare sempre GitHub prima di utilizzare questi dati: le sezioni descrittive non si aggiornano da sole. Il riquadro CI viene aggiornato automaticamente dal workflow di registrazione. In caso di incoerenza prevalgono sorgenti e risultati GitHub Actions verificati.

## Identità e obiettivo

**Ecojumbo** è un'app nativa iPhone, SwiftUI/iOS, destinata al cockpit e alla telemetria di uno scooter elettrico. Repository: [gulinodesign-maker/EMT](https://github.com/gulinodesign-maker/EMT), ramo di produzione `main`. Bundle ID `it.ecojumbo.battery`, marketing version `1.0`, deployment target iOS **17.0**. Build del progetto su `main`: **1.0 (68)** (Debug e Release), commit `7552aeb50d88d2a0525002824d938f2bf153791b`. CI main [43282616860](https://github.com/gulinodesign-maker/EMT/actions/runs/43282616860) riuscita; upload Apple build 68 confermato dai log del secondo tentativo [43282616970](https://github.com/gulinodesign-maker/EMT/actions/runs/43282616970): `Numero build TestFlight: 68`, `ARCHIVE SUCCEEDED`, `Upload succeeded`, `EXPORT SUCCEEDED`. Elaborazione ASC e distribuzione ai tester non verificate. La versione reale, più recente, va letta in `Ecojumbo.xcodeproj/project.pbxproj` (NON dal README storico).

## Architettura verificata

- `Ecojumbo/EcojumboApp.swift`: entry point, environment object GPS/Bluetooth, gestione orientamento e ciclo di vita; cockpit GPS in landscape, sezioni di servizio anche portrait.
- `Ecojumbo/Views/EcojumboRootView.swift`: composizione della schermata principale, dock, modalità chiaro/scuro/automatica e routing delle sezioni.
- `Ecojumbo/Views/CockpitComponents.swift`: quadranti, corona luminosa, raccordi superiori/inferiori, telemetria e mappa GPS; lettura Open-Meteo e batteria iPhone.
- `Ecojumbo/Views/CockpitTabs.swift`: sezione viaggi, navigazione e configurazione dei temi/17 ruoli colore (15 precedenti più due estremi della sfumatura); tre palette personalizzate persistenti.
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
- **Continuità cross-chat, 12/11/2026:** implementazione [PR #54](https://github.com/gulinodesign-maker/EMT/pull/54) integrata su `main` al commit `1e306497498e838715aac03dac3cb12a2c6637f5`. CI main [#170](https://github.com/gulinodesign-maker/EMT/actions/runs/43276540175) con test e compilazione simulatore riusciti; workflow di registrazione [43276877533](https://github.com/gulinodesign-maker/EMT/actions/runs/43276877533) riuscito. Il bot ha effettivamente committato `BUILD_HISTORY.md` e aggiornato il riquadro CI in questo file su `main` (commit `c94f3e16f6ecf93aae04e104c2b1b104e30d1880`), senza lanciare altre CI. Sono stati verificati davvero il percorso positivo e la persistenza; esiti falliti/cancellati e fallback scrittura sono coperti da test, ma NON ancora provati con un fallimento reale dopo l'attivazione.

- **Build 68 (integrata su `main` con [PR #55](https://github.com/gulinodesign-maker/EMT/pull/55), 12/11/2026):** sfumatura condivisa e personalizzabile per top bar GPS e ponte inferiore kW tramite due ruoli colore aggiuntivi (17 totali) nell'editor; migrazione conservativa degli slot 8→17 e 15→17. Allargamento telemetria + dock dei cinque tasti sull'intervallo centrato fra la tangente destra del quadrante GPS e il confine destro del display, con margini simmetrici. Non alterati dati JK, GPS, trip, mappa o firmware. **Verificato:** test Python/JK/barre e compilazione iOS simulator su PR #55: [CI 43282152539](https://github.com/gulinodesign-maker/EMT/actions/runs/43282152539) `success`, merge SHA `7552aeb5`. **Verificato anche su main:** CI [43282616860](https://github.com/gulinodesign-maker/EMT/actions/runs/43282616860) `success`; primo tentativo di TestFlight [43282616970](https://github.com/gulinodesign-maker/EMT/actions/runs/43282616970) fallito senza assegnazione runner e job `cancelled` dopo attesa. Rilanciato il solo job, il secondo tentativo è riuscito (12/11/2026, 19:06:16 UTC): log `Numero build TestFlight: 68`, `ARCHIVE SUCCEEDED`, `Upload succeeded`, `EXPORT SUCCEEDED`, Apple segnala `Uploaded package is processing`. **Da verificare:** elaborazione ASC conclusa, gruppo tester **TE**, pulsante «Aggiorna» in TestFlight e resa visiva reale iPhone. Nessun aumento build necessario.

- **Build 69 (in sviluppo, richiesta utente con screenshot annotato 12/11/2026):** correggere l'interpretazione della 68. I ruoli editabili 15/16 e l'accent centrale NON colorano più le linee; applicano una sfumatura orizzontale al riempimento dell'area tra bordo superiore e top bar e al riempimento interno sotto il ponte kW. I bordi luminosi restano nel colore principale, senza fade aggiuntivi alle giunzioni del quadrante. Aggiungere un profilo indipendente e parallelo ai due lati del tachimetro che segue i percorsi verdi annotati, con spessore esattamente **3×** rispetto agli stroke principali (top bar e ponte, stesso spessore base). Resta invariato il centraggio della telemetria e dei tasti della 68, come GPS, BMS e trip. La nuova build 69 non è ancora compilata né inviata ad Apple in questo primo commit: CI, rilascio e verifica visiva sono da completare.

## Ultima compilazione verificata e telemetria CI

<!-- CI_STATUS_START -->
<!-- CI_SOURCE_STARTED:2026-11-12T18:42:24Z -->
**Ultimo run CI main registrato automaticamente:** versione **1.0 (68)**, commit 7552aeb50d88, avvio 2026-11-12T18:42:24Z UTC, esito workflow **SUCCESS**. [Passaggi verificabili e dettagli](https://github.com/gulinodesign-maker/EMT/actions/runs/43282616860). Consultare BUILD_HISTORY.md per esito effettivo di test e compilazione. Questo NON certifica upload, processing o distribuzione ai tester.
<!-- CI_STATUS_END -->

Per tutti i run successivi, riusciti o falliti, consultare **[BUILD_HISTORY.md](BUILD_HISTORY.md)**. Il riquadro qui sopra è aggiornato solo per i run CI su `main` gestiti dal registratore, **non** per eventi App Store Connect.

## Stato operativo e richieste aperte

**Attività corrente:** implementazione della **build 69** sul ramo `build-69-area-gradients-double-profile`: i colori editabili devono agire sulle aree piene sopra la top bar e sotto il ponte kW, non sui bordi, con nuovo profilo parallelo 3× indicato in verde. Ancora da confermare i test, la compilazione iOS e l'upload Apple. La 68 resta l'ultima build con upload verificato.

**Richieste utente ancora da completare / da verificare:**
1. **TestFlight 68/69 (priorità):** dopo upload Apple riuscito, controllare in App Store Connect `1.0 (68)`, verificare processing completo e associazione al gruppo **TE**; confermare pulsante «Aggiorna» su iPhone. Nell'ultimo screenshot precedente, la 67 risultava **Completo** ma senza gruppo. Non dichiarare la 68 distribuita senza conferma da App Store Connect.
2. **Controllo su dispositivo reale della build 67:** verificare visivamente raccordi, temperatura con GPS+Internet e valore batteria iPhone; test automatici non equivalgono a verifica su hardware.
3. **ChatGPT Progetto:** inserire una volta il testo di `docs/ISTRUZIONI_PROGETTO_CHATGPT.md` nelle istruzioni del Progetto; non configurabile automaticamente da questo repository.

**Verifiche tecniche completate:** PR #54 / CI verde, workflow di registrazione realmente eseguito con esito `success`, entry nel registro su `main`, aggiornamento automatico del riquadro CI e assenza di loop. La gestione degli esiti negativi è stata testata con casi automatici simulati, ma il ramo fallback per permessi negati non è stato esercitato in ambiente reale.

**Prossima operazione:** eseguire test/regressioni build 69 e compilazione reale iOS nella PR; dopo CI verde integrare su `main` e verificare CI main, archive, export e upload Apple. Controllare successivamente elaborazione App Store Connect e associazione al gruppo **TE** (senza dedurla dall'upload), e ottenere verifica visiva su iPhone di entrambi i RIEMPIMENTI sfumati, della nuova linea 3× e dei comandi telemetria.

## Procedura di handoff

All'inizio di ogni nuova sessione: leggere [AGENTS.md](AGENTS.md), questo stato e [BUILD_HISTORY.md](BUILD_HISTORY.md); interrogare GitHub per `main`, PR, workflow recenti, numero build effettivo e ultima commit. Controllare eventuali conflitti e richieste aperte; fare modifiche minime in branch+PR, con CI verde, documentare decisioni e problemi **prima del merge**. Non affidarsi alle vecchie versioni indicate in README.
