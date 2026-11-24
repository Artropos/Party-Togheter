# QuestSync

Addon voor World of Warcraft Forever (Interface 16001). Alle synchronisatie verloopt uitsluitend over het tijdelijke kanaal `QS_<code>`; er is geen party-/raid-chattransport en geen automatische sessie. De code is een wachtwoord: deel hem alleen met gewenste deelnemers.

## Installatie

Kopieer de volledige map `QuestSync` naar `_forever_\Interface\AddOns\QuestSync` en controleer dat `QuestSync.toc` direct in die map staat. De TGA-afbeeldingen staan in `Media/`; `Media/generate_media.py` kan ze opnieuw genereren met Python 3.

## Gebruik

- `/qs create` maakt een sessiecode en maakt het kanaal aan.
- `/qs join K7Q2X` sluit aan; spaties en streepjes worden genegeerd.
- `/qs leave` verlaat sessie en kanaal.
- `/qs probe` controleert API-aannames en print PASS/FAIL in het chatvenster.
- `/qs` opent het sessievenster. De L-toets en questlog-microknop openen de eigen questlog.
- Trackerregels links/rechts klikken: openen / ontvolgen; questlog-rij rechtsklikken volgt/ontvolgt, middelklikken deelt via Blizzard met party.
- Ctrl-rechtsklik op de wereldkaart plaatst een marker; Shift-Ctrl-rechtsklik maakt hem permanent.

De addon vervangt de Blizzard-objectivetracker, toont quests met moderne `C_QuestLog`-API's en houdt class-quests lokaal. Class-quests komen niet in transport of matrix. Deelopties staan in SavedVariables; de sessiecode blijft bewaard om na herladen te reconnecten.

## Protocol in het kort

Addon-prefix `QuestSync`, uitsluitend `CHANNEL`; payloads zijn `TYPE|payload`: `V` versie/hello, `R` snapshotverzoek, `S` snapshot, `Q` genummerde delta, `D` verwijdering, `T`/`TR` titel, `SH` deelname/deelindicatie, `P` positie, `M` kaartmarker, `C` claim en `X` vertrek. Berichten boven de clientlimiet worden in maximaal 190-byte payloadfragmenten verzonden en na ontvangst samengevoegd. Incomplete fragmenten verlopen na 10 seconden. Berichten worden tijdens combat uitgesteld.

## Probe: aannames en actie bij FAIL

`/qs probe` controleert quest-ID-/questlog-/objective-/selectie-API's en `QuestLogPushQuest`, class-tagdetectie (een class-quest moet in je log staan om de concrete tag te tonen), SuperTrack, addonbericht-API, texturepad, kaartpin-mixins en kaartmethodes, `UnitPosition`, minimap-rotatie/CVar en tijdelijke kanaalmethodes. Ontbrekende functies betekenen dat de geïnstalleerde client/build niet aan de vereiste Forever-API voldoet: controleer de clientpatch en addonmap, herlaad (`/reload`) en voer de probe opnieuw uit. Als alleen class-tag geen quest vindt, laad een class-quest in je eigen questlog en voer de probe opnieuw uit; deel nooit die quest. De CHAT_MSG_ADDON-regel bevestigt dat het event registreerbaar is; een echte ontvangstproef vereist twee clients in dezelfde code.

## Bekende runtime-beperkingen

De addon kan geen quests op afstand accepteren: acceptatie gebeurt uitsluitend bij Blizzard's `QUEST_DETAIL`, en delen vereist party/raid en `QuestLogPushQuest()`. De code is geen encryptie; sessieleden kunnen queststatussen en (als ingeschakeld) posities zien.
