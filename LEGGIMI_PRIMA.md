# Ecojumbo — EJ_1.09 (versione 1.0, build 9)

## Cosa cambia rispetto a EJ_1.08

- **Un'unica linea arancione inferiore ininterrotta:** dal bordo sinistro sotto i quattro tasti, raccordo curvo verso il centro, tratto orizzontale sopra i valori A/kW, raccordo simmetrico e prosecuzione sotto i quattro tasti di destra. La linea è una sola `Shape` vettoriale SwiftUI con tre passate di luce; è stato eliminato il vecchio contorno interno separato del tachimetro.
- **Tachimetro dimensionato all'altezza dell'iPhone:** diametro massimo 93% dell'altezza disponibile (ulteriormente limitato dalla larghezza); centrato e senza corone tagliate dai bordi dello schermo. La scala esterna e la velocità restano in primo piano rispetto ai pannelli.
- **Nuovo LED rosso di velocità:** eliminati tutti i numeri fissi 0–120 dalla scala. Resta una graduazione a tacche bianche, sotto cui un arco luminoso rosso cresce proporzionalmente alla velocità GPS valida, da 0 a 120 km/h. Un punto brillante segna l'estremità della barra. Senza segnale GPS il LED resta spento.
- Rimangono pannelli laterali con sei barre progressive, sfondo carbonio, doppia corona corrente/potenza, pulsanti metallici 4+4, Bluetooth JK, GPS, percorsi, temi, Google Maps, e icona E/saetta originali.

## Misure e sicurezza

La velocità proviene SOLO dal GPS di Core Location. Potenza, corrente, tensione e SOC richiedono dati **reali** da JK BMS via BLE, mai simulati. Se il BMS non è collegato, le misure sono "—" e le barre rimangono vuote. Non sono implementati comandi di scrittura sul BMS. Il protocollo va convalidato sul BMS reale quando sarà disponibile. La scala 120 km/h è esclusivamente grafica e non modifica i limiti dello scooter.

## Compilazione sul Mac

1. Estrarre `EJ_1.09.zip`. La cartella principale si chiama esattamente `EJ_1.09`.
2. Aprire `EJ_1.09/Ecojumbo.xcodeproj`.
3. Selezionare il Team Apple in **Signing & Capabilities**.
4. Xcode: **Product → Clean Build Folder**, poi **Product → Build**. Testare in orientamento landscape sul proprio iPhone e verificare che la linea inferiore non abbia interruzioni.
5. Per TestFlight: **Product → Archive**. Bundle ID invariato `it.ecojumbo.battery`.

Apple version: `1.0`; build: `9`; display Impostazioni: `1.09`.

Controlli eseguiti in questo ambiente: parsing Swift, test del decoder JK, test matematici delle sei barre, controlli dei file Xcode e di coerenza grafica, controlli di integrità dello ZIP. Non è disponibile Xcode/iOS SDK: l'app non è stata compilata con gli strumenti Apple né controllata visivamente sul dispositivo.
