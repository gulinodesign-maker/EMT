# BUILD HISTORY — Registro permanente delle CI EMT

Registro tecnico delle esecuzioni **Compila Ecojumbo (iOS)**. Dall'attivazione del workflow `Registra esiti build EMT`, ogni esecuzione terminata (successo, errore, annullamento o timeout) produce qui una voce con metadati GitHub verificabili. Il workflow di registrazione **non compila l'app**, non carica su TestFlight e non sostituisce la lettura dei log originali.

Le informazioni sui test e sulla compilazione derivano dagli **esiti effettivi dei passaggi GitHub Actions**; una fase saltata è `non eseguita`, mai `riuscita`. Non vengono salvati log grezzi, token, credenziali né segreti. Data e ora sono in **UTC**, ove non diversamente indicato. I file cambiati sono recuperati da GitHub per il commit SHA, non ricostruiti dalla conversazione. Se l'API non li fornisce sono segnati `non disponibili`.

L'aggiornamento usa il `GITHUB_TOKEN` del workflow, con privilegi limitati. Se `main` vieta il push del bot, un ramo di fallback conserva un tentativo di registrazione; il workflow segnala l'errore, senza fingere che `main` sia aggiornato. Leggere [STATO_PROGETTO.md](STATO_PROGETTO.md) per le decisioni e gli impegni utente non ricavabili dai log.

## Registro automatico

<!-- BUILD_HISTORY_AUTO_START -->
<!-- EMT_RUN:43949985711:ATTEMPT:1 -->
### 2026-11-16T20:27:34Z — CI #327 · build-101-day-topbar-theme-cleanup · tentativo 1

