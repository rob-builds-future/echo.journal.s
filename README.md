# echo. journal & language practice

Meine Motivation: Mentale Klarheit und Sprachbegeisterung vereinen.
Ich schreibe seit einem Jahr regelmäßig Tagebuch und habe dabei gemerkt, wie sehr mir das Festhalten meiner Gedanken hilft, den Kopf freizubekommen und neue Perspektiven zu gewinnen. Gleichzeitig interessiere ich mich nicht nur für Programmiersprachen, sondern auch für gesprochene Sprachen. Doch im Alltag bleibt oft wenig Zeit, beides konsequent zu verfolgen.

Genau hier setzt meine App-Idee an: echo. journal & language practice kombiniert das schnelle, unkomplizierte Festhalten von Einträgen mit dem spielerischen Lernen einer Fremdsprache. So möchte ich die Vorteile des Tagebuchschreibens – Klarheit, Reflexion, mentale Stärkung – mit dem Reiz des Sprachenlernens verknüpfen und Menschen eine einfache Möglichkeit bieten, beide Routinen gleichzeitig zu pflegen.

**echo. Schreiben, Lernen, Wachsen – jeden Tag.**

echo. journal & language practice ist eine App, die Menschen dabei unterstützt, gute Gewohnheiten wie Tagebuchschreiben und das Lernen von Fremdsprachen gleichzeitig zu etablieren. Sie richtet sich an alle, die **persönliche Reflexion** und **sprachliche Weiterentwicklung** in ihren Alltag integrieren möchten – auch wenn wenig Zeit zur Verfügung steht.

Die App schafft eine motivierende Umgebung, in der Nutzer ihre Gedanken festhalten und dabei spielerisch eine Fremdsprache lernen können. Was echo. besonders macht, ist die Kombination von intuitivem Tagebuchschreiben mit Echtzeit-Übersetzungen und einem KI-Assistenten, der als zukünftiges Ich personalisiert wird, um gezielt zu motivieren und zu unterstützen. So wird Lernen inspirierend, effizient und individuell.


## Design

### Light Mode

<!-- Erste Zeile -->
| Entry List | Entry List Popup | New Entry |
|------------|------------------|-----------|
| <img src="./img/Entry%20List_light.PNG" alt="Entry List" width="200"> | <img src="./img/Entry%20List%20Popup_light.png" alt="Entry List Popup" width="200"> | <img src="./img/New%20Entry_light.png" alt="New Entry" width="200"> |

<!-- Zweite Zeile -->
| Onboarding1 | Onboarding2 | Settings |
|-------------|-------------|----------|
| <img src="./img/Onboarding1_light.png" alt="Onboarding1" width="200"> | <img src="./img/Onboarding2_light.png" alt="Onboarding2" width="200"> | <img src="./img/Settings_light.png" alt="Settings" width="200"> |

<!-- Dritte Zeile -->
| Show:Change Entry | Sign In | SplashScreen |
|-------------------|---------|--------------|
| <img src="./img/Show%3AChange%20Entry_light.png" alt="Show:Change Entry" width="200"> | <img src="./img/Sign%20In_light.png" alt="Sign In" width="200"> | <img src="./img/SplashScreen_light.png" alt="SplashScreen" width="200"> |

<!-- Vierte Zeile -->
| Statistics |  |  |
|------------|--|--|
| <img src="./img/Statistics_light.png" alt="Statistics" width="200"> |  |  |

### Dark Mode

<!-- Erste Zeile -->
| Entry List | New Entry | Onboarding1 |
|------------|-----------|-------------|
| <img src="./img/Entry%20List_dark.png" alt="Entry List" width="200"> | <img src="./img/New%20Entry_dark.PNG" alt="New Entry" width="200"> | <img src="./img/Onboarding1_dark.png" alt="Onboarding1" width="200"> |

<!-- Zweite Zeile -->
| Onboarding2 | Show:Change Entry | Sign In |
|-------------|-------------------|---------|
| <img src="./img/Onboarding2_dark.png" alt="Onboarding2" width="200"> | <img src="./img/Show%3AChange%20Entry_dark.png" alt="Show:Change Entry" width="200"> | <img src="./img/Sign%20In_dark.png" alt="Sign In" width="200"> |

<!-- Dritte Zeile -->
| SplashScreen | Statistics |  |
|--------------|------------|---|
| <img src="./img/SplashScreen_dark.pn" alt="SplashScreen" width="200"> | <img src="./img/Statistics_dark.PNG" alt="Statistics" width="200"> |  |


## Features

### Höchste Priorität (MVP)
- [x] Tagebuch Einträge Übersicht
- [x] Tagebuch Einträge Favoritenliste
- [x] Tagebuch Schreiben und speichern
- [x] Sprachübersetzung und Wörterbuchfunktion in relevante Sprachen
- [x] echo's inspirierende Schreibanregungen
- [x] Zielsprache auswählen und wechseln
- [x] User Profil und generelle Settings
### Mittlere Priorität
- [x] Echtzeit-Übersetzung
- [x] Text-zu-Sprache für gelernte Sprache
- [x] Voice to Text
- [x] Schreib-Statistik
- [x] Schreib-Tracker
- [x] TopWord-Identifikation und Übersetzung
### Niedrige Priorität
- [ ] Bilder aus Fotos einfügen
- [ ] Orte aus Maps einfügen
- [ ] Audio Records to Text
- [ ] Vokabel-Highlighting
+ siehe unten -> Ausblick


