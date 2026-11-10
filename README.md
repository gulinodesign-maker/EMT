# Ecojumbo — iPhone cockpit (1.0, build 9)

> **Stato grafico:** la 1.09 è un punto di partenza non ancora approvato. Il cruscotto non coincide ancora con il riferimento richiesto. Non considerare i mockup `RiferimentoGrafico/` come una prova del risultato dell'app.

## Contenuto del repository

Questo repository **contiene il codice Xcode completo**, estratto dall'archivio `EJ_1.09.zip` originale, senza modifiche ai sorgenti o alla grafica durante il trasferimento:

- `Ecojumbo.xcodeproj/` — progetto iOS Xcode.
- `Ecojumbo/` — sorgenti Swift, servizi Bluetooth/GPS, viste e catalogo immagini.
- `Tests/` — test del protocollo JK, formule e controlli della struttura.
- `RiferimentoGrafico/` — immagini di riferimento, **non** fotografie di un'app verificata.
- `.github/workflows/ios-build.yml` — compilazione automatica del simulatore iOS, più test offline.
- `LEGGIMI_PRIMA.md` — note originali della build 1.09.

**Versione Apple:** `1.0` · **Build:** `9` · **Visualizzazione nelle Impostazioni:** `1.09` · **Bundle ID:** `it.ecojumbo.battery` · **iOS minimo:** 17.0 · **Orientamento:** landscape.

## Compilazione automatica da GitHub

Apri **Actions → Compila Ecojumbo (iOS) → Run workflow** oppure esegui un push su `main`.

Il workflow utilizza un runner macOS con Xcode, esegue i test e prova `xcodebuild` per il simulatore senza firma Apple. Il segno verde compare **solo se la compilazione è effettivamente riuscita**. Il workflow non crea un'app firmata, non pubblica su TestFlight e non verifica l'aspetto sullo schermo. I minuti dei runner macOS possono essere fatturati o soggetti a limiti del piano GitHub.

## Compilazione dal proprio Mac

Apri `Ecojumbo.xcodeproj` in Xcode, seleziona il tuo Apple Developer Team, poi **Product → Clean Build Folder** e **Build**. Per pubblicare su TestFlight bisogna fare una build firmata e un Archive dal Mac o predisporre separatamente certificati e provisioning nella CI.

## Privacy e sicurezza

- La connessione a JK BMS è pensata per lettura dati reali, non per comandare le protezioni o fermare la ricarica.
- Le funzionalità GPS, Bluetooth e le prestazioni del cruscotto richiedono una prova su dispositivi reali.
- Evita di aggiungere al repository credenziali Apple, certificati di firma, chiavi private, file `.p12`, `.p8` o provisioning profiles.
- Il repository è consigliato **privato** fino alla revisione completa del progetto.

Per caricare il repository dall'iPhone leggi **`CARICAMENTO_GITHUB_IPHONE.md`**.
