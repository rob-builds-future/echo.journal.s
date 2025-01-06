# echo. journal & language practice

**echo. Schreiben, Lernen, Wachsen – jeden Tag.**

echo. journal & language practice ist eine App, die Menschen dabei unterstützt, gute Gewohnheiten wie Tagebuchschreiben und das Lernen von Fremdsprachen gleichzeitig zu etablieren. Sie richtet sich an alle, die **persönliche Reflexion** und **sprachliche Weiterentwicklung** in ihren Alltag integrieren möchten – auch wenn wenig Zeit zur Verfügung steht.

Die App schafft eine motivierende Umgebung, in der Nutzer ihre Gedanken festhalten und dabei spielerisch eine Fremdsprache lernen können. Was echo. besonders macht, ist die Kombination von intuitivem Tagebuchschreiben mit Echtzeit-Übersetzungen und einem KI-Assistenten, der als zukünftiges Ich personalisiert wird, um gezielt zu motivieren und zu unterstützen. So wird Lernen inspirierend, effizient und individuell.


## Design

| App Landing             | Sign In               | Onboarding             | Home List            |
|--------------------------|-----------------------|------------------------|----------------------|
| ![App Landing](./img/App%20Landing.png) | ![Sign In](./img/Sign%20In.png) | ![Onboarding](./img/echo%20onboarding.png) | ![Home List](./img/Home%20List.png) |
| New Entry               | PopUp Change/Delete | Language Picker        | Entry Translated     |
| ![New Entry](./img/New%20Entry.png) | ![PopUp Change/Delete](./img/PopUp%20Change%20Delete.png) | ![Language Picker](./img/Language%20Picker.png) | ![Entry Translated](./img/Entry%20translated.png) |
| Record Audio            | Entry from Audio     | Entry Inspiration      | PopUp Echo Message   |
| ![Record Audio](./img/Record%20Audio.png) | ![Entry from Audio](./img/Entry%20from%20Audio.png) | ![Entry Inspiration](./img/Echo%20Entry%20Inspiration.png) | ![PopUp Echo Message](./img/PopUp%20Echo%20Message.png) |

## Features

### Höchste Priorität (MVP)
- [ ] Tagebuch Einträge Übersicht
- [ ] Tagebuch Schreiben und speichern
- [ ] Sprachübersetzung und Wörterbuchfunktion in relevante Sprachen
- [ ] echo's inspirierende Schreibanregungen
- [ ] Zielsprache auswählen und wechseln
- [ ] User Profil und generelle Settings
### Mittlere Priorität
- [ ] Echtzeit-Übersetzung
- [ ] Text-zu-Sprache für gelernte Sprache
- [ ] Bilder aus Fotos einfügen
- [ ] Orte aus Maps einfügen
- [ ] Voice to Text
- [ ] Audio Records to Text
- [ ] Vokabel-Highlighting
### Niedrige Priorität
- [ ] Sumaaries und Reviews von Wochen, Monaten, Jahrenanhand der Einträge
- [ ] Andere User adden und Community-Features (Gemeinsames Tagebuch, Einträge teilen, ...)
- [ ] Echo Customizing / personalisierter KI-Assistent
- [ ] Gamification
- [ ] Emotionstracker

## Technischer Aufbau

#### Projektaufbau
echo/

├── Models/

│   ├── Entry.swift

│   ├── User.swift

│   ├── Translation.swift

│   ├── Prompt.swift

├── ViewModels/

│   ├── EntryViewModel.swift

│   ├── UserViewModel.swift

│   ├── TranslationViewModel.swift

│   ├── PromptViewModel.swift

├── Views/

│   ├── EntryListView.swift

│   ├── EntryDetailView.swift

│   ├── NewEntryView.swift

│   ├── SettingsView.swift

│   ├── LanguagePickerView.swift

├── Repositories/

│   ├── EntryRepository.swift

│   ├── UserRepository.swift

│   ├── TranslationRepository.swift

│   ├── PromptRepository.swift


##### 1. Models
Aufgabe: Datenstrukturen definieren.
Beispiel: Tagebucheintrag (Entry), Nutzerprofil (User), Übersetzung (Translation), Schreibanregung (Prompt).

##### 2. Repositories
Aufgabe: Datenquellen abstrahieren und Datenoperationen bereitstellen.
Beispiele:
	•	Einträge laden und speichern (EntryRepository: fetchEntries(), saveEntry(), deleteEntry()).
	•	Benutzerprofil verwalten (UserRepository: getUser(), updateUser()).
	•	Texte übersetzen (TranslationRepository: translateText()).
	•	Schreibanregungen bereitstellen (PromptRepository: getDailyPrompt(), fetchPrompts()).

##### 3. ViewModels
Aufgabe: UI-Logik und Datenbereitstellung für die Views.
Beispiele:
	•	Tagebucheinträge anzeigen und verwalten (EntryViewModel: loadEntries(), addEntry(), deleteEntry()).
	•	Benutzerinformationen verwalten (UserViewModel: loadUser(), updateLanguage()).
	•	Texte übersetzen (TranslationViewModel: translateText()).
	•	Schreibanregungen laden (PromptViewModel: loadDailyPrompt()).

##### 4. Views
Aufgabe: Darstellung der Daten und Verarbeitung von Benutzerinteraktionen.
Beispiele:
	•	Eintragsübersicht (EntryListView).
	•	Detaileintrag (EntryDetailView).
	•	Neuer Eintrag (NewEntryView).
	•	Einstellungen (SettingsView).
	•	Sprache auswählen (LanguagePickerView).

#### Datenspeicherung

##### Welche Daten?
	•	Tagebucheinträge: Titel, Inhalt, Datum, Tags, Sprache, Übersetzungen.
	•	Benutzerprofile: Name, Zielsprache, Einstellungen.
	•	Übersetzungen: Quelltext, Zieltext, Sprache.
	•	Schreibanregungen: Tägliche Inspirationen.

##### Wo und wie?
	•	Firebase: Hauptspeicherort für alle Daten.
	•	Warum Firebase? Echtzeit-Synchronisation zwischen Geräten. Skalierbarkeit und einfache Integration. Möglichkeit für späteren Offline-Support.

Core Data wird derzeit nicht genutzt, kann jedoch später für einen Offline-Modus integriert werden.

#### API Calls
Welche APIs verwendest du?

#### 3rd-Party Frameworks
Verwendest du Frameworks, die nicht von dir stammen? Bspw. Swift Packages für Firebase, fertige SwiftUI-Views o.Ä.? Gib diese hier an.


## Ausblick
Beschreibe hier, wo die Reise nach deinem Praxisprojekt hin geht. Was möchtest du in Zukunft noch ergänzen?

- [ ] Geplantes Feature 1
- [ ] Geplantes Feature 2
- [ ] ...