## Technischer Aufbau


#### Projektaufbau

	echo.journal/
	├── 1 Models/
	│   ├── JournalEntry.swift
	│   └── User.swift
	├── 2 ViewModels/
	│   └── JournalViewModel.swift
	├── 3 Views/
	│   ├── JournalListView.swift
	│   ├── JournalEntryView.swift
	│   └── LoginView.swift
	├── 4 Repositories/
	│   ├── JournalRepository.swift
	│   └── TranslationRepository.swift
	└── 5 Ressources & Config/
    	├── Assets
     	├── Plist
    	└── Localizable

	Der Datenfluss geht dabei typischerweise: View <-> ViewModel <-> Repository <-> External Sources

##### 1. Models

Aufgabe: Definieren die Datenstrukturen/Objekte der App (z.B. JournalEntry, User)

Structs: Tagebucheintrag (JournalEntry), Nutzerprofil (User), ggf. weitere: (Übersetzung (Translation), Schreibanregung (Prompt), ...).
 
##### 2. ViewModels

Aufgabe: Implementieren die Business-Logik und koordinieren verschiedene Repos

ViewModels:

- Tagebucheinträge anzeigen und verwalten (JournalViewModel: loadEntries(), addEntry(), deleteEntry()).
 
- ggf. weitere (Benutzerinformationen verwalten (UserViewModel: loadUser(), updateLanguage()), Texte übersetzen (TranslationViewModel: translateText()), Schreibanregungen laden (PromptViewModel: loadDailyPrompt()).

##### 3. Views

Aufgabe: Zeigen die UI an und nehmen User-Interaktionen entgegen

Views:

- Eintragsübersicht (JournalListView),
 
- Detaileintrag neu/änderbar (JournalEntrylView),
 
- Login (LoginView),
 
- ggf. weitere (Sprache auswählen (LanguagePickerView), Einstellungen (SettingsView), ...).

##### 4. Repositories

Aufgabe: Kümmern sich um die technische Kommunikation mit externen APIs/Systemen (Firebase, LibreTranslate)

- Firebase-Kommunikation (FirebaseService),

- LibreTranslateAPI-Docker-Container-Kommunikation (TranslationService).

Repos: 

- Einträge laden und speichern (JournalRepository: fetchEntries(), saveEntry(), deleteEntry()),
  
- Texte übersetzen (TranslationRepository: translateText()),
  
- ggf. weitere (Benutzerprofil verwalten (UserRepository: getUser(), updateUser()), Schreibanregungen bereitstellen (PromptRepository: getDailyPrompt(), fetchPrompts(), ...).

#### Datenspeicherung

##### Welche Daten?

- Tagebucheinträge: Titel, Inhalt, Datum, Tags, Sprache, Übersetzungen.
 
- Benutzerprofile: Name, Zielsprache, Einstellungen.
   
- Schreibanregungen: Tägliche Inspirationen.

##### Wo und wie?

- Firebase: Hauptspeicherort für Daten.

- Warum Firebase? Echtzeit-Synchronisation zwischen Geräten. Skalierbarkeit und einfache Integration. Möglichkeit für späteren Offline-Support.

- Loakler Speicher UserDefault für Daten wie Onboarding Bool und gewähltes Farbschema.



#### API Calls

LibreTranslate API: Übersetzung von Texten in die Zielsprache. Übersetzen von Tagebucheinträgen und Bereitstellen von Synonymen/Definitionen.

Warum: Open-Source-Lösung ohne Lizenzkosten, sofern Selbst-gehostet. Unterstützt mehrere Sprachen.

**Extra Herausforderung:** Selbst-Hosten ist wegen der API notwendig, da die Nutzung über die LibreTranslate Server nicht kostenfrei ist! -- **Docker Container** 

Zukünftige API-Erweiterungen für bspw echos' KI-Funktionen können später ergänzt werden.


## Ausblick

1.	**Summaries & Reviews**
Automatisierte Wochen- oder Monatsrückblicke anhand der geschriebenen Einträge – so lassen sich persönliche Fortschritte im Journalen und Sprachenlernen übersichtlich nachvollziehen.

2.	**Community-Features**
Einbindung anderer Nutzer: Gemeinsame Journals, das Austauschen von Einträgen oder Feedback und damit ein soziales Element, das zusätzlich motiviert.

3.	**Echo-Assistent Customizing**
Das virtuelle Zukunfts-Ich lässt sich individuell anpassen und personalisieren: Nutzer können die Persönlichkeit, den Schreibstil oder sogar den Avatar ihres KI-Assistenten definieren.

