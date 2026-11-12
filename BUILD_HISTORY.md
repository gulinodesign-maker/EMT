# BUILD HISTORY — Registro permanente delle CI EMT

Registro tecnico delle esecuzioni **Compila Ecojumbo (iOS)**. Dall'attivazione del workflow `Registra esiti build EMT`, ogni esecuzione terminata (successo, errore, annullamento o timeout) produce qui una voce con metadati GitHub verificabili. Il workflow di registrazione **non compila l'app**, non carica su TestFlight e non sostituisce la lettura dei log originali.

Le informazioni sui test e sulla compilazione derivano dagli **esiti effettivi dei passaggi GitHub Actions**; una fase saltata è `non eseguita`, mai `riuscita`. Non vengono salvati log grezzi, token, credenziali né segreti. Data e ora sono in **UTC**, ove non diversamente indicato. I file cambiati sono recuperati da GitHub per il commit SHA, non ricostruiti dalla conversazione. Se l'API non li fornisce sono segnati `non disponibili`.

L'aggiornamento usa il `GITHUB_TOKEN` del workflow, con privilegi limitati. Se `main` vieta il push del bot, un ramo di fallback conserva un tentativo di registrazione; il workflow segnala l'errore, senza fingere che `main` sia aggiornato. Leggere [STATO_PROGETTO.md](STATO_PROGETTO.md) per le decisioni e gli impegni utente non ricavabili dai log.

## Registro automatico

<!-- BUILD_HISTORY_AUTO_START -->
_Nessun evento automatico ancora registrato. Il primo evento verificato dopo l'installazione del workflow sarà aggiunto qui._
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
