# BUILD HISTORY — Registro permanente delle CI EMT

Registro tecnico delle esecuzioni **Compila Ecojumbo (iOS)**. Dall'attivazione del workflow `Registra esiti build EMT`, ogni esecuzione terminata (successo, errore, annullamento o timeout) produce qui una voce con metadati GitHub verificabili. Il workflow di registrazione **non compila l'app**, non carica su TestFlight e non sostituisce la lettura dei log originali.

Le informazioni sui test e sulla compilazione derivano dagli **esiti effettivi dei passaggi GitHub Actions**; una fase saltata è `non eseguita`, mai `riuscita`. Non vengono salvati log grezzi, token, credenziali né segreti. Data e ora sono in **UTC**, ove non diversamente indicato. I file cambiati sono recuperati da GitHub per il commit SHA, non ricostruiti dalla conversazione. Se l'API non li fornisce sono segnati `non disponibili`.

L'aggiornamento usa il `GITHUB_TOKEN` del workflow, con privilegi limitati. Se `main` vieta il push del bot, un ramo di fallback conserva un tentativo di registrazione; il workflow segnala l'errore, senza fingere che `main` sia aggiornato. Leggere [STATO_PROGETTO.md](STATO_PROGETTO.md) per le decisioni e gli impegni utente non ricavabili dai log.

## Registro automatico

<!-- BUILD_HISTORY_AUTO_START -->
<!-- EMT_RUN:43305267533:ATTEMPT:1 -->
### 2026-11-12T20:56:35Z — CI #176 · build-70-no-colored-gradients-telemetry-tangent · tentativo 1