- **Esecuzione:** [GitHub Actions 43949985711](https://github.com/gulinodesign-maker/EMT/actions/runs/43949985711); avvio 2026-11-16T20:27:34Z UTC; aggiornamento finale 2026-11-16T20:28:09Z UTC; registrazione 2026-11-16T20:28:19+00:00 UTC; evento pull_request.
- **Commit:** [b2cf69f79999](https://github.com/gulinodesign-maker/EMT/commit/b2cf69f799996dce39d4230aa55a4a0400f52140); versione **1.0**; build **101**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build93_geometry_preview.py.

<!-- EMT_RUN:43949855018:ATTEMPT:1 -->
### 2026-11-16T20:26:48Z — CI #326 · build-101-day-topbar-theme-cleanup · tentativo 1

- **Esecuzione:** [GitHub Actions 43949855018](https://github.com/gulinodesign-maker/EMT/actions/runs/43949855018); avvio 2026-11-16T20:26:48Z UTC; aggiornamento finale 2026-11-16T20:27:18Z UTC; registrazione 2026-11-16T20:27:29+00:00 UTC; evento pull_request.
- **Commit:** [31b15fb21db4](https://github.com/gulinodesign-maker/EMT/commit/31b15fb21db4759789a9e8b528c9b02a444c2aef); versione **1.0**; build **101**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** .github/workflows/ios-build.yml.

<!-- EMT_RUN:43949714946:ATTEMPT:1 -->
### 2026-11-16T20:26:00Z — CI #325 · build-101-day-topbar-theme-cleanup · tentativo 1

- **Esecuzione:** [GitHub Actions 43949714946](https://github.com/gulinodesign-maker/EMT/actions/runs/43949714946); avvio 2026-11-16T20:26:00Z UTC; aggiornamento finale 2026-11-16T20:26:28Z UTC; registrazione 2026-11-16T20:26:37+00:00 UTC; evento pull_request.
- **Commit:** [0c1d4ca4063c](https://github.com/gulinodesign-maker/EMT/commit/0c1d4ca4063c3156304b7350b5f6155f05946607); versione **1.0**; build **101**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build92_twenty_shades.py.

<!-- EMT_RUN:43949526998:ATTEMPT:1 -->
### 2026-11-16T20:24:55Z — CI #324 · build-101-day-topbar-theme-cleanup · tentativo 1

- **Esecuzione:** [GitHub Actions 43949526998](https://github.com/gulinodesign-maker/EMT/actions/runs/43949526998); avvio 2026-11-16T20:24:55Z UTC; aggiornamento finale 2026-11-16T20:25:27Z UTC; registrazione 2026-11-16T20:25:43+00:00 UTC; evento pull_request.
- **Commit:** [e6fc240ff224](https://github.com/gulinodesign-maker/EMT/commit/e6fc240ff224acabe3f06cfcadf6b6de6386cbf2); versione **1.0**; build **101**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build91_top_bottom_fades.py.

<!-- EMT_RUN:43949288047:ATTEMPT:1 -->
### 2026-11-16T20:23:32Z — CI #323 · build-101-day-topbar-theme-cleanup · tentativo 1

- **Esecuzione:** [GitHub Actions 43949288047](https://github.com/gulinodesign-maker/EMT/actions/runs/43949288047); avvio 2026-11-16T20:23:32Z UTC; aggiornamento finale 2026-11-16T20:24:02Z UTC; registrazione 2026-11-16T20:24:13+00:00 UTC; evento pull_request.
- **Commit:** [4dab4fb985f9](https://github.com/gulinodesign-maker/EMT/commit/4dab4fb985f9e3d3c695826f89b19da46b60cb93); versione **1.0**; build **101**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build90_exterior_layer.py, Tests/verify_build91_top_bottom_fades.py, Tests/verify_build92_twenty_shades.py, Tests/verify_build95_map_concentric.py.

<!-- EMT_RUN:43949004431:ATTEMPT:1 -->
### 2026-11-16T20:21:54Z — CI #322 · build-101-day-topbar-theme-cleanup · tentativo 1

- **Esecuzione:** [GitHub Actions 43949004431](https://github.com/gulinodesign-maker/EMT/actions/runs/43949004431); avvio 2026-11-16T20:21:54Z UTC; aggiornamento finale 2026-11-16T20:22:28Z UTC; registrazione 2026-11-16T20:22:38+00:00 UTC; evento pull_request.
- **Commit:** [49d6409a8d4b](https://github.com/gulinodesign-maker/EMT/commit/49d6409a8d4b52a85c8ba7474bd916ccfb421b9f); versione **1.0**; build **101**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build89_layer_edges.py.

<!-- EMT_RUN:43948800477:ATTEMPT:1 -->
### 2026-11-16T20:20:43Z — CI #321 · build-101-day-topbar-theme-cleanup · tentativo 1

- **Esecuzione:** [GitHub Actions 43948800477](https://github.com/gulinodesign-maker/EMT/actions/runs/43948800477); avvio 2026-11-16T20:20:43Z UTC; aggiornamento finale 2026-11-16T20:21:06Z UTC; registrazione 2026-11-16T20:21:17+00:00 UTC; evento pull_request.
- **Commit:** [709bdf47d791](https://github.com/gulinodesign-maker/EMT/commit/709bdf47d791d809f6d0c719b9f878bd9f07eecf); versione **1.0**; build **101**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build74_speed_phases_neon.py.

<!-- EMT_RUN:43948625945:ATTEMPT:1 -->
### 2026-11-16T20:19:44Z — CI #320 · build-101-day-topbar-theme-cleanup · tentativo 1

- **Esecuzione:** [GitHub Actions 43948625945](https://github.com/gulinodesign-maker/EMT/actions/runs/43948625945); avvio 2026-11-16T20:19:44Z UTC; aggiornamento finale 2026-11-16T20:20:09Z UTC; registrazione 2026-11-16T20:20:21+00:00 UTC; evento pull_request.
- **Commit:** [bfd284e216c5](https://github.com/gulinodesign-maker/EMT/commit/bfd284e216c510f75032cc3118e15b145704471c); versione **1.0**; build **101**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build74_speed_phases_neon.py, Tests/verify_build93_geometry_preview.py, Tests/verify_build95_map_concentric.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py.

<!-- EMT_RUN:43948305706:ATTEMPT:1 -->
### 2026-11-16T20:17:51Z — CI #319 · build-101-day-topbar-theme-cleanup · tentativo 1

- **Esecuzione:** [GitHub Actions 43948305706](https://github.com/gulinodesign-maker/EMT/actions/runs/43948305706); avvio 2026-11-16T20:17:51Z UTC; aggiornamento finale 2026-11-16T20:18:18Z UTC; registrazione 2026-11-16T20:18:33+00:00 UTC; evento pull_request.
- **Commit:** [b3a389766511](https://github.com/gulinodesign-maker/EMT/commit/b3a3897665119931f6d07cfae2933eb75d47050f); versione **1.0**; build **101**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build73_settings_glow_speed.py.

<!-- EMT_RUN:43948077040:ATTEMPT:1 -->
### 2026-11-16T20:16:32Z — CI #318 · build-101-day-topbar-theme-cleanup · tentativo 1

- **Esecuzione:** [GitHub Actions 43948077040](https://github.com/gulinodesign-maker/EMT/actions/runs/43948077040); avvio 2026-11-16T20:16:32Z UTC; aggiornamento finale 2026-11-16T20:17:15Z UTC; registrazione 2026-11-16T20:17:24+00:00 UTC; evento pull_request.
- **Commit:** [60b52f2fea30](https://github.com/gulinodesign-maker/EMT/commit/60b52f2fea30a9dcfe311ca2867ce3444c0a2a59); versione **1.0**; build **101**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build65_ui.py.

<!-- EMT_RUN:43947886259:ATTEMPT:1 -->
### 2026-11-16T20:15:28Z — CI #317 · build-101-day-topbar-theme-cleanup · tentativo 1

- **Esecuzione:** [GitHub Actions 43947886259](https://github.com/gulinodesign-maker/EMT/actions/runs/43947886259); avvio 2026-11-16T20:15:28Z UTC; aggiornamento finale 2026-11-16T20:16:00Z UTC; registrazione 2026-11-16T20:16:13+00:00 UTC; evento pull_request.
- **Commit:** [a5636ab62fcc](https://github.com/gulinodesign-maker/EMT/commit/a5636ab62fccdb3db77f0bf9043c9d3c497bbc02); versione **1.0**; build **101**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43936937883:ATTEMPT:1 -->
### 2026-11-16T19:12:42Z — CI #316 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43936937883](https://github.com/gulinodesign-maker/EMT/actions/runs/43936937883); avvio 2026-11-16T19:12:42Z UTC; aggiornamento finale 2026-11-16T19:15:14Z UTC; registrazione 2026-11-16T19:15:29+00:00 UTC; evento push.
- **Commit:** [dd152290ee2a](https://github.com/gulinodesign-maker/EMT/commit/dd152290ee2ace306c07a0e64392e48932c12e01); versione **1.0**; build **100**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/CockpitTabs.swift, STATO_PROGETTO.md, Tests/verify_build100_luminous_rings_power_weather.py, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_build89_layer_edges.py, Tests/verify_build90_exterior_layer.py, Tests/verify_build91_top_bottom_fades.py, Tests/verify_build92_twenty_shades.py, Tests/verify_build93_geometry_preview.py, Tests/verify_build94_preview_dial_geometry.py, Tests/verify_build95_map_concentric.py, Tests/verify_build96_topbar_flush.py, Tests/verify_build97_music_cockpit.py, Tests/verify_build98_inapp_music.py, Tests/verify_build99_music_search_clip.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43936597488:ATTEMPT:1 -->
### 2026-11-16T19:10:45Z — CI #315 · build-100-luminous-double-ring-power-temp · tentativo 1

- **Esecuzione:** [GitHub Actions 43936597488](https://github.com/gulinodesign-maker/EMT/actions/runs/43936597488); avvio 2026-11-16T19:10:45Z UTC; aggiornamento finale 2026-11-16T19:12:16Z UTC; registrazione 2026-11-16T19:12:26+00:00 UTC; evento pull_request.
- **Commit:** [31e134717354](https://github.com/gulinodesign-maker/EMT/commit/31e13471735438b97e7ead80cbd8c783a3991319); versione **1.0**; build **100**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_build91_top_bottom_fades.py.

<!-- EMT_RUN:43936414613:ATTEMPT:1 -->
### 2026-11-16T19:09:45Z — CI #314 · build-100-luminous-double-ring-power-temp · tentativo 1

- **Esecuzione:** [GitHub Actions 43936414613](https://github.com/gulinodesign-maker/EMT/actions/runs/43936414613); avvio 2026-11-16T19:09:45Z UTC; aggiornamento finale 2026-11-16T19:10:19Z UTC; registrazione 2026-11-16T19:10:30+00:00 UTC; evento pull_request.
- **Commit:** [f6e5b13f84bf](https://github.com/gulinodesign-maker/EMT/commit/f6e5b13f84bff694d1d8dd2f9aabef2d33097733); versione **1.0**; build **100**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build68_gradient_layout.py.

<!-- EMT_RUN:43936256052:ATTEMPT:1 -->
### 2026-11-16T19:08:50Z — CI #313 · build-100-luminous-double-ring-power-temp · tentativo 1

- **Esecuzione:** [GitHub Actions 43936256052](https://github.com/gulinodesign-maker/EMT/actions/runs/43936256052); avvio 2026-11-16T19:08:50Z UTC; aggiornamento finale 2026-11-16T19:09:18Z UTC; registrazione 2026-11-16T19:09:31+00:00 UTC; evento pull_request.
- **Commit:** [dbca7e243037](https://github.com/gulinodesign-maker/EMT/commit/dbca7e243037f9a9d10735b194b40d0050623b94); versione **1.0**; build **100**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build66_symmetry_ring.py, Tests/verify_build85_left_topbar_off.py.

<!-- EMT_RUN:43920870463:ATTEMPT:1 -->
### 2026-11-16T17:40:38Z — CI #312 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43920870463](https://github.com/gulinodesign-maker/EMT/actions/runs/43920870463); avvio 2026-11-16T17:40:38Z UTC; aggiornamento finale 2026-11-16T17:43:31Z UTC; registrazione 2026-11-16T17:43:57+00:00 UTC; evento push.
- **Commit:** [b3c4161bbac6](https://github.com/gulinodesign-maker/EMT/commit/b3c4161bbac695df3b0a18856c945e79a2e7d40f); versione **1.0**; build **99**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Models/EcoMusicManager.swift, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/EcoMusicCockpitPanel.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_build89_layer_edges.py, Tests/verify_build90_exterior_layer.py, Tests/verify_build91_top_bottom_fades.py, Tests/verify_build92_twenty_shades.py, Tests/verify_build93_geometry_preview.py, Tests/verify_build94_preview_dial_geometry.py, Tests/verify_build95_map_concentric.py, Tests/verify_build96_topbar_flush.py, Tests/verify_build97_music_cockpit.py, Tests/verify_build98_inapp_music.py, Tests/verify_build99_music_search_clip.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43920161379:ATTEMPT:1 -->
### 2026-11-16T17:36:32Z — CI #311 · build-99-music-library-search-map-clip · tentativo 1

- **Esecuzione:** [GitHub Actions 43920161379](https://github.com/gulinodesign-maker/EMT/actions/runs/43920161379); avvio 2026-11-16T17:36:32Z UTC; aggiornamento finale 2026-11-16T17:40:15Z UTC; registrazione 2026-11-16T17:40:25+00:00 UTC; evento pull_request.
- **Commit:** [5e8fc5b35413](https://github.com/gulinodesign-maker/EMT/commit/5e8fc5b35413caefa5f5e647819faffbe54c065c); versione **1.0**; build **99**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_build98_inapp_music.py.

<!-- EMT_RUN:43919977547:ATTEMPT:1 -->
### 2026-11-16T17:35:30Z — CI #310 · build-99-music-library-search-map-clip · tentativo 1

- **Esecuzione:** [GitHub Actions 43919977547](https://github.com/gulinodesign-maker/EMT/actions/runs/43919977547); avvio 2026-11-16T17:35:30Z UTC; aggiornamento finale 2026-11-16T17:36:03Z UTC; registrazione 2026-11-16T17:36:22+00:00 UTC; evento pull_request.
- **Commit:** [054a3ef32665](https://github.com/gulinodesign-maker/EMT/commit/054a3ef32665290a52c6b8c0893440beb1f9e80f); versione **1.0**; build **99**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build66_symmetry_ring.py, Tests/verify_build98_inapp_music.py.

<!-- EMT_RUN:43919767706:ATTEMPT:1 -->
### 2026-11-16T17:34:21Z — CI #309 · build-99-music-library-search-map-clip · tentativo 1

- **Esecuzione:** [GitHub Actions 43919767706](https://github.com/gulinodesign-maker/EMT/actions/runs/43919767706); avvio 2026-11-16T17:34:21Z UTC; aggiornamento finale 2026-11-16T17:34:53Z UTC; registrazione 2026-11-16T17:35:05+00:00 UTC; evento pull_request.
- **Commit:** [9b0a837a058f](https://github.com/gulinodesign-maker/EMT/commit/9b0a837a058ffb539f72f821402ab81f58397a04); versione **1.0**; build **99**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43914818588:ATTEMPT:1 -->
### 2026-11-16T17:06:30Z — CI #308 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43914818588](https://github.com/gulinodesign-maker/EMT/actions/runs/43914818588); avvio 2026-11-16T17:06:30Z UTC; aggiornamento finale 2026-11-16T17:09:50Z UTC; registrazione 2026-11-16T17:10:12+00:00 UTC; evento push.
- **Commit:** [0bd00b4129ac](https://github.com/gulinodesign-maker/EMT/commit/0bd00b4129ac9ae35adc9ac06e1b919375d9a831); versione **1.0**; build **98**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Info.plist, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/EcoMusicCockpitPanel.swift, Ecojumbo/Views/EcojumboRootView.swift, Ecojumbo/Views/OtherViews.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_build89_layer_edges.py, Tests/verify_build90_exterior_layer.py, Tests/verify_build91_top_bottom_fades.py, Tests/verify_build92_twenty_shades.py, Tests/verify_build93_geometry_preview.py, Tests/verify_build94_preview_dial_geometry.py, Tests/verify_build95_map_concentric.py, Tests/verify_build96_topbar_flush.py, Tests/verify_build97_music_cockpit.py, Tests/verify_build98_inapp_music.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_map_contour_build48.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43914133845:ATTEMPT:1 -->
### 2026-11-16T17:02:47Z — CI #307 · build-98-inapp-musickit-cockpit · tentativo 1

- **Esecuzione:** [GitHub Actions 43914133845](https://github.com/gulinodesign-maker/EMT/actions/runs/43914133845); avvio 2026-11-16T17:02:47Z UTC; aggiornamento finale 2026-11-16T17:05:54Z UTC; registrazione 2026-11-16T17:06:07+00:00 UTC; evento pull_request.
- **Commit:** [c0e7c8b5513d](https://github.com/gulinodesign-maker/EMT/commit/c0e7c8b5513de3c3f98ad5697d83f9ade8ecd1af); versione **1.0**; build **98**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_map_contour_build48.py.

<!-- EMT_RUN:43913956491:ATTEMPT:1 -->
### 2026-11-16T17:01:47Z — CI #306 · build-98-inapp-musickit-cockpit · tentativo 1

- **Esecuzione:** [GitHub Actions 43913956491](https://github.com/gulinodesign-maker/EMT/actions/runs/43913956491); avvio 2026-11-16T17:01:47Z UTC; aggiornamento finale 2026-11-16T17:02:21Z UTC; registrazione 2026-11-16T17:02:32+00:00 UTC; evento pull_request.
- **Commit:** [d59cf36cb4bb](https://github.com/gulinodesign-maker/EMT/commit/d59cf36cb4bb1eb5f8ecf530640b9e49d3ac5d1c); versione **1.0**; build **98**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build85_left_topbar_off.py.

<!-- EMT_RUN:43913864497:ATTEMPT:1 -->
### 2026-11-16T17:01:17Z — CI #305 · build-98-inapp-musickit-cockpit · tentativo 1

- **Esecuzione:** [GitHub Actions 43913864497](https://github.com/gulinodesign-maker/EMT/actions/runs/43913864497); avvio 2026-11-16T17:01:17Z UTC; aggiornamento finale 2026-11-16T17:02:02Z UTC; registrazione 2026-11-16T17:02:13+00:00 UTC; evento pull_request.
- **Commit:** [df9452f8db36](https://github.com/gulinodesign-maker/EMT/commit/df9452f8db36f818e10652e8127105626397dde5); versione **1.0**; build **98**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Ecojumbo/Views/CockpitComponents.swift.

<!-- EMT_RUN:43913712432:ATTEMPT:1 -->
### 2026-11-16T17:00:30Z — CI #304 · build-98-inapp-musickit-cockpit · tentativo 1

- **Esecuzione:** [GitHub Actions 43913712432](https://github.com/gulinodesign-maker/EMT/actions/runs/43913712432); avvio 2026-11-16T17:00:30Z UTC; aggiornamento finale 2026-11-16T17:00:59Z UTC; registrazione 2026-11-16T17:01:10+00:00 UTC; evento pull_request.
- **Commit:** [e63d0f31cc17](https://github.com/gulinodesign-maker/EMT/commit/e63d0f31cc17cf2a51a5e825ae1f19c647715324); versione **1.0**; build **98**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build66_symmetry_ring.py, Tests/verify_cockpit.py, Tests/verify_telemetry_dock_build62.py.

<!-- EMT_RUN:43913515527:ATTEMPT:1 -->
### 2026-11-16T16:59:25Z — CI #303 · build-98-inapp-musickit-cockpit · tentativo 1

- **Esecuzione:** [GitHub Actions 43913515527](https://github.com/gulinodesign-maker/EMT/actions/runs/43913515527); avvio 2026-11-16T16:59:25Z UTC; aggiornamento finale 2026-11-16T17:00:40Z UTC; registrazione 2026-11-16T17:00:51+00:00 UTC; evento pull_request.
- **Commit:** [427427dda777](https://github.com/gulinodesign-maker/EMT/commit/427427dda77764fcf115b47698e2ec6960568970); versione **1.0**; build **98**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build98_inapp_music.py.

<!-- EMT_RUN:43902311603:ATTEMPT:1 -->
### 2026-11-16T15:58:36Z — CI #302 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43902311603](https://github.com/gulinodesign-maker/EMT/actions/runs/43902311603); avvio 2026-11-16T15:58:36Z UTC; aggiornamento finale 2026-11-16T16:02:00Z UTC; registrazione 2026-11-16T16:02:13+00:00 UTC; evento push.
- **Commit:** [6cdd68037820](https://github.com/gulinodesign-maker/EMT/commit/6cdd68037820db4a7747af16aadb1c5355282894); versione **1.0**; build **97**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/EcojumboApp.swift, Ecojumbo/Info.plist, Ecojumbo/Models/EcoMusicManager.swift, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/EcoMusicCockpitPanel.swift, Ecojumbo/Views/EcojumboRootView.swift, Ecojumbo/Views/OtherViews.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_build89_layer_edges.py, Tests/verify_build90_exterior_layer.py, Tests/verify_build91_top_bottom_fades.py, Tests/verify_build92_twenty_shades.py, Tests/verify_build93_geometry_preview.py, Tests/verify_build94_preview_dial_geometry.py, Tests/verify_build95_map_concentric.py, Tests/verify_build96_topbar_flush.py, Tests/verify_build97_music_cockpit.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43901676522:ATTEMPT:1 -->
### 2026-11-16T15:55:11Z — CI #301 · build-97-cockpit-music · tentativo 1

- **Esecuzione:** [GitHub Actions 43901676522](https://github.com/gulinodesign-maker/EMT/actions/runs/43901676522); avvio 2026-11-16T15:55:11Z UTC; aggiornamento finale 2026-11-16T15:58:04Z UTC; registrazione 2026-11-16T15:58:16+00:00 UTC; evento pull_request.
- **Commit:** [9ce4460c9615](https://github.com/gulinodesign-maker/EMT/commit/9ce4460c9615d4dbbfc91bf69a713406b3394d0f); versione **1.0**; build **97**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo/Models/EcoMusicManager.swift.

<!-- EMT_RUN:43901117533:ATTEMPT:1 -->
### 2026-11-16T15:52:16Z — CI #300 · build-97-cockpit-music · tentativo 1

- **Esecuzione:** [GitHub Actions 43901117533](https://github.com/gulinodesign-maker/EMT/actions/runs/43901117533); avvio 2026-11-16T15:52:16Z UTC; aggiornamento finale 2026-11-16T15:52:47Z UTC; registrazione 2026-11-16T15:53:01+00:00 UTC; evento pull_request.
- **Commit:** [b8bd851a71f8](https://github.com/gulinodesign-maker/EMT/commit/b8bd851a71f80b5fd9545c4b2b5b68702006f19c); versione **1.0**; build **97**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py.

<!-- EMT_RUN:43900452734:ATTEMPT:1 -->
### 2026-11-16T15:48:44Z — CI #299 · build-97-cockpit-music · tentativo 1

- **Esecuzione:** [GitHub Actions 43900452734](https://github.com/gulinodesign-maker/EMT/actions/runs/43900452734); avvio 2026-11-16T15:48:44Z UTC; aggiornamento finale 2026-11-16T15:49:35Z UTC; registrazione 2026-11-16T15:49:45+00:00 UTC; evento pull_request.
- **Commit:** [d17b6ad2f499](https://github.com/gulinodesign-maker/EMT/commit/d17b6ad2f499f40d6a2d476c0613626c3b619528); versione **1.0**; build **97**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Ecojumbo/Views/EcoMusicCockpitPanel.swift.

<!-- EMT_RUN:43900393744:ATTEMPT:1 -->
### 2026-11-16T15:48:25Z — CI #298 · build-97-cockpit-music · tentativo 1

- **Esecuzione:** [GitHub Actions 43900393744](https://github.com/gulinodesign-maker/EMT/actions/runs/43900393744); avvio 2026-11-16T15:48:25Z UTC; aggiornamento finale 2026-11-16T15:48:47Z UTC; registrazione 2026-11-16T15:49:01+00:00 UTC; evento pull_request.
- **Commit:** [1c7e7d8b0e38](https://github.com/gulinodesign-maker/EMT/commit/1c7e7d8b0e38eb2ef4d4ab6d9f7170157861a3b3); versione **1.0**; build **97**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build66_symmetry_ring.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_menu_orientation_build58.py.

<!-- EMT_RUN:43899426821:ATTEMPT:1 -->
### 2026-11-16T15:43:17Z — CI #295 · build-97-cockpit-music · tentativo 1

- **Esecuzione:** [GitHub Actions 43899426821](https://github.com/gulinodesign-maker/EMT/actions/runs/43899426821); avvio 2026-11-16T15:43:17Z UTC; aggiornamento finale 2026-11-16T15:45:20Z UTC; registrazione 2026-11-16T15:45:37+00:00 UTC; evento pull_request.
- **Commit:** [17aa582160e1](https://github.com/gulinodesign-maker/EMT/commit/17aa582160e1860021433722f6dc2c1b234e57d9); versione **1.0**; build **97**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py.

<!-- EMT_RUN:43899717597:ATTEMPT:1 -->
### 2026-11-16T15:44:50Z — CI #297 · build-97-cockpit-music · tentativo 1

- **Esecuzione:** [GitHub Actions 43899717597](https://github.com/gulinodesign-maker/EMT/actions/runs/43899717597); avvio 2026-11-16T15:44:50Z UTC; aggiornamento finale 2026-11-16T15:45:16Z UTC; registrazione 2026-11-16T15:45:27+00:00 UTC; evento pull_request.
- **Commit:** [e8544ef3bf6a](https://github.com/gulinodesign-maker/EMT/commit/e8544ef3bf6a253f274c8f8186f81894c81934ab); versione **1.0**; build **97**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build60_setup_navigation.py, Tests/verify_build65_ui.py, Tests/verify_cockpit.py, Tests/verify_telemetry_dock_build62.py.

<!-- EMT_RUN:43899492576:ATTEMPT:1 -->
### 2026-11-16T15:43:37Z — CI #296 · build-97-cockpit-music · tentativo 1

- **Esecuzione:** [GitHub Actions 43899492576](https://github.com/gulinodesign-maker/EMT/actions/runs/43899492576); avvio 2026-11-16T15:43:37Z UTC; aggiornamento finale 2026-11-16T15:44:03Z UTC; registrazione 2026-11-16T15:44:16+00:00 UTC; evento pull_request.
- **Commit:** [65b2f25965d0](https://github.com/gulinodesign-maker/EMT/commit/65b2f25965d0f0a00ac0034980c3cf7606796526); versione **1.0**; build **97**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py.

<!-- EMT_RUN:43898945313:ATTEMPT:1 -->
### 2026-11-16T15:40:41Z — CI #294 · build-97-cockpit-music · tentativo 1

- **Esecuzione:** [GitHub Actions 43898945313](https://github.com/gulinodesign-maker/EMT/actions/runs/43898945313); avvio 2026-11-16T15:40:41Z UTC; aggiornamento finale 2026-11-16T15:41:15Z UTC; registrazione 2026-11-16T15:41:27+00:00 UTC; evento pull_request.
- **Commit:** [942a1566a778](https://github.com/gulinodesign-maker/EMT/commit/942a1566a7784695fe63ea435b2ecbf13ac94b1c); versione **1.0**; build **97**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** STATO_PROGETTO.md.

<!-- EMT_RUN:43894439872:ATTEMPT:1 -->
### 2026-11-16T15:15:47Z — CI #293 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43894439872](https://github.com/gulinodesign-maker/EMT/actions/runs/43894439872); avvio 2026-11-16T15:15:47Z UTC; aggiornamento finale 2026-11-16T15:17:26Z UTC; registrazione 2026-11-16T15:17:40+00:00 UTC; evento push.
- **Commit:** [6b7d8c7026f3](https://github.com/gulinodesign-maker/EMT/commit/6b7d8c7026f3a6d071437b10a4bd12009ca1a8f9); versione **1.0**; build **96**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_build89_layer_edges.py, Tests/verify_build90_exterior_layer.py, Tests/verify_build91_top_bottom_fades.py, Tests/verify_build92_twenty_shades.py, Tests/verify_build93_geometry_preview.py, Tests/verify_build94_preview_dial_geometry.py, Tests/verify_build95_map_concentric.py, Tests/verify_build96_topbar_flush.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43893977759:ATTEMPT:1 -->
### 2026-11-16T15:13:07Z — CI #292 · build-96-topbar-gradient-flush-metal · tentativo 1

- **Esecuzione:** [GitHub Actions 43893977759](https://github.com/gulinodesign-maker/EMT/actions/runs/43893977759); avvio 2026-11-16T15:13:07Z UTC; aggiornamento finale 2026-11-16T15:14:57Z UTC; registrazione 2026-11-16T15:15:07+00:00 UTC; evento pull_request.
- **Commit:** [882240d575ce](https://github.com/gulinodesign-maker/EMT/commit/882240d575ce744b2b5e5a1d60efc8d80740cd14); versione **1.0**; build **96**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43887263116:ATTEMPT:1 -->
### 2026-11-16T14:35:11Z — CI #291 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43887263116](https://github.com/gulinodesign-maker/EMT/actions/runs/43887263116); avvio 2026-11-16T14:35:11Z UTC; aggiornamento finale 2026-11-16T14:38:32Z UTC; registrazione 2026-11-16T14:38:43+00:00 UTC; evento push.
- **Commit:** [4e60e67fe735](https://github.com/gulinodesign-maker/EMT/commit/4e60e67fe735311ae528f1da68758d8fbe554146); versione **1.0**; build **95**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/CockpitTabs.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_build89_layer_edges.py, Tests/verify_build90_exterior_layer.py, Tests/verify_build91_top_bottom_fades.py, Tests/verify_build92_twenty_shades.py, Tests/verify_build93_geometry_preview.py, Tests/verify_build94_preview_dial_geometry.py, Tests/verify_build95_map_concentric.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_landscape_geometry.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_map_contour_build48.py, Tests/verify_map_fade_build47.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43886515367:ATTEMPT:1 -->
### 2026-11-16T14:30:52Z — CI #290 · build-95-map-2pt-concentric-ring · tentativo 1

- **Esecuzione:** [GitHub Actions 43886515367](https://github.com/gulinodesign-maker/EMT/actions/runs/43886515367); avvio 2026-11-16T14:30:52Z UTC; aggiornamento finale 2026-11-16T14:34:30Z UTC; registrazione 2026-11-16T14:34:43+00:00 UTC; evento pull_request.
- **Commit:** [02ffe581756a](https://github.com/gulinodesign-maker/EMT/commit/02ffe581756a4a93effe814189b837e24aecc3db); versione **1.0**; build **95**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_landscape_geometry.py.

<!-- EMT_RUN:43886248948:ATTEMPT:1 -->
### 2026-11-16T14:29:23Z — CI #289 · build-95-map-2pt-concentric-ring · tentativo 1

- **Esecuzione:** [GitHub Actions 43886248948](https://github.com/gulinodesign-maker/EMT/actions/runs/43886248948); avvio 2026-11-16T14:29:23Z UTC; aggiornamento finale 2026-11-16T14:29:54Z UTC; registrazione 2026-11-16T14:30:05+00:00 UTC; evento pull_request.
- **Commit:** [83c98085619f](https://github.com/gulinodesign-maker/EMT/commit/83c98085619f954d79d7cb344b120365cc2135c6); versione **1.0**; build **95**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py.

<!-- EMT_RUN:43886034114:ATTEMPT:1 -->
### 2026-11-16T14:28:09Z — CI #288 · build-95-map-2pt-concentric-ring · tentativo 1

- **Esecuzione:** [GitHub Actions 43886034114](https://github.com/gulinodesign-maker/EMT/actions/runs/43886034114); avvio 2026-11-16T14:28:09Z UTC; aggiornamento finale 2026-11-16T14:28:41Z UTC; registrazione 2026-11-16T14:28:52+00:00 UTC; evento pull_request.
- **Commit:** [defc4405280f](https://github.com/gulinodesign-maker/EMT/commit/defc4405280f3f3167c4ba6428249011b0d23b7e); versione **1.0**; build **95**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py.

<!-- EMT_RUN:43885803302:ATTEMPT:1 -->
### 2026-11-16T14:26:51Z — CI #287 · build-95-map-2pt-concentric-ring · tentativo 1

- **Esecuzione:** [GitHub Actions 43885803302](https://github.com/gulinodesign-maker/EMT/actions/runs/43885803302); avvio 2026-11-16T14:26:51Z UTC; aggiornamento finale 2026-11-16T14:27:21Z UTC; registrazione 2026-11-16T14:27:32+00:00 UTC; evento pull_request.
- **Commit:** [3b081b8995f1](https://github.com/gulinodesign-maker/EMT/commit/3b081b8995f1a49f03e1b49f551052919a6e1c86); versione **1.0**; build **95**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py.

<!-- EMT_RUN:43885530427:ATTEMPT:1 -->
### 2026-11-16T14:25:18Z — CI #286 · build-95-map-2pt-concentric-ring · tentativo 1

- **Esecuzione:** [GitHub Actions 43885530427](https://github.com/gulinodesign-maker/EMT/actions/runs/43885530427); avvio 2026-11-16T14:25:18Z UTC; aggiornamento finale 2026-11-16T14:25:43Z UTC; registrazione 2026-11-16T14:25:59+00:00 UTC; evento pull_request.
- **Commit:** [59d34267c5bf](https://github.com/gulinodesign-maker/EMT/commit/59d34267c5bf1cb3e2bc8b16f01ccd4ea860fa60); versione **1.0**; build **95**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43875659476:ATTEMPT:1 -->
### 2026-11-16T13:25:46Z — CI #285 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43875659476](https://github.com/gulinodesign-maker/EMT/actions/runs/43875659476); avvio 2026-11-16T13:25:46Z UTC; aggiornamento finale 2026-11-16T13:27:13Z UTC; registrazione 2026-11-16T13:27:30+00:00 UTC; evento push.
- **Commit:** [09f5d104e961](https://github.com/gulinodesign-maker/EMT/commit/09f5d104e961daff8a66bfc7b3e34e4b259438cd); versione **1.0**; build **94**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/CockpitTabs.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_build89_layer_edges.py, Tests/verify_build90_exterior_layer.py, Tests/verify_build91_top_bottom_fades.py, Tests/verify_build92_twenty_shades.py, Tests/verify_build93_geometry_preview.py, Tests/verify_build94_preview_dial_geometry.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43875241936:ATTEMPT:1 -->
### 2026-11-16T13:23:09Z — CI #284 · build-94-preview-icons-dial-profile · tentativo 1

- **Esecuzione:** [GitHub Actions 43875241936](https://github.com/gulinodesign-maker/EMT/actions/runs/43875241936); avvio 2026-11-16T13:23:09Z UTC; aggiornamento finale 2026-11-16T13:25:16Z UTC; registrazione 2026-11-16T13:25:28+00:00 UTC; evento pull_request.
- **Commit:** [e69031258fb6](https://github.com/gulinodesign-maker/EMT/commit/e69031258fb6c7092038b13e9eea6f460978f89f); versione **1.0**; build **94**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43871992012:ATTEMPT:1 -->
### 2026-11-16T13:02:21Z — CI #283 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43871992012](https://github.com/gulinodesign-maker/EMT/actions/runs/43871992012); avvio 2026-11-16T13:02:21Z UTC; aggiornamento finale 2026-11-16T13:06:12Z UTC; registrazione 2026-11-16T13:06:26+00:00 UTC; evento push.
- **Commit:** [3984aedf7da9](https://github.com/gulinodesign-maker/EMT/commit/3984aedf7da9ac665019c1a290b0758f3495bb59); versione **1.0**; build **93**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/CockpitTabs.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_build89_layer_edges.py, Tests/verify_build90_exterior_layer.py, Tests/verify_build91_top_bottom_fades.py, Tests/verify_build92_twenty_shades.py, Tests/verify_build93_geometry_preview.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_landscape_geometry.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43871551413:ATTEMPT:1 -->
### 2026-11-16T12:59:28Z — CI #282 · build-93-cockpit-preview-geometry · tentativo 1

- **Esecuzione:** [GitHub Actions 43871551413](https://github.com/gulinodesign-maker/EMT/actions/runs/43871551413); avvio 2026-11-16T12:59:28Z UTC; aggiornamento finale 2026-11-16T13:01:49Z UTC; registrazione 2026-11-16T13:02:04+00:00 UTC; evento pull_request.
- **Commit:** [768805592b1a](https://github.com/gulinodesign-maker/EMT/commit/768805592b1af30f4d5c90e182c29792846a397d); versione **1.0**; build **93**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_landscape_geometry.py.

<!-- EMT_RUN:43871281049:ATTEMPT:1 -->
### 2026-11-16T12:57:37Z — CI #281 · build-93-cockpit-preview-geometry · tentativo 1

- **Esecuzione:** [GitHub Actions 43871281049](https://github.com/gulinodesign-maker/EMT/actions/runs/43871281049); avvio 2026-11-16T12:57:37Z UTC; aggiornamento finale 2026-11-16T12:58:08Z UTC; registrazione 2026-11-16T12:58:18+00:00 UTC; evento pull_request.
- **Commit:** [0d82f2fe464c](https://github.com/gulinodesign-maker/EMT/commit/0d82f2fe464c4407d24911fe5c32b06650e4cbcf); versione **1.0**; build **93**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py.

<!-- EMT_RUN:43871041741:ATTEMPT:1 -->
### 2026-11-16T12:56:02Z — CI #280 · build-93-cockpit-preview-geometry · tentativo 1

- **Esecuzione:** [GitHub Actions 43871041741](https://github.com/gulinodesign-maker/EMT/actions/runs/43871041741); avvio 2026-11-16T12:56:02Z UTC; aggiornamento finale 2026-11-16T12:56:32Z UTC; registrazione 2026-11-16T12:56:44+00:00 UTC; evento pull_request.
- **Commit:** [2c0c8978c237](https://github.com/gulinodesign-maker/EMT/commit/2c0c8978c23709731c362fd04316f52d01b5fd56); versione **1.0**; build **93**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build91_top_bottom_fades.py.

<!-- EMT_RUN:43870807269:ATTEMPT:1 -->
### 2026-11-16T12:54:31Z — CI #279 · build-93-cockpit-preview-geometry · tentativo 1

- **Esecuzione:** [GitHub Actions 43870807269](https://github.com/gulinodesign-maker/EMT/actions/runs/43870807269); avvio 2026-11-16T12:54:31Z UTC; aggiornamento finale 2026-11-16T12:55:03Z UTC; registrazione 2026-11-16T12:55:13+00:00 UTC; evento pull_request.
- **Commit:** [c514c3122fdb](https://github.com/gulinodesign-maker/EMT/commit/c514c3122fdbe97bbb3a5a4278acd0d0ec0cc716); versione **1.0**; build **93**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build66_symmetry_ring.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build93_geometry_preview.py, Tests/verify_custom_themes_build63.py.

<!-- EMT_RUN:43870495536:ATTEMPT:1 -->
### 2026-11-16T12:52:26Z — CI #278 · build-93-cockpit-preview-geometry · tentativo 1

- **Esecuzione:** [GitHub Actions 43870495536](https://github.com/gulinodesign-maker/EMT/actions/runs/43870495536); avvio 2026-11-16T12:52:26Z UTC; aggiornamento finale 2026-11-16T12:52:50Z UTC; registrazione 2026-11-16T12:53:01+00:00 UTC; evento pull_request.
- **Commit:** [192bbbdbb4f5](https://github.com/gulinodesign-maker/EMT/commit/192bbbdbb4f533516d2ddd369f68f1d616070722); versione **1.0**; build **93**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43861189082:ATTEMPT:1 -->
### 2026-11-16T11:50:03Z — CI #277 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43861189082](https://github.com/gulinodesign-maker/EMT/actions/runs/43861189082); avvio 2026-11-16T11:50:03Z UTC; aggiornamento finale 2026-11-16T11:52:42Z UTC; registrazione 2026-11-16T11:52:53+00:00 UTC; evento push.
- **Commit:** [9a09db3eb272](https://github.com/gulinodesign-maker/EMT/commit/9a09db3eb272e6298681927745c1557f6eaf2356); versione **1.0**; build **92**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitTabs.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_build89_layer_edges.py, Tests/verify_build90_exterior_layer.py, Tests/verify_build91_top_bottom_fades.py, Tests/verify_build92_twenty_shades.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43860729581:ATTEMPT:1 -->
### 2026-11-16T11:46:47Z — CI #276 · build-92-color-picker-20-base-shades · tentativo 1

- **Esecuzione:** [GitHub Actions 43860729581](https://github.com/gulinodesign-maker/EMT/actions/runs/43860729581); avvio 2026-11-16T11:46:47Z UTC; aggiornamento finale 2026-11-16T11:49:36Z UTC; registrazione 2026-11-16T11:49:48+00:00 UTC; evento pull_request.
- **Commit:** [0098f423ab63](https://github.com/gulinodesign-maker/EMT/commit/0098f423ab63906b794319c2abbf5aa64d295658); versione **1.0**; build **92**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_custom_themes_build63.py.

<!-- EMT_RUN:43856374450:ATTEMPT:1 -->
### 2026-11-16T11:17:03Z — CI #275 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43856374450](https://github.com/gulinodesign-maker/EMT/actions/runs/43856374450); avvio 2026-11-16T11:17:03Z UTC; aggiornamento finale 2026-11-16T11:18:37Z UTC; registrazione 2026-11-16T11:18:47+00:00 UTC; evento push.
- **Commit:** [4161b3fb6a77](https://github.com/gulinodesign-maker/EMT/commit/4161b3fb6a77121a87acf5bb4a23d601d1be7a58); versione **1.0**; build **91**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/CockpitTabs.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_build89_layer_edges.py, Tests/verify_build90_exterior_layer.py, Tests/verify_build91_top_bottom_fades.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43855916659:ATTEMPT:1 -->
### 2026-11-16T11:13:59Z — CI #274 · build-91-top-bottom-fades · tentativo 1

- **Esecuzione:** [GitHub Actions 43855916659](https://github.com/gulinodesign-maker/EMT/actions/runs/43855916659); avvio 2026-11-16T11:13:59Z UTC; aggiornamento finale 2026-11-16T11:16:28Z UTC; registrazione 2026-11-16T11:16:39+00:00 UTC; evento pull_request.
- **Commit:** [a6987611e403](https://github.com/gulinodesign-maker/EMT/commit/a6987611e4036f8945ac8fb0236b55f39aeb8e2b); versione **1.0**; build **91**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_build90_exterior_layer.py.

<!-- EMT_RUN:43855751311:ATTEMPT:1 -->
### 2026-11-16T11:12:54Z — CI #273 · build-91-top-bottom-fades · tentativo 1

- **Esecuzione:** [GitHub Actions 43855751311](https://github.com/gulinodesign-maker/EMT/actions/runs/43855751311); avvio 2026-11-16T11:12:54Z UTC; aggiornamento finale 2026-11-16T11:13:26Z UTC; registrazione 2026-11-16T11:13:36+00:00 UTC; evento pull_request.
- **Commit:** [f5aad50d7cec](https://github.com/gulinodesign-maker/EMT/commit/f5aad50d7cecc629009910ec32ec449589267e6e); versione **1.0**; build **91**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43851843614:ATTEMPT:1 -->
### 2026-11-16T10:46:32Z — CI #272 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43851843614](https://github.com/gulinodesign-maker/EMT/actions/runs/43851843614); avvio 2026-11-16T10:46:32Z UTC; aggiornamento finale 2026-11-16T10:48:01Z UTC; registrazione 2026-11-16T10:48:13+00:00 UTC; evento push.
- **Commit:** [56e66fc4e475](https://github.com/gulinodesign-maker/EMT/commit/56e66fc4e475eec1f53fc2da089c84e18e08f079); versione **1.0**; build **90**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_build89_layer_edges.py, Tests/verify_build90_exterior_layer.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43851420309:ATTEMPT:1 -->
### 2026-11-16T10:43:40Z — CI #271 · build-90-exclude-layer-from-dial-bridge · tentativo 1

- **Esecuzione:** [GitHub Actions 43851420309](https://github.com/gulinodesign-maker/EMT/actions/runs/43851420309); avvio 2026-11-16T10:43:40Z UTC; aggiornamento finale 2026-11-16T10:45:53Z UTC; registrazione 2026-11-16T10:46:05+00:00 UTC; evento pull_request.
- **Commit:** [46fcf8341fb2](https://github.com/gulinodesign-maker/EMT/commit/46fcf8341fb27bcf549eaf4caacdad5c9750fb48); versione **1.0**; build **90**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43848354579:ATTEMPT:1 -->
### 2026-11-16T10:23:12Z — CI #270 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43848354579](https://github.com/gulinodesign-maker/EMT/actions/runs/43848354579); avvio 2026-11-16T10:23:12Z UTC; aggiornamento finale 2026-11-16T10:25:03Z UTC; registrazione 2026-11-16T10:25:12+00:00 UTC; evento push.
- **Commit:** [9beda30a0e42](https://github.com/gulinodesign-maker/EMT/commit/9beda30a0e421e6986ffe514bf4e9b258c4dff2c); versione **1.0**; build **89**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_build89_layer_edges.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43848037898:ATTEMPT:1 -->
### 2026-11-16T10:21:02Z — CI #269 · build-89-topbar-profile-correction · tentativo 1

- **Esecuzione:** [GitHub Actions 43848037898](https://github.com/gulinodesign-maker/EMT/actions/runs/43848037898); avvio 2026-11-16T10:21:02Z UTC; aggiornamento finale 2026-11-16T10:22:50Z UTC; registrazione 2026-11-16T10:23:00+00:00 UTC; evento pull_request.
- **Commit:** [7ef00426bbc5](https://github.com/gulinodesign-maker/EMT/commit/7ef00426bbc53bcb82a0f46797378fe33cb81645); versione **1.0**; build **89**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43845607976:ATTEMPT:1 -->
### 2026-11-16T10:05:07Z — CI #268 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43845607976](https://github.com/gulinodesign-maker/EMT/actions/runs/43845607976); avvio 2026-11-16T10:05:07Z UTC; aggiornamento finale 2026-11-16T10:07:58Z UTC; registrazione 2026-11-16T10:08:09+00:00 UTC; evento push.
- **Commit:** [38ccecf05df8](https://github.com/gulinodesign-maker/EMT/commit/38ccecf05df824d037e29b7c4297115fbfa6ceff); versione **1.0**; build **88**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/CockpitTabs.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43845274220:ATTEMPT:1 -->
### 2026-11-16T10:02:57Z — CI #267 · build-88-topbar-layer-gradient-glow · tentativo 1

- **Esecuzione:** [GitHub Actions 43845274220](https://github.com/gulinodesign-maker/EMT/actions/runs/43845274220); avvio 2026-11-16T10:02:57Z UTC; aggiornamento finale 2026-11-16T10:04:32Z UTC; registrazione 2026-11-16T10:04:48+00:00 UTC; evento pull_request.
- **Commit:** [f0696766e53a](https://github.com/gulinodesign-maker/EMT/commit/f0696766e53aee8e01e8899258879fe4027717b1); versione **1.0**; build **88**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_build68_gradient_layout.py.

<!-- EMT_RUN:43845264828:ATTEMPT:1 -->
### 2026-11-16T10:02:53Z — CI #266 · build-88-topbar-layer-gradient-glow · tentativo 1

- **Esecuzione:** [GitHub Actions 43845264828](https://github.com/gulinodesign-maker/EMT/actions/runs/43845264828); avvio 2026-11-16T10:02:53Z UTC; aggiornamento finale 2026-11-16T10:03:25Z UTC; registrazione 2026-11-16T10:03:34+00:00 UTC; evento pull_request.
- **Commit:** [f4942aecdfe8](https://github.com/gulinodesign-maker/EMT/commit/f4942aecdfe8a1f69d98e24140d12c16e5a38392); versione **1.0**; build **88**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build69_filled_areas_profile.py.

<!-- EMT_RUN:43845112208:ATTEMPT:1 -->
### 2026-11-16T10:01:51Z — CI #265 · build-88-topbar-layer-gradient-glow · tentativo 1

- **Esecuzione:** [GitHub Actions 43845112208](https://github.com/gulinodesign-maker/EMT/actions/runs/43845112208); avvio 2026-11-16T10:01:51Z UTC; aggiornamento finale 2026-11-16T10:02:27Z UTC; registrazione 2026-11-16T10:02:36+00:00 UTC; evento pull_request.
- **Commit:** [9950e0f8bae7](https://github.com/gulinodesign-maker/EMT/commit/9950e0f8bae7414434fe5914c5446baf181ece38); versione **1.0**; build **88**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43832957576:ATTEMPT:1 -->
### 2026-11-16T08:39:06Z — CI #264 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43832957576](https://github.com/gulinodesign-maker/EMT/actions/runs/43832957576); avvio 2026-11-16T08:39:06Z UTC; aggiornamento finale 2026-11-16T08:41:57Z UTC; registrazione 2026-11-16T08:42:09+00:00 UTC; evento push.
- **Commit:** [0056f018e39d](https://github.com/gulinodesign-maker/EMT/commit/0056f018e39d2f6d91c0906322eb4b1262e00295); versione **1.0**; build **87**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_build87_gray_horizontal_power.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_landscape_geometry.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43832650763:ATTEMPT:1 -->
### 2026-11-16T08:36:50Z — CI #263 · build-87-gray-contours-horizontal-power · tentativo 1

- **Esecuzione:** [GitHub Actions 43832650763](https://github.com/gulinodesign-maker/EMT/actions/runs/43832650763); avvio 2026-11-16T08:36:50Z UTC; aggiornamento finale 2026-11-16T08:38:32Z UTC; registrazione 2026-11-16T08:38:43+00:00 UTC; evento pull_request.
- **Commit:** [a508adefd997](https://github.com/gulinodesign-maker/EMT/commit/a508adefd9976072f0d7fb0eb2bcfbb6cd2b4768); versione **1.0**; build **87**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py.

<!-- EMT_RUN:43832458117:ATTEMPT:1 -->
### 2026-11-16T08:35:27Z — CI #262 · build-87-gray-contours-horizontal-power · tentativo 1

- **Esecuzione:** [GitHub Actions 43832458117](https://github.com/gulinodesign-maker/EMT/actions/runs/43832458117); avvio 2026-11-16T08:35:27Z UTC; aggiornamento finale 2026-11-16T08:36:18Z UTC; registrazione 2026-11-16T08:36:28+00:00 UTC; evento pull_request.
- **Commit:** [7fd78a05ebf8](https://github.com/gulinodesign-maker/EMT/commit/7fd78a05ebf820839136d037eb82a644011dda1d); versione **1.0**; build **87**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build87_gray_horizontal_power.py.

<!-- EMT_RUN:43832314411:ATTEMPT:1 -->
### 2026-11-16T08:34:26Z — CI #261 · build-87-gray-contours-horizontal-power · tentativo 1

- **Esecuzione:** [GitHub Actions 43832314411](https://github.com/gulinodesign-maker/EMT/actions/runs/43832314411); avvio 2026-11-16T08:34:26Z UTC; aggiornamento finale 2026-11-16T08:35:07Z UTC; registrazione 2026-11-16T08:35:17+00:00 UTC; evento pull_request.
- **Commit:** [5e2f03bb1c4b](https://github.com/gulinodesign-maker/EMT/commit/5e2f03bb1c4b2ec055f7b73bdfa23dd1816caff9); versione **1.0**; build **87**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build85_left_topbar_off.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py.

<!-- EMT_RUN:43828068117:ATTEMPT:1 -->
### 2026-11-16T08:02:10Z — CI #260 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43828068117](https://github.com/gulinodesign-maker/EMT/actions/runs/43828068117); avvio 2026-11-16T08:02:10Z UTC; aggiornamento finale 2026-11-16T08:05:09Z UTC; registrazione 2026-11-16T08:05:26+00:00 UTC; evento push.
- **Commit:** [dfb7c394c5bb](https://github.com/gulinodesign-maker/EMT/commit/dfb7c394c5bb01bdcbe9bb730b60415f8185c7d0); versione **1.0**; build **86**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_build86_single_kw_bridge.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_landscape_geometry.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_map_contour_build48.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43827641996:ATTEMPT:1 -->
### 2026-11-16T07:58:52Z — CI #259 · build-86-single-kw-shorter-bridge · tentativo 1

- **Esecuzione:** [GitHub Actions 43827641996](https://github.com/gulinodesign-maker/EMT/actions/runs/43827641996); avvio 2026-11-16T07:58:52Z UTC; aggiornamento finale 2026-11-16T08:01:45Z UTC; registrazione 2026-11-16T08:01:55+00:00 UTC; evento pull_request.
- **Commit:** [5276d3bac02c](https://github.com/gulinodesign-maker/EMT/commit/5276d3bac02c1074ee87c009faf7d541909f39a0); versione **1.0**; build **86**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_build86_single_kw_bridge.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py.

<!-- EMT_RUN:43757412829:ATTEMPT:1 -->
### 2026-11-15T20:19:25Z — CI #258 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43757412829](https://github.com/gulinodesign-maker/EMT/actions/runs/43757412829); avvio 2026-11-15T20:19:25Z UTC; aggiornamento finale 2026-11-15T20:21:38Z UTC; registrazione 2026-11-15T20:21:48+00:00 UTC; evento push.
- **Commit:** [32c08831d276](https://github.com/gulinodesign-maker/EMT/commit/32c08831d2761d7be79dbb0795ecf80ee1370d01); versione **1.0**; build **85**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43757071893:ATTEMPT:1 -->
### 2026-11-15T20:15:51Z — CI #257 · build-85-remove-left-gray-topbar · tentativo 1

- **Esecuzione:** [GitHub Actions 43757071893](https://github.com/gulinodesign-maker/EMT/actions/runs/43757071893); avvio 2026-11-15T20:15:51Z UTC; aggiornamento finale 2026-11-15T20:19:05Z UTC; registrazione 2026-11-15T20:19:12+00:00 UTC; evento pull_request.
- **Commit:** [db9a575421bb](https://github.com/gulinodesign-maker/EMT/commit/db9a575421bb19c707460305522a1552d38eae6e); versione **1.0**; build **85**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build85_left_topbar_off.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43750388207:ATTEMPT:1 -->
### 2026-11-15T19:05:01Z — CI #256 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43750388207](https://github.com/gulinodesign-maker/EMT/actions/runs/43750388207); avvio 2026-11-15T19:05:01Z UTC; aggiornamento finale 2026-11-15T19:07:29Z UTC; registrazione 2026-11-15T19:07:38+00:00 UTC; evento push.
- **Commit:** [d0c7118ae129](https://github.com/gulinodesign-maker/EMT/commit/d0c7118ae129c235d8c78185dc9cb99d85fab8b3); versione **1.0**; build **84**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build83_restore_81.py, Tests/verify_build84_left_topbar_off.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43750106560:ATTEMPT:1 -->
### 2026-11-15T19:02:13Z — CI #255 · build-84-remove-left-topbar-neon · tentativo 1

- **Esecuzione:** [GitHub Actions 43750106560](https://github.com/gulinodesign-maker/EMT/actions/runs/43750106560); avvio 2026-11-15T19:02:13Z UTC; aggiornamento finale 2026-11-15T19:04:30Z UTC; registrazione 2026-11-15T19:04:41+00:00 UTC; evento pull_request.
- **Commit:** [d77836d53a95](https://github.com/gulinodesign-maker/EMT/commit/d77836d53a959e06ed6defac822c132f2a6f8453); versione **1.0**; build **84**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build83_restore_81.py, Tests/verify_build84_left_topbar_off.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43739949152:ATTEMPT:1 -->
### 2026-11-15T17:14:09Z — CI #254 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43739949152](https://github.com/gulinodesign-maker/EMT/actions/runs/43739949152); avvio 2026-11-15T17:14:09Z UTC; aggiornamento finale 2026-11-15T17:16:20Z UTC; registrazione 2026-11-15T17:16:30+00:00 UTC; evento push.
- **Commit:** [ce2b1e33695d](https://github.com/gulinodesign-maker/EMT/commit/ce2b1e33695de2c7968c292a8f444f582b868485); versione **1.0**; build **83**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/EcojumboRootView.swift, Ecojumbo/Views/OtherViews.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build82_layered_power_cockpit.py, Tests/verify_build83_restore_81.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_landscape_geometry.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43739653928:ATTEMPT:1 -->
### 2026-11-15T17:10:58Z — CI #253 · build-83-restore-81 · tentativo 1

- **Esecuzione:** [GitHub Actions 43739653928](https://github.com/gulinodesign-maker/EMT/actions/runs/43739653928); avvio 2026-11-15T17:10:58Z UTC; aggiornamento finale 2026-11-15T17:13:48Z UTC; registrazione 2026-11-15T17:13:57+00:00 UTC; evento pull_request.
- **Commit:** [a6ec8cfc796f](https://github.com/gulinodesign-maker/EMT/commit/a6ec8cfc796f9ede6adf43e2117ab5a1804df18f); versione **1.0**; build **83**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py.

<!-- EMT_RUN:43739318732:ATTEMPT:1 -->
### 2026-11-15T17:07:29Z — CI #252 · build-83-restore-81 · tentativo 1

- **Esecuzione:** [GitHub Actions 43739318732](https://github.com/gulinodesign-maker/EMT/actions/runs/43739318732); avvio 2026-11-15T17:07:29Z UTC; aggiornamento finale 2026-11-15T17:07:54Z UTC; registrazione 2026-11-15T17:08:04+00:00 UTC; evento pull_request.
- **Commit:** [1f3ecc7823ad](https://github.com/gulinodesign-maker/EMT/commit/1f3ecc7823ade13f6ddede260c39bb9a453c9c88); versione **1.0**; build **83**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/EcojumboRootView.swift, Ecojumbo/Views/OtherViews.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build82_layered_power_cockpit.py, Tests/verify_build83_restore_81.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_landscape_geometry.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43737774133:ATTEMPT:1 -->
### 2026-11-15T16:50:59Z — CI #251 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43737774133](https://github.com/gulinodesign-maker/EMT/actions/runs/43737774133); avvio 2026-11-15T16:50:59Z UTC; aggiornamento finale 2026-11-15T16:53:27Z UTC; registrazione 2026-11-15T16:53:35+00:00 UTC; evento push.
- **Commit:** [0b77ab6d79a7](https://github.com/gulinodesign-maker/EMT/commit/0b77ab6d79a747da91a31fd5a81f9a876a9ac958); versione **1.0**; build **82**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/EcojumboRootView.swift, Ecojumbo/Views/OtherViews.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build81_restore_76.py, Tests/verify_build82_layered_power_cockpit.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_landscape_geometry.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43737389403:ATTEMPT:1 -->
### 2026-11-15T16:46:52Z — CI #250 · build-82-layered-glass-power-scales · tentativo 1

- **Esecuzione:** [GitHub Actions 43737389403](https://github.com/gulinodesign-maker/EMT/actions/runs/43737389403); avvio 2026-11-15T16:46:52Z UTC; aggiornamento finale 2026-11-15T16:50:20Z UTC; registrazione 2026-11-15T16:50:32+00:00 UTC; evento pull_request.
- **Commit:** [f104b1714d64](https://github.com/gulinodesign-maker/EMT/commit/f104b1714d6459b08119fa0605e0c03868cd7b28); versione **1.0**; build **82**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_odo_reset_51.py.

<!-- EMT_RUN:43737266752:ATTEMPT:1 -->
### 2026-11-15T16:45:33Z — CI #249 · build-82-layered-glass-power-scales · tentativo 1

- **Esecuzione:** [GitHub Actions 43737266752](https://github.com/gulinodesign-maker/EMT/actions/runs/43737266752); avvio 2026-11-15T16:45:33Z UTC; aggiornamento finale 2026-11-15T16:46:05Z UTC; registrazione 2026-11-15T16:46:16+00:00 UTC; evento pull_request.
- **Commit:** [4144c38d9665](https://github.com/gulinodesign-maker/EMT/commit/4144c38d9665e3c9ca5c2926bb290ba4c38a0840); versione **1.0**; build **82**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_minimal_navigation_build59.py.

<!-- EMT_RUN:43737169018:ATTEMPT:1 -->
### 2026-11-15T16:44:33Z — CI #248 · build-82-layered-glass-power-scales · tentativo 1

- **Esecuzione:** [GitHub Actions 43737169018](https://github.com/gulinodesign-maker/EMT/actions/runs/43737169018); avvio 2026-11-15T16:44:33Z UTC; aggiornamento finale 2026-11-15T16:45:01Z UTC; registrazione 2026-11-15T16:45:09+00:00 UTC; evento pull_request.
- **Commit:** [d964146200f0](https://github.com/gulinodesign-maker/EMT/commit/d964146200f0e3637c0202f535a3c7d7ef063dc1); versione **1.0**; build **82**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_landscape_geometry.py, Tests/verify_speed_font_build53.py.

<!-- EMT_RUN:43737010759:ATTEMPT:1 -->
### 2026-11-15T16:42:48Z — CI #247 · build-82-layered-glass-power-scales · tentativo 1

- **Esecuzione:** [GitHub Actions 43737010759](https://github.com/gulinodesign-maker/EMT/actions/runs/43737010759); avvio 2026-11-15T16:42:48Z UTC; aggiornamento finale 2026-11-15T16:43:23Z UTC; registrazione 2026-11-15T16:43:34+00:00 UTC; evento pull_request.
- **Commit:** [49c2a8c75bff](https://github.com/gulinodesign-maker/EMT/commit/49c2a8c75bff82f944a734cc9b9c7ec50f453d01); versione **1.0**; build **82**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py.

<!-- EMT_RUN:43736893314:ATTEMPT:1 -->
### 2026-11-15T16:41:31Z — CI #246 · build-82-layered-glass-power-scales · tentativo 1

- **Esecuzione:** [GitHub Actions 43736893314](https://github.com/gulinodesign-maker/EMT/actions/runs/43736893314); avvio 2026-11-15T16:41:31Z UTC; aggiornamento finale 2026-11-15T16:41:54Z UTC; registrazione 2026-11-15T16:42:08+00:00 UTC; evento pull_request.
- **Commit:** [baf6274a5223](https://github.com/gulinodesign-maker/EMT/commit/baf6274a5223598de6039e113b95158284fb4853); versione **1.0**; build **82**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py.

<!-- EMT_RUN:43736746482:ATTEMPT:1 -->
### 2026-11-15T16:40:01Z — CI #245 · build-82-layered-glass-power-scales · tentativo 1

- **Esecuzione:** [GitHub Actions 43736746482](https://github.com/gulinodesign-maker/EMT/actions/runs/43736746482); avvio 2026-11-15T16:40:01Z UTC; aggiornamento finale 2026-11-15T16:40:30Z UTC; registrazione 2026-11-15T16:40:39+00:00 UTC; evento pull_request.
- **Commit:** [dc8d95736790](https://github.com/gulinodesign-maker/EMT/commit/dc8d95736790fdbf04c17c3016bb82dcd9510171); versione **1.0**; build **82**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build66_symmetry_ring.py.

<!-- EMT_RUN:43736565284:ATTEMPT:1 -->
### 2026-11-15T16:38:00Z — CI #244 · build-82-layered-glass-power-scales · tentativo 1

- **Esecuzione:** [GitHub Actions 43736565284](https://github.com/gulinodesign-maker/EMT/actions/runs/43736565284); avvio 2026-11-15T16:38:00Z UTC; aggiornamento finale 2026-11-15T16:38:29Z UTC; registrazione 2026-11-15T16:38:37+00:00 UTC; evento pull_request.
- **Commit:** [d46e70851182](https://github.com/gulinodesign-maker/EMT/commit/d46e708511826af01b3e2bc0846fae55233d1661); versione **1.0**; build **82**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43640050702:ATTEMPT:1 -->
### 2026-11-14T20:55:35Z — CI #243 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43640050702](https://github.com/gulinodesign-maker/EMT/actions/runs/43640050702); avvio 2026-11-14T20:55:35Z UTC; aggiornamento finale 2026-11-14T20:58:45Z UTC; registrazione 2026-11-14T20:58:55+00:00 UTC; evento push.
- **Commit:** [957327595640](https://github.com/gulinodesign-maker/EMT/commit/95732759564074fec15d71bacb4f2416a4a60b82); versione **1.0**; build **81**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build77_internal_power_dial.py, Tests/verify_build78_unified_scale.py, Tests/verify_build79_power_below_bridge.py, Tests/verify_build80_clean_power_tachometer.py, Tests/verify_build81_restore_76.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_landscape_geometry.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_map_contour_build48.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43639827805:ATTEMPT:1 -->
### 2026-11-14T20:52:58Z — CI #242 · build-81-restore-build-76 · tentativo 1

- **Esecuzione:** [GitHub Actions 43639827805](https://github.com/gulinodesign-maker/EMT/actions/runs/43639827805); avvio 2026-11-14T20:52:58Z UTC; aggiornamento finale 2026-11-14T20:55:17Z UTC; registrazione 2026-11-14T20:55:28+00:00 UTC; evento pull_request.
- **Commit:** [627ea3e6d5e0](https://github.com/gulinodesign-maker/EMT/commit/627ea3e6d5e042ebd3506ba926f4209faab0c03e); versione **1.0**; build **81**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_build81_restore_76.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43627659577:ATTEMPT:1 -->
### 2026-11-14T18:37:44Z — CI #240 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43627659577](https://github.com/gulinodesign-maker/EMT/actions/runs/43627659577); avvio 2026-11-14T18:37:44Z UTC; aggiornamento finale 2026-11-14T18:49:59Z UTC; registrazione 2026-11-14T18:50:09+00:00 UTC; evento pull_request.
- **Commit:** [2354b5ec44f7](https://github.com/gulinodesign-maker/EMT/commit/2354b5ec44f72749fe8c3f62ef70d21f658e1508); versione **1.0**; build **80**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_battery_rail_range49.py.

<!-- EMT_RUN:43627833374:ATTEMPT:1 -->
### 2026-11-14T18:39:39Z — CI #241 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43627833374](https://github.com/gulinodesign-maker/EMT/actions/runs/43627833374); avvio 2026-11-14T18:39:39Z UTC; aggiornamento finale 2026-11-14T18:40:15Z UTC; registrazione 2026-11-14T18:40:25+00:00 UTC; evento pull_request.
- **Commit:** [4255ed193e31](https://github.com/gulinodesign-maker/EMT/commit/4255ed193e315b723191b7193896e601278c3dd4); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/EMTMaterialSystem.swift.

<!-- EMT_RUN:43625891053:ATTEMPT:1 -->
### 2026-11-14T18:18:48Z — CI #235 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43625891053](https://github.com/gulinodesign-maker/EMT/actions/runs/43625891053); avvio 2026-11-14T18:18:48Z UTC; aggiornamento finale 2026-11-14T18:35:11Z UTC; registrazione 2026-11-14T18:35:21+00:00 UTC; evento pull_request.
- **Commit:** [fb644417e00a](https://github.com/gulinodesign-maker/EMT/commit/fb644417e00ac617c923bb966d74e513533ae81c); versione **1.0**; build **80**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** .github/workflows/ios-build.yml.

<!-- EMT_RUN:43627277751:ATTEMPT:1 -->
### 2026-11-14T18:33:39Z — CI #239 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43627277751](https://github.com/gulinodesign-maker/EMT/actions/runs/43627277751); avvio 2026-11-14T18:33:39Z UTC; aggiornamento finale 2026-11-14T18:34:01Z UTC; registrazione 2026-11-14T18:34:09+00:00 UTC; evento pull_request.
- **Commit:** [6111be326f59](https://github.com/gulinodesign-maker/EMT/commit/6111be326f59eead7604c63c6e44082ddf5022a6); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/EcojumboRootView.swift, Tests/verify_build60_setup_navigation.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_cockpit.py, Tests/verify_landscape_geometry.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py.

<!-- EMT_RUN:43625358959:ATTEMPT:1 -->
### 2026-11-14T18:13:13Z — CI #234 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43625358959](https://github.com/gulinodesign-maker/EMT/actions/runs/43625358959); avvio 2026-11-14T18:13:13Z UTC; aggiornamento finale 2026-11-14T18:25:25Z UTC; registrazione 2026-11-14T18:25:34+00:00 UTC; evento pull_request.
- **Commit:** [47010a7d9714](https://github.com/gulinodesign-maker/EMT/commit/47010a7d971440d79aece7035c439bc48457826b); versione **1.0**; build **80**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** .github/workflows/ios-build.yml.

<!-- EMT_RUN:43625143466:ATTEMPT:1 -->
### 2026-11-14T18:10:55Z — CI #233 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43625143466](https://github.com/gulinodesign-maker/EMT/actions/runs/43625143466); avvio 2026-11-14T18:10:55Z UTC; aggiornamento finale 2026-11-14T18:24:18Z UTC; registrazione 2026-11-14T18:24:32+00:00 UTC; evento pull_request.
- **Commit:** [9ce877551dc3](https://github.com/gulinodesign-maker/EMT/commit/9ce877551dc34efb7a4d9395491855ec99b2053f); versione **1.0**; build **80**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo/Views/CockpitComponents.swift.

<!-- EMT_RUN:43626190949:ATTEMPT:1 -->
### 2026-11-14T18:21:58Z — CI #237 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43626190949](https://github.com/gulinodesign-maker/EMT/actions/runs/43626190949); avvio 2026-11-14T18:21:58Z UTC; aggiornamento finale 2026-11-14T18:22:22Z UTC; registrazione 2026-11-14T18:22:33+00:00 UTC; evento pull_request.
- **Commit:** [466cac5d7dcf](https://github.com/gulinodesign-maker/EMT/commit/466cac5d7dcf0deced542353c219fc9501a398dd); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_landscape_geometry.py.

<!-- EMT_RUN:43624604755:ATTEMPT:1 -->
### 2026-11-14T18:05:09Z — CI #231 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43624604755](https://github.com/gulinodesign-maker/EMT/actions/runs/43624604755); avvio 2026-11-14T18:05:09Z UTC; aggiornamento finale 2026-11-14T18:22:04Z UTC; registrazione 2026-11-14T18:22:13+00:00 UTC; evento pull_request.
- **Commit:** [86a970dbc839](https://github.com/gulinodesign-maker/EMT/commit/86a970dbc839db10be5d44aca0ca2163eacfbf22); versione **1.0**; build **80**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** .github/workflows/ios-build.yml.

<!-- EMT_RUN:43626116939:ATTEMPT:1 -->
### 2026-11-14T18:21:09Z — CI #236 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43626116939](https://github.com/gulinodesign-maker/EMT/actions/runs/43626116939); avvio 2026-11-14T18:21:09Z UTC; aggiornamento finale 2026-11-14T18:21:56Z UTC; registrazione 2026-11-14T18:22:04+00:00 UTC; evento pull_request.
- **Commit:** [9d4242cbf376](https://github.com/gulinodesign-maker/EMT/commit/9d4242cbf376c64a7c0b64952df5ac1c2485cc20); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Ecojumbo/Views/CockpitComponents.swift.

<!-- EMT_RUN:43624777261:ATTEMPT:1 -->
### 2026-11-14T18:07:01Z — CI #232 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43624777261](https://github.com/gulinodesign-maker/EMT/actions/runs/43624777261); avvio 2026-11-14T18:07:01Z UTC; aggiornamento finale 2026-11-14T18:16:04Z UTC; registrazione 2026-11-14T18:16:14+00:00 UTC; evento pull_request.
- **Commit:** [73133f8dcf00](https://github.com/gulinodesign-maker/EMT/commit/73133f8dcf001181acc49de12d920af590442a66); versione **1.0**; build **80**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** .github/workflows/ios-build.yml.

<!-- EMT_RUN:43624285171:ATTEMPT:1 -->
### 2026-11-14T18:01:41Z — CI #230 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43624285171](https://github.com/gulinodesign-maker/EMT/actions/runs/43624285171); avvio 2026-11-14T18:01:41Z UTC; aggiornamento finale 2026-11-14T18:13:26Z UTC; registrazione 2026-11-14T18:13:35+00:00 UTC; evento pull_request.
- **Commit:** [7ba0e9d73b67](https://github.com/gulinodesign-maker/EMT/commit/7ba0e9d73b67172b140d553ee6701a7214b57d4f); versione **1.0**; build **80**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo/Views/EMTMaterialSystem.swift.

<!-- EMT_RUN:43624098058:ATTEMPT:1 -->
### 2026-11-14T17:59:51Z — CI #229 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43624098058](https://github.com/gulinodesign-maker/EMT/actions/runs/43624098058); avvio 2026-11-14T17:59:51Z UTC; aggiornamento finale 2026-11-14T18:01:37Z UTC; registrazione 2026-11-14T18:01:48+00:00 UTC; evento pull_request.
- **Commit:** [27fdf774fda9](https://github.com/gulinodesign-maker/EMT/commit/27fdf774fda93e14e5e2b0cd8574dece476dd0ab); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **fase riuscita, workflow complessivo failure**; Test protocollo JK Bluetooth (sola lettura): **fase riuscita, workflow complessivo failure**; Test barre dinamiche: **fase riuscita, workflow complessivo failure**.
- **Compilazione simulatore:** **FAILURE**.
- **Errori rilevati:** Compila app per simulatore iOS (senza firma Apple). Dettagli nei log GitHub.
- **File modificati nel commit:** tools/compare_visual_reference.py.

<!-- EMT_RUN:43624002421:ATTEMPT:1 -->
### 2026-11-14T17:58:44Z — CI #228 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43624002421](https://github.com/gulinodesign-maker/EMT/actions/runs/43624002421); avvio 2026-11-14T17:58:44Z UTC; aggiornamento finale 2026-11-14T18:00:02Z UTC; registrazione 2026-11-14T18:00:11+00:00 UTC; evento pull_request.
- **Commit:** [33458b68d20e](https://github.com/gulinodesign-maker/EMT/commit/33458b68d20e55a1d7abb4d6126739e4c6f4fda4); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **fase riuscita, workflow complessivo failure**; Test protocollo JK Bluetooth (sola lettura): **fase riuscita, workflow complessivo failure**; Test barre dinamiche: **fase riuscita, workflow complessivo failure**.
- **Compilazione simulatore:** **FAILURE**.
- **Errori rilevati:** Compila app per simulatore iOS (senza firma Apple). Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py.

<!-- EMT_RUN:43623935579:ATTEMPT:1 -->
### 2026-11-14T17:57:57Z — CI #226 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623935579](https://github.com/gulinodesign-maker/EMT/actions/runs/43623935579); avvio 2026-11-14T17:57:57Z UTC; aggiornamento finale 2026-11-14T17:58:28Z UTC; registrazione 2026-11-14T17:58:37+00:00 UTC; evento pull_request.
- **Commit:** [17986c436e1b](https://github.com/gulinodesign-maker/EMT/commit/17986c436e1baf88ccab49869c6a41ab50065bf1); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_landscape_geometry.py.

<!-- EMT_RUN:43623874409:ATTEMPT:1 -->
### 2026-11-14T17:57:15Z — CI #225 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623874409](https://github.com/gulinodesign-maker/EMT/actions/runs/43623874409); avvio 2026-11-14T17:57:15Z UTC; aggiornamento finale 2026-11-14T17:57:44Z UTC; registrazione 2026-11-14T17:57:54+00:00 UTC; evento pull_request.
- **Commit:** [795681634418](https://github.com/gulinodesign-maker/EMT/commit/7956816344186593f2ba3bf4590b2f3df7241df0); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_secondary_telemetry50.py.

<!-- EMT_RUN:43623863857:ATTEMPT:1 -->
### 2026-11-14T17:57:07Z — CI #224 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623863857](https://github.com/gulinodesign-maker/EMT/actions/runs/43623863857); avvio 2026-11-14T17:57:07Z UTC; aggiornamento finale 2026-11-14T17:57:31Z UTC; registrazione 2026-11-14T17:57:41+00:00 UTC; evento pull_request.
- **Commit:** [0f87fb0f12c5](https://github.com/gulinodesign-maker/EMT/commit/0f87fb0f12c5ff36ed03311ac0f15a85421738c3); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_custom_themes_build64.py.

<!-- EMT_RUN:43623813810:ATTEMPT:1 -->
### 2026-11-14T17:56:33Z — CI #223 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623813810](https://github.com/gulinodesign-maker/EMT/actions/runs/43623813810); avvio 2026-11-14T17:56:33Z UTC; aggiornamento finale 2026-11-14T17:56:52Z UTC; registrazione 2026-11-14T17:57:16+00:00 UTC; evento pull_request.
- **Commit:** [83581d82491c](https://github.com/gulinodesign-maker/EMT/commit/83581d82491ca4df70cb7f1c0114e66eeb4bdaf0); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Ecojumbo/Views/CockpitComponents.swift.

<!-- EMT_RUN:43623768890:ATTEMPT:1 -->
### 2026-11-14T17:56:02Z — CI #222 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623768890](https://github.com/gulinodesign-maker/EMT/actions/runs/43623768890); avvio 2026-11-14T17:56:02Z UTC; aggiornamento finale 2026-11-14T17:56:49Z UTC; registrazione 2026-11-14T17:57:00+00:00 UTC; evento pull_request.
- **Commit:** [bd22198f0537](https://github.com/gulinodesign-maker/EMT/commit/bd22198f0537b7eeb9122dee803e2fd3721eee4e); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_telemetry_dock_build62.py.

<!-- EMT_RUN:43623763161:ATTEMPT:1 -->
### 2026-11-14T17:55:58Z — CI #221 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623763161](https://github.com/gulinodesign-maker/EMT/actions/runs/43623763161); avvio 2026-11-14T17:55:58Z UTC; aggiornamento finale 2026-11-14T17:56:26Z UTC; registrazione 2026-11-14T17:56:35+00:00 UTC; evento pull_request.
- **Commit:** [0c5d9944bac1](https://github.com/gulinodesign-maker/EMT/commit/0c5d9944bac14f52c5325d7103a4b69007451851); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build66_symmetry_ring.py.

<!-- EMT_RUN:43623636299:ATTEMPT:1 -->
### 2026-11-14T17:54:32Z — CI #220 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623636299](https://github.com/gulinodesign-maker/EMT/actions/runs/43623636299); avvio 2026-11-14T17:54:32Z UTC; aggiornamento finale 2026-11-14T17:55:03Z UTC; registrazione 2026-11-14T17:55:12+00:00 UTC; evento pull_request.
- **Commit:** [0eb6506865bf](https://github.com/gulinodesign-maker/EMT/commit/0eb6506865bfd180a0c1b3bc4bd4292ce5aa479b); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** .github/workflows/ios-build.yml.

<!-- EMT_RUN:43623542623:ATTEMPT:1 -->
### 2026-11-14T17:53:28Z — CI #219 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623542623](https://github.com/gulinodesign-maker/EMT/actions/runs/43623542623); avvio 2026-11-14T17:53:28Z UTC; aggiornamento finale 2026-11-14T17:53:58Z UTC; registrazione 2026-11-14T17:54:11+00:00 UTC; evento pull_request.
- **Commit:** [995107f71073](https://github.com/gulinodesign-maker/EMT/commit/995107f7107355274f48d170f4d7f8d34cf41533); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build65_ui.py.

<!-- EMT_RUN:43623469026:ATTEMPT:1 -->
### 2026-11-14T17:52:39Z — CI #216 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623469026](https://github.com/gulinodesign-maker/EMT/actions/runs/43623469026); avvio 2026-11-14T17:52:39Z UTC; aggiornamento finale 2026-11-14T17:53:53Z UTC; registrazione 2026-11-14T17:54:02+00:00 UTC; evento pull_request.
- **Commit:** [d40aeba7e3fd](https://github.com/gulinodesign-maker/EMT/commit/d40aeba7e3fd5cf7985d69b871333dce005788f5); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build77_internal_power_dial.py.

<!-- EMT_RUN:43623475752:ATTEMPT:1 -->
### 2026-11-14T17:52:44Z — CI #217 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623475752](https://github.com/gulinodesign-maker/EMT/actions/runs/43623475752); avvio 2026-11-14T17:52:44Z UTC; aggiornamento finale 2026-11-14T17:53:12Z UTC; registrazione 2026-11-14T17:53:27+00:00 UTC; evento pull_request.
- **Commit:** [4cb172a8733a](https://github.com/gulinodesign-maker/EMT/commit/4cb172a8733a7a6d2c7fa776b751304efabefa74); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build79_power_below_bridge.py.

<!-- EMT_RUN:43623481988:ATTEMPT:1 -->
### 2026-11-14T17:52:48Z — CI #218 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623481988](https://github.com/gulinodesign-maker/EMT/actions/runs/43623481988); avvio 2026-11-14T17:52:48Z UTC; aggiornamento finale 2026-11-14T17:53:07Z UTC; registrazione 2026-11-14T17:53:17+00:00 UTC; evento pull_request.
- **Commit:** [f404023c24f8](https://github.com/gulinodesign-maker/EMT/commit/f404023c24f8fed0730fe45b17e1f546d08b8e30); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build80_clean_power_tachometer.py.

<!-- EMT_RUN:43623426343:ATTEMPT:1 -->
### 2026-11-14T17:52:10Z — CI #215 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623426343](https://github.com/gulinodesign-maker/EMT/actions/runs/43623426343); avvio 2026-11-14T17:52:10Z UTC; aggiornamento finale 2026-11-14T17:52:57Z UTC; registrazione 2026-11-14T17:53:06+00:00 UTC; evento pull_request.
- **Commit:** [0d56b0c485e0](https://github.com/gulinodesign-maker/EMT/commit/0d56b0c485e052fa8bf68890f4ee377b76300e4e); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build75_metal_topbar_speed_shadow.py.

<!-- EMT_RUN:43623418154:ATTEMPT:1 -->
### 2026-11-14T17:52:05Z — CI #214 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623418154](https://github.com/gulinodesign-maker/EMT/actions/runs/43623418154); avvio 2026-11-14T17:52:05Z UTC; aggiornamento finale 2026-11-14T17:52:45Z UTC; registrazione 2026-11-14T17:52:53+00:00 UTC; evento pull_request.
- **Commit:** [0fc6164cfdfa](https://github.com/gulinodesign-maker/EMT/commit/0fc6164cfdfa9a71ca31c1736b7d58a615403202); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build73_settings_glow_speed.py.

<!-- EMT_RUN:43623357167:ATTEMPT:1 -->
### 2026-11-14T17:51:23Z — CI #212 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623357167](https://github.com/gulinodesign-maker/EMT/actions/runs/43623357167); avvio 2026-11-14T17:51:23Z UTC; aggiornamento finale 2026-11-14T17:52:00Z UTC; registrazione 2026-11-14T17:52:19+00:00 UTC; evento pull_request.
- **Commit:** [9782a2fa4036](https://github.com/gulinodesign-maker/EMT/commit/9782a2fa4036ef8a3dc0452509162325a6bb5b6a); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build69_filled_areas_profile.py.

<!-- EMT_RUN:43623363294:ATTEMPT:1 -->
### 2026-11-14T17:51:28Z — CI #213 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623363294](https://github.com/gulinodesign-maker/EMT/actions/runs/43623363294); avvio 2026-11-14T17:51:28Z UTC; aggiornamento finale 2026-11-14T17:51:58Z UTC; registrazione 2026-11-14T17:52:09+00:00 UTC; evento pull_request.
- **Commit:** [f5a8f5ded298](https://github.com/gulinodesign-maker/EMT/commit/f5a8f5ded29802ef48c17d63f9d825077d9f3eaa); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build71_single_topbar.py.

<!-- EMT_RUN:43623259407:ATTEMPT:1 -->
### 2026-11-14T17:50:18Z — CI #210 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623259407](https://github.com/gulinodesign-maker/EMT/actions/runs/43623259407); avvio 2026-11-14T17:50:18Z UTC; aggiornamento finale 2026-11-14T17:50:55Z UTC; registrazione 2026-11-14T17:51:11+00:00 UTC; evento pull_request.
- **Commit:** [84aee215209f](https://github.com/gulinodesign-maker/EMT/commit/84aee215209f6e78ff069462c608bb52831a79ff); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_telemetry_dock_build62.py.

<!-- EMT_RUN:43623266066:ATTEMPT:1 -->
### 2026-11-14T17:50:22Z — CI #211 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623266066](https://github.com/gulinodesign-maker/EMT/actions/runs/43623266066); avvio 2026-11-14T17:50:22Z UTC; aggiornamento finale 2026-11-14T17:50:50Z UTC; registrazione 2026-11-14T17:51:01+00:00 UTC; evento pull_request.
- **Commit:** [0014865aa28e](https://github.com/gulinodesign-maker/EMT/commit/0014865aa28ebd69cf0bcdc1836506e1422136ab); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build66_symmetry_ring.py.

<!-- EMT_RUN:43623059437:ATTEMPT:1 -->
### 2026-11-14T17:48:02Z — CI #209 · redesign-hyperrealistic-neon-preview · tentativo 1

- **Esecuzione:** [GitHub Actions 43623059437](https://github.com/gulinodesign-maker/EMT/actions/runs/43623059437); avvio 2026-11-14T17:48:02Z UTC; aggiornamento finale 2026-11-14T17:48:31Z UTC; registrazione 2026-11-14T17:48:41+00:00 UTC; evento pull_request.
- **Commit:** [4b0f61db3889](https://github.com/gulinodesign-maker/EMT/commit/4b0f61db38893fd442454be3d63307ea10eb63f1); versione **1.0**; build **80**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** STATO_PROGETTO.md.

<!-- EMT_RUN:43618637862:ATTEMPT:1 -->
### 2026-11-14T16:59:56Z — CI #208 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43618637862](https://github.com/gulinodesign-maker/EMT/actions/runs/43618637862); avvio 2026-11-14T16:59:56Z UTC; aggiornamento finale 2026-11-14T17:03:21Z UTC; registrazione 2026-11-14T17:03:30+00:00 UTC; evento push.
- **Commit:** [d17b3f658afb](https://github.com/gulinodesign-maker/EMT/commit/d17b3f658afb6c1d4304a050a6a7026e9e304357); versione **1.0**; build **80**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build77_internal_power_dial.py, Tests/verify_build78_unified_scale.py, Tests/verify_build79_power_below_bridge.py, Tests/verify_build80_clean_power_tachometer.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43618349535:ATTEMPT:1 -->
### 2026-11-14T16:56:39Z — CI #207 · build-80-clean-power-ticks-smaller-dial · tentativo 1

- **Esecuzione:** [GitHub Actions 43618349535](https://github.com/gulinodesign-maker/EMT/actions/runs/43618349535); avvio 2026-11-14T16:56:39Z UTC; aggiornamento finale 2026-11-14T16:59:20Z UTC; registrazione 2026-11-14T16:59:28+00:00 UTC; evento pull_request.
- **Commit:** [d2cc4800866b](https://github.com/gulinodesign-maker/EMT/commit/d2cc4800866bb40a4c353a142ff9463d8333417e); versione **1.0**; build **80**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_version.py.

<!-- EMT_RUN:43614497225:ATTEMPT:1 -->
### 2026-11-14T16:14:15Z — CI #206 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43614497225](https://github.com/gulinodesign-maker/EMT/actions/runs/43614497225); avvio 2026-11-14T16:14:15Z UTC; aggiornamento finale 2026-11-14T16:16:40Z UTC; registrazione 2026-11-14T16:16:50+00:00 UTC; evento push.
- **Commit:** [e176cf8b7246](https://github.com/gulinodesign-maker/EMT/commit/e176cf8b72468e07a8729a437ef049b9e77af75d); versione **1.0**; build **79**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build77_internal_power_dial.py, Tests/verify_build78_unified_scale.py, Tests/verify_build79_power_below_bridge.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43614183223:ATTEMPT:1 -->
### 2026-11-14T16:10:52Z — CI #205 · build-79-power-bridge-ratio-speed-reset · tentativo 1

- **Esecuzione:** [GitHub Actions 43614183223](https://github.com/gulinodesign-maker/EMT/actions/runs/43614183223); avvio 2026-11-14T16:10:52Z UTC; aggiornamento finale 2026-11-14T16:13:39Z UTC; registrazione 2026-11-14T16:13:50+00:00 UTC; evento pull_request.
- **Commit:** [4164d66ba28c](https://github.com/gulinodesign-maker/EMT/commit/4164d66ba28c4051e568c48f255adcfcf66584e8); versione **1.0**; build **79**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43603575447:ATTEMPT:1 -->
### 2026-11-14T14:11:37Z — CI #204 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43603575447](https://github.com/gulinodesign-maker/EMT/actions/runs/43603575447); avvio 2026-11-14T14:11:37Z UTC; aggiornamento finale 2026-11-14T14:13:49Z UTC; registrazione 2026-11-14T14:13:58+00:00 UTC; evento push.
- **Commit:** [873467077ec9](https://github.com/gulinodesign-maker/EMT/commit/873467077ec9a55a2b2d5e8d78c6a67922c3eec8); versione **1.0**; build **78**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build77_internal_power_dial.py, Tests/verify_build78_unified_scale.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43603378049:ATTEMPT:1 -->
### 2026-11-14T14:09:26Z — CI #203 · build-78-unified-scale-thin-bridge · tentativo 1

- **Esecuzione:** [GitHub Actions 43603378049](https://github.com/gulinodesign-maker/EMT/actions/runs/43603378049); avvio 2026-11-14T14:09:26Z UTC; aggiornamento finale 2026-11-14T14:11:21Z UTC; registrazione 2026-11-14T14:11:30+00:00 UTC; evento pull_request.
- **Commit:** [92a6ebfceb8b](https://github.com/gulinodesign-maker/EMT/commit/92a6ebfceb8b9b0d0f5f24d1c73920da5a3cd727); versione **1.0**; build **78**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43600345371:ATTEMPT:1 -->
### 2026-11-14T13:33:17Z — CI #202 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43600345371](https://github.com/gulinodesign-maker/EMT/actions/runs/43600345371); avvio 2026-11-14T13:33:17Z UTC; aggiornamento finale 2026-11-14T13:35:34Z UTC; registrazione 2026-11-14T13:35:44+00:00 UTC; evento push.
- **Commit:** [10ea33b8099f](https://github.com/gulinodesign-maker/EMT/commit/10ea33b8099f1e4141d1522dcf2acaf17d67d87e); versione **1.0**; build **77**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_build77_internal_power_dial.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_landscape_geometry.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_map_contour_build48.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43599981897:ATTEMPT:1 -->
### 2026-11-14T13:29:09Z — CI #201 · build-77-integrated-power-dial · tentativo 1

- **Esecuzione:** [GitHub Actions 43599981897](https://github.com/gulinodesign-maker/EMT/actions/runs/43599981897); avvio 2026-11-14T13:29:09Z UTC; aggiornamento finale 2026-11-14T13:32:36Z UTC; registrazione 2026-11-14T13:32:45+00:00 UTC; evento pull_request.
- **Commit:** [cb1f0e730a28](https://github.com/gulinodesign-maker/EMT/commit/cb1f0e730a289009ab2189e2a75eff2e0999a9f7); versione **1.0**; build **77**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_odo_reset_51.py.

<!-- EMT_RUN:43599891934:ATTEMPT:1 -->
### 2026-11-14T13:28:00Z — CI #200 · build-77-integrated-power-dial · tentativo 1

- **Esecuzione:** [GitHub Actions 43599891934](https://github.com/gulinodesign-maker/EMT/actions/runs/43599891934); avvio 2026-11-14T13:28:00Z UTC; aggiornamento finale 2026-11-14T13:28:40Z UTC; registrazione 2026-11-14T13:28:49+00:00 UTC; evento pull_request.
- **Commit:** [6ef7c85af824](https://github.com/gulinodesign-maker/EMT/commit/6ef7c85af824f767872685a4b99d9098d305b1bf); versione **1.0**; build **77**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_map_contour_build48.py.

<!-- EMT_RUN:43599804875:ATTEMPT:1 -->
### 2026-11-14T13:26:54Z — CI #199 · build-77-integrated-power-dial · tentativo 1

- **Esecuzione:** [GitHub Actions 43599804875](https://github.com/gulinodesign-maker/EMT/actions/runs/43599804875); avvio 2026-11-14T13:26:54Z UTC; aggiornamento finale 2026-11-14T13:27:28Z UTC; registrazione 2026-11-14T13:27:36+00:00 UTC; evento pull_request.
- **Commit:** [05295ca35d51](https://github.com/gulinodesign-maker/EMT/commit/05295ca35d51fd8deb856835b0fd3a4da0f08746); versione **1.0**; build **77**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_landscape_geometry.py.

<!-- EMT_RUN:43599708674:ATTEMPT:1 -->
### 2026-11-14T13:25:42Z — CI #198 · build-77-integrated-power-dial · tentativo 1

- **Esecuzione:** [GitHub Actions 43599708674](https://github.com/gulinodesign-maker/EMT/actions/runs/43599708674); avvio 2026-11-14T13:25:42Z UTC; aggiornamento finale 2026-11-14T13:26:08Z UTC; registrazione 2026-11-14T13:26:21+00:00 UTC; evento pull_request.
- **Commit:** [e6e7b9d5a1bb](https://github.com/gulinodesign-maker/EMT/commit/e6e7b9d5a1bb80570a7228d26f8c2f2115d05bbf); versione **1.0**; build **77**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py.

<!-- EMT_RUN:43599600664:ATTEMPT:1 -->
### 2026-11-14T13:24:26Z — CI #197 · build-77-integrated-power-dial · tentativo 1

- **Esecuzione:** [GitHub Actions 43599600664](https://github.com/gulinodesign-maker/EMT/actions/runs/43599600664); avvio 2026-11-14T13:24:26Z UTC; aggiornamento finale 2026-11-14T13:25:00Z UTC; registrazione 2026-11-14T13:25:08+00:00 UTC; evento pull_request.
- **Commit:** [32887f890f1f](https://github.com/gulinodesign-maker/EMT/commit/32887f890f1f9ca06ef47a6d502c2914ac8fb9df); versione **1.0**; build **77**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py.

<!-- EMT_RUN:43448468737:ATTEMPT:1 -->
### 2026-11-13T15:02:00Z — CI #196 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43448468737](https://github.com/gulinodesign-maker/EMT/actions/runs/43448468737); avvio 2026-11-13T15:02:00Z UTC; aggiornamento finale 2026-11-13T15:04:33Z UTC; registrazione 2026-11-13T15:04:45+00:00 UTC; evento push.
- **Commit:** [42e726142115](https://github.com/gulinodesign-maker/EMT/commit/42e72614211580dc771e06f9dc764f33a88fc194); versione **1.0**; build **76**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_build76_bridge_cutoff.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_map_contour_build48.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43447815528:ATTEMPT:1 -->
### 2026-11-13T14:58:06Z — CI #195 · build-76-gps-bridge-clean-cutoff · tentativo 1

- **Esecuzione:** [GitHub Actions 43447815528](https://github.com/gulinodesign-maker/EMT/actions/runs/43447815528); avvio 2026-11-13T14:58:06Z UTC; aggiornamento finale 2026-11-13T15:01:43Z UTC; registrazione 2026-11-13T15:02:03+00:00 UTC; evento pull_request.
- **Commit:** [5326b61e8d5e](https://github.com/gulinodesign-maker/EMT/commit/5326b61e8d5e6a75c5360a5bb992d9e5f3c0ca19); versione **1.0**; build **76**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py.

<!-- EMT_RUN:43447573123:ATTEMPT:1 -->
### 2026-11-13T14:56:35Z — CI #194 · build-76-gps-bridge-clean-cutoff · tentativo 1

- **Esecuzione:** [GitHub Actions 43447573123](https://github.com/gulinodesign-maker/EMT/actions/runs/43447573123); avvio 2026-11-13T14:56:35Z UTC; aggiornamento finale 2026-11-13T14:57:03Z UTC; registrazione 2026-11-13T14:57:14+00:00 UTC; evento pull_request.
- **Commit:** [931b2908532b](https://github.com/gulinodesign-maker/EMT/commit/931b2908532b3a65844814509a70ceedb972040a); versione **1.0**; build **76**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py, Tests/verify_map_contour_build48.py.

<!-- EMT_RUN:43447292257:ATTEMPT:1 -->
### 2026-11-13T14:54:53Z — CI #193 · build-76-gps-bridge-clean-cutoff · tentativo 1

- **Esecuzione:** [GitHub Actions 43447292257](https://github.com/gulinodesign-maker/EMT/actions/runs/43447292257); avvio 2026-11-13T14:54:53Z UTC; aggiornamento finale 2026-11-13T14:55:36Z UTC; registrazione 2026-11-13T14:55:47+00:00 UTC; evento pull_request.
- **Commit:** [705ed2cd5b3b](https://github.com/gulinodesign-maker/EMT/commit/705ed2cd5b3b8c1cd911d5b39b5d07fb01d972c0); versione **1.0**; build **76**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py.

<!-- EMT_RUN:43447132593:ATTEMPT:1 -->
### 2026-11-13T14:53:53Z — CI #192 · build-76-gps-bridge-clean-cutoff · tentativo 1

- **Esecuzione:** [GitHub Actions 43447132593](https://github.com/gulinodesign-maker/EMT/actions/runs/43447132593); avvio 2026-11-13T14:53:53Z UTC; aggiornamento finale 2026-11-13T14:54:20Z UTC; registrazione 2026-11-13T14:54:32+00:00 UTC; evento pull_request.
- **Commit:** [f430f5c173da](https://github.com/gulinodesign-maker/EMT/commit/f430f5c173da2769ee3f903f958fa91be9f07262); versione **1.0**; build **76**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py.

<!-- EMT_RUN:43446905915:ATTEMPT:1 -->
### 2026-11-13T14:52:28Z — CI #191 · build-76-gps-bridge-clean-cutoff · tentativo 1

- **Esecuzione:** [GitHub Actions 43446905915](https://github.com/gulinodesign-maker/EMT/actions/runs/43446905915); avvio 2026-11-13T14:52:28Z UTC; aggiornamento finale 2026-11-13T14:53:06Z UTC; registrazione 2026-11-13T14:53:15+00:00 UTC; evento pull_request.
- **Commit:** [37fec27d24aa](https://github.com/gulinodesign-maker/EMT/commit/37fec27d24aad90e8b64de55872378cab46914d4); versione **1.0**; build **76**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py.

<!-- EMT_RUN:43431278574:ATTEMPT:1 -->
### 2026-11-13T13:09:53Z — CI #190 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43431278574](https://github.com/gulinodesign-maker/EMT/actions/runs/43431278574); avvio 2026-11-13T13:09:53Z UTC; aggiornamento finale 2026-11-13T13:13:03Z UTC; registrazione 2026-11-13T13:13:15+00:00 UTC; evento push.
- **Commit:** [e9b2d4adbb5d](https://github.com/gulinodesign-maker/EMT/commit/e9b2d4adbb5ddfefbcea73a6cb9da71550d2e4ae); versione **1.0**; build **75**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_build75_metal_topbar_speed_shadow.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43430860789:ATTEMPT:1 -->
### 2026-11-13T13:06:59Z — CI #189 · build-75-metal-topbar-speed-shadow · tentativo 1

- **Esecuzione:** [GitHub Actions 43430860789](https://github.com/gulinodesign-maker/EMT/actions/runs/43430860789); avvio 2026-11-13T13:06:59Z UTC; aggiornamento finale 2026-11-13T13:09:36Z UTC; registrazione 2026-11-13T13:09:45+00:00 UTC; evento pull_request.
- **Commit:** [ef91c5346cea](https://github.com/gulinodesign-maker/EMT/commit/ef91c5346cea5803bf18600060da99f5f6ba9b8f); versione **1.0**; build **75**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py.

<!-- EMT_RUN:43420451910:ATTEMPT:1 -->
### 2026-11-13T11:52:01Z — CI #188 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43420451910](https://github.com/gulinodesign-maker/EMT/actions/runs/43420451910); avvio 2026-11-13T11:52:01Z UTC; aggiornamento finale 2026-11-13T11:54:08Z UTC; registrazione 2026-11-13T11:54:20+00:00 UTC; evento push.
- **Commit:** [eb8b92644ec4](https://github.com/gulinodesign-maker/EMT/commit/eb8b92644ec4d4c64bfbc63059fa669ff4f902f9); versione **1.0**; build **74**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/CockpitTabs.swift, Ecojumbo/Views/OtherViews.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43419845447:ATTEMPT:1 -->
### 2026-11-13T11:47:25Z — CI #187 · build-74-speed-phases-neon-testflight · tentativo 1

- **Esecuzione:** [GitHub Actions 43419845447](https://github.com/gulinodesign-maker/EMT/actions/runs/43419845447); avvio 2026-11-13T11:47:25Z UTC; aggiornamento finale 2026-11-13T11:51:15Z UTC; registrazione 2026-11-13T11:51:25+00:00 UTC; evento pull_request.
- **Commit:** [b85d2ba5a609](https://github.com/gulinodesign-maker/EMT/commit/b85d2ba5a60948cb14bcf08a5cb5e24c71f3f454); versione **1.0**; build **74**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build74_speed_phases_neon.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43412198661:ATTEMPT:1 -->
### 2026-11-13T10:50:22Z — CI #186 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43412198661](https://github.com/gulinodesign-maker/EMT/actions/runs/43412198661); avvio 2026-11-13T10:50:22Z UTC; aggiornamento finale 2026-11-13T10:52:28Z UTC; registrazione 2026-11-13T10:52:37+00:00 UTC; evento push.
- **Commit:** [f03fcab59e02](https://github.com/gulinodesign-maker/EMT/commit/f03fcab59e02835c43d41af35a98811dd70d23f1); versione **1.0**; build **73**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/CockpitTabs.swift, Ecojumbo/Views/OtherViews.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_build73_settings_glow_speed.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43411682537:ATTEMPT:1 -->
### 2026-11-13T10:46:30Z — CI #185 · build-73-setup-3x3-led-glow-speed-limits · tentativo 1

- **Esecuzione:** [GitHub Actions 43411682537](https://github.com/gulinodesign-maker/EMT/actions/runs/43411682537); avvio 2026-11-13T10:46:30Z UTC; aggiornamento finale 2026-11-13T10:49:25Z UTC; registrazione 2026-11-13T10:49:38+00:00 UTC; evento pull_request.
- **Commit:** [22234ab055d2](https://github.com/gulinodesign-maker/EMT/commit/22234ab055d269b781a7f8351eaccf2d09f1773a); versione **1.0**; build **73**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_version.py.

<!-- EMT_RUN:43411561824:ATTEMPT:1 -->
### 2026-11-13T10:45:35Z — CI #184 · build-73-setup-3x3-led-glow-speed-limits · tentativo 1

- **Esecuzione:** [GitHub Actions 43411561824](https://github.com/gulinodesign-maker/EMT/actions/runs/43411561824); avvio 2026-11-13T10:45:35Z UTC; aggiornamento finale 2026-11-13T10:46:07Z UTC; registrazione 2026-11-13T10:46:17+00:00 UTC; evento pull_request.
- **Commit:** [57124ae0ccb1](https://github.com/gulinodesign-maker/EMT/commit/57124ae0ccb16f8c2506f01ba3fc2e566fc46d06); versione **1.0**; build **73**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_cockpit.py.

<!-- EMT_RUN:43411419517:ATTEMPT:1 -->
### 2026-11-13T10:44:32Z — CI #183 · build-73-setup-3x3-led-glow-speed-limits · tentativo 1

- **Esecuzione:** [GitHub Actions 43411419517](https://github.com/gulinodesign-maker/EMT/actions/runs/43411419517); avvio 2026-11-13T10:44:32Z UTC; aggiornamento finale 2026-11-13T10:44:56Z UTC; registrazione 2026-11-13T10:45:23+00:00 UTC; evento pull_request.
- **Commit:** [14911b6b68d1](https://github.com/gulinodesign-maker/EMT/commit/14911b6b68d1675d7793bc6ef32945706b0bb551); versione **1.0**; build **73**.
- **Esito workflow:** **FAILURE**.
- **Test automatici:** Controlli strutturali Python: **FAILURE**; Test protocollo JK Bluetooth (sola lettura): **NON ESEGUITO**; Test barre dinamiche: **NON ESEGUITO**.
- **Compilazione simulatore:** **NON ESEGUITO**.
- **Errori rilevati:** Controlli strutturali Python. Dettagli nei log GitHub.
- **File modificati nel commit:** Tests/verify_build73_settings_glow_speed.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43396081664:ATTEMPT:1 -->
### 2026-11-13T08:48:10Z — CI #182 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43396081664](https://github.com/gulinodesign-maker/EMT/actions/runs/43396081664); avvio 2026-11-13T08:48:10Z UTC; aggiornamento finale 2026-11-13T08:52:54Z UTC; registrazione 2026-11-13T08:53:06+00:00 UTC; evento push.
- **Commit:** [5f187a192309](https://github.com/gulinodesign-maker/EMT/commit/5f187a1923098ca5dda684dbdde16bbbe2ea3990); versione **1.0**; build **72**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_build72_internal_led_contours.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43393862407:ATTEMPT:1 -->
### 2026-11-13T08:31:20Z — CI #181 · build-72-internal-led-contours · tentativo 1

- **Esecuzione:** [GitHub Actions 43393862407](https://github.com/gulinodesign-maker/EMT/actions/runs/43393862407); avvio 2026-11-13T08:31:20Z UTC; aggiornamento finale 2026-11-13T08:33:35Z UTC; registrazione 2026-11-13T08:33:44+00:00 UTC; evento pull_request.
- **Commit:** [d07afa3179e2](https://github.com/gulinodesign-maker/EMT/commit/d07afa3179e2e7c5117e21c1a2a036e76cac7495); versione **1.0**; build **72**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43309759041:ATTEMPT:1 -->
### 2026-11-12T21:23:18Z — CI #180 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43309759041](https://github.com/gulinodesign-maker/EMT/actions/runs/43309759041); avvio 2026-11-12T21:23:18Z UTC; aggiornamento finale 2026-11-12T21:26:10Z UTC; registrazione 2026-11-12T21:26:19+00:00 UTC; evento push.
- **Commit:** [fd6de1e42ebb](https://github.com/gulinodesign-maker/EMT/commit/fd6de1e42ebbeb3b17308baf07586683c843bb93); versione **1.0**; build **71**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build71_single_topbar.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43309262488:ATTEMPT:1 -->
### 2026-11-12T21:20:20Z — CI #179 · build-71-remove-duplicate-gps-top-profile · tentativo 1

- **Esecuzione:** [GitHub Actions 43309262488](https://github.com/gulinodesign-maker/EMT/actions/runs/43309262488); avvio 2026-11-12T21:20:20Z UTC; aggiornamento finale 2026-11-12T21:22:28Z UTC; registrazione 2026-11-12T21:22:39+00:00 UTC; evento pull_request.
- **Commit:** [fa918fccb9e6](https://github.com/gulinodesign-maker/EMT/commit/fa918fccb9e66c052118c7306240cfeccffefed2); versione **1.0**; build **71**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** STATO_PROGETTO.md.

<!-- EMT_RUN:43306056548:ATTEMPT:1 -->
### 2026-11-12T21:01:23Z — CI #178 · main · tentativo 1

- **Esecuzione:** [GitHub Actions 43306056548](https://github.com/gulinodesign-maker/EMT/actions/runs/43306056548); avvio 2026-11-12T21:01:23Z UTC; aggiornamento finale 2026-11-12T21:04:03Z UTC; registrazione 2026-11-12T21:04:13+00:00 UTC; evento push.
- **Commit:** [6154b6874067](https://github.com/gulinodesign-maker/EMT/commit/6154b687406710af43b2fd342d7934aecb7c9f89); versione **1.0**; build **70**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** Ecojumbo.xcodeproj/project.pbxproj, Ecojumbo/Views/CockpitComponents.swift, Ecojumbo/Views/CockpitTabs.swift, STATO_PROGETTO.md, Tests/verify_build60_setup_navigation.py, Tests/verify_build61_setup_grid.py, Tests/verify_build65_ui.py, Tests/verify_build66_symmetry_ring.py, Tests/verify_build67_user_fixes.py, Tests/verify_build68_gradient_layout.py, Tests/verify_build69_filled_areas_profile.py, Tests/verify_build70_no_gradients_centered.py, Tests/verify_build_history.py, Tests/verify_cockpit.py, Tests/verify_custom_themes_build63.py, Tests/verify_custom_themes_build64.py, Tests/verify_map_alignment_odo_keyboard52.py, Tests/verify_menu_orientation_build58.py, Tests/verify_minimal_navigation_build59.py, Tests/verify_odo_reset_51.py, Tests/verify_secondary_telemetry50.py, Tests/verify_speed_font_build53.py, Tests/verify_system_clock_build54.py, Tests/verify_telemetry_dock_build62.py, Tests/verify_version.py.

<!-- EMT_RUN:43305481404:ATTEMPT:1 -->
### 2026-11-12T20:57:55Z — CI #177 · build-70-no-colored-gradients-telemetry-tangent · tentativo 1

- **Esecuzione:** [GitHub Actions 43305481404](https://github.com/gulinodesign-maker/EMT/actions/runs/43305481404); avvio 2026-11-12T20:57:55Z UTC; aggiornamento finale 2026-11-12T21:00:49Z UTC; registrazione 2026-11-12T21:01:00+00:00 UTC; evento pull_request.
- **Commit:** [1cc8f6b8c797](https://github.com/gulinodesign-maker/EMT/commit/1cc8f6b8c79778f17e93f99b63075db106f103a3); versione **1.0**; build **70**.
- **Esito workflow:** **SUCCESS**.
- **Test automatici:** Controlli strutturali Python: **RIUSCITO**; Test protocollo JK Bluetooth (sola lettura): **RIUSCITO**; Test barre dinamiche: **RIUSCITO**.
- **Compilazione simulatore:** **RIUSCITO**.
- **Errori rilevati:** Nessun passaggio fallito riportato dall'API GitHub.
- **File modificati nel commit:** STATO_PROGETTO.md, Tests/verify_build_history.py.

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
