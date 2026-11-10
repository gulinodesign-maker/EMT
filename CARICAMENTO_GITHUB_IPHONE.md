# Come caricare Ecojumbo su GitHub senza Mac

Il contenuto **dello ZIP va estratto prima del caricamento**: GitHub non trasforma automaticamente uno ZIP caricato nella struttura dei file del repository.

## Procedura da browser iPhone

1. Nell'app **File**, apri `EJ_1.09_GITHUB_COMPLETO.zip` e toccalo per decomprimerlo. Si crea la cartella `EJ_1.09_GITHUB`.
2. Apri GitHub e crea un **repository privato** (per esempio `Ecojumbo`), preferibilmente senza inizializzarlo con altri file. Se usi Safari, potresti dover scegliere **Richiedi sito desktop**.
3. Nella pagina del repository scegli **Add file → Upload files**. Per caricare tutti i file preservando le sottocartelle, è più affidabile usare un computer o un client Git capace di caricare directory. Dal solo Safari su iPhone, la selezione di cartelle e la conservazione dei percorsi potrebbero non essere supportate.
4. **Non caricare solo il file ZIP** aspettandoti che GitHub lo estragga: rimarrebbe un unico file ZIP, e GitHub Actions non vedrebbe il progetto Xcode.
5. Quando i file sono presenti nel repository con la struttura originale, apri **Actions → Compila Ecojumbo (iOS)** e abilita i workflow se GitHub lo richiede. Poi premi **Run workflow**.

## Alternativa più semplice da iPhone

Se hai collegato GitHub a ChatGPT, puoi chiedere di caricare direttamente il contenuto del pacchetto nel repository che indichi. Questa procedura evita le limitazioni dell'upload di cartelle da Safari: richiede però che il collegamento GitHub abbia i permessi di scrittura e che tu autorizzi il repository destinazione.

## Struttura attesa su GitHub

```text
Ecojumbo.xcodeproj/
Ecojumbo/
  Assets.xcassets/
  Bluetooth/
  Models/
  Views/
Tests/
RiferimentoGrafico/
.github/workflows/ios-build.yml
.gitignore
README.md
LEGGIMI_PRIMA.md
CARICAMENTO_GITHUB_IPHONE.md
```

Tutti i file sopra sono **già inclusi** in questo pacchetto, non servono archivi esterni.