- **Esecuzione:** [GitHub Actions 43305267533](https://github.com/gulinodesign-maker/EMT/actions/runs/43305267533); avvio 2026-11-12T20:56:35Z UTC; aggiornamento finale 2026-11-12T20:56:57Z UTC; registrazione 2026-11-12T20:57:07+00:00 UTC; evento pull_request.
- **Commit:** [bba0229a0634](https://github.com/gulinodesign-maker/EMT/commit/bba0229a063426ffb8b82f1fca7afaf955f93879); versione **1.0**; build **70**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43293155559:ATTEMPT:1 -->
### 2026-11-12T19:43:56Z — CI #175 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43293155559](https://github.com/gulinodesign-maker/EMT/actions/runs/43293155559); avvio 2026-11-12T19:43:56Z UTC; aggiornamento finale 2026-11-12T19:49:21Z UTC; registrazione 2026-11-12T19:49:34+00:00 UTC; evento push.
- **Commit:** [bb7a05b0a399](https://github.com/gulinodesign-maker/EMT/commit/bb7a05b0a39974456f45abb4f5ac4f4491fd5ca0); versione **1.0**; build **69**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/CockpitTabs.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43292716756:ATTEMPT:1 -->
### 2026-11-12T19:41:21Z — CI #174 · build-69-area-gradients-double-profile · tentativo 1

- **Esecuzione:** [GitHub Actions 43292716756](https://github.com/gulinodesign-maker/EMT/actions/runs/43292716756); avvio 2026-11-12T19:41:21Z UTC; aggiornamento finale 2026-11-12T19:43:09Z UTC; registrazione 2026-11-12T19:43:20+00:00 UTC; evento pull_request.
- **Commit:** [f41863ba0994](https://github.com/gulinodesign-maker/EMT/commit/f41863ba099476941eb7239d33316fff5850e4f7); versione **1.0**; build **69**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py.

<!-- EMT_RUN:43282616860:ATTEMPT:1 -->
### 2026-11-12T18:42:24Z — CI #173 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43282616860](https://github.com/gulinodesign-maker/EMT/actions/runs/43282616860); avvio 2026-11-12T18:42:24Z UTC; aggiornamento finale 2026-11-12T18:45:46Z UTC; registrazione 2026-11-12T18:45:58+00:00 UTC; evento push.
- **Commit:** [7552aeb50d88](https://github.com/gulinodesign-maker/EMT/commit/7552aeb50d88d2a0525002824d938f2bf153791b); versione **1.0**; build **68**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/CockpitTabs.swift, Ecojumbo/Views/EcojumboRootView.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43282152539:ATTEMPT:1 -->
### 2026-11-12T18:39:42Z — CI #172 · build-68-shared-gradient-centered-telemetry · tentativo 1

- **Esecuzione:** [GitHub Actions 43282152539](https://github.com/gulinodesign-maker/EMT/actions/runs/43282152539); avvio 2026-11-12T18:39:42Z UTC; aggiornamento finale 2026-11-12T18:41:59Z UTC; registrazione 2026-11-12T18:42:15+00:00 UTC; evento pull_request.
- **Commit:** [c4472ed4064f](https://github.com/gulinodesign-maker/EMT/commit/c4472ed4064ff4d3a1eaba12fd1c99daa2d01c5a); versione **1.0**; build **68**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_build68_gradient_layout.py.

<!-- EMT_RUN:43281981908:ATTEMPT:1 -->
### 2026-11-12T18:38:42Z — CI #171 · build-68-shared-gradient-centered-telemetry · tentativo 1

- **Esecuzione:** [GitHub Actions 43281981908](https://github.com/gulinodesign-maker/EMT/actions/runs/43281981908); avvio 2026-11-12T18:38:42Z UTC; aggiornamento finale 2026-11-12T18:39:10Z UTC; registrazione 2026-11-12T18:39:20+00:00 UTC; evento pull_request.
- **Commit:** [7fbc540d913f](https://github.com/gulinodesign-maker/EMT/commit/7fbc540d913f73ab0fba79647ad8b53652142a0a); versione **1.0**; build **68**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build68_gradient_layout.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43276540175:ATTEMPT:1 -->
### 2026-11-12T18:07:27Z — CI #170 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43276540175](https://github.com/gulinodesign-maker/EMT/actions/runs/43276540175); avvio 2026-11-12T18:07:27Z UTC; aggiornamento finale 2026-11-12T18:09:21Z UTC; registrazione 2026-11-12T18:09:34+00:00 UTC; evento push.
- **Commit:** [1e306497498e](https://github.com/gulinodesign-maker/EMT/commit/1e306497498e838715aac03dac3cb12a2c6637f5); versione **1.0**; build **67**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** .github/scripts/record_build_history.py, .github/workflows/ios-build.yml, .github/workflows/record-build-history.yml, AGENTS.md, BUILD_HISTORY.md, STATO_PROGETTO.md, Tests/verify_build_history.py, docs/ISTRUZIONI_PROGETTO_CHATGPT.md.
<!-- BUILD_HISTORY_AUTO_END -->

## Evidenze storiche preesistenti (ricostruzione manuale il 12/11/2026)

Queste voci precedono l'attivazione della registrazione automatica; riportano solo gli esiti verificati via API GitHub. Le liste complete dei file si consultano tramite i rispettivi commit.

| Build/contesto | Commit | Esecuzione CI | Test Python / JK / barre | Compilazione simulator | Esito |
| --- | --- | --- | --- | --- | --- |
| 1.0 (67), main | [b48ce3b](https://github.com/gulinodesign-maker/EMT/commit/b48ce3b493923e8e4d785d654fe8a7dcd18c5751) | [43267365428](https://github.com/gulinodesign-maker/EMT/actions/runs/43267365428), 12/11 17:14 UTC | riusciti / riusciti / riusciti | riuscita | successo |
| 1.0 (67), PR #53 | [623459b](https://github.com/gulinodesign-maker/EMT/commit/623459b987768e49eca1f9f6d2fc5f91e1c89562) | [43266614829](https://github.com/gulinodesign-maker/EMT/actions/runs/43266614829), 12/11 17:10 UTC | riusciti / riusciti / riusciti | riuscita | successo |
| 1.0 (66), main | [2082057](https://github.com/gulinodesign-maker/EMT/commit/2082057a00414ecd201f8e5a4fae271cfdc8b17d) | [43254110364](https://github.com/gulinodesign-maker/EMT/actions/runs/43254110364), 12/11 16:01 UTC | riusciti / riusciti / riusciti | riuscita | successo |
| sviluppo build 65 | [f0f6aa4](https://github.com/gulinodesign-maker/EMT/commit/f0f6aa448adb96a6b83601087c1e6a3a2e0eb13e) | [43237377970](https://github.com/gulinodesign-maker/EMT/actions/runs/43237377970), 12/11 14:27 UTC | falliti / saltati / saltati | saltata | errore |

Nota: gli upload TestFlight sono **separati** dalla CI. [Build 67: upload Apple riuscito](https://github.com/gulinodesign-maker/EMT/actions/runs/43267365446); [build 66: upload Apple riuscito](https://github.com/gulinodesign-maker/EMT/actions/runs/43254110459). Questo NON certifica distribuzione ai tester.
