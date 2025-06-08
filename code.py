# Name dieser Datei: code.py
# Benötigt: pip install gitignore-parser (am besten in einer venv)
# Ausführen mit: python code.py (im Zielverzeichnis, venv muss aktiv sein)

import os
import sys
try:
    import gitignore_parser
except ImportError:
    print("Fehler: Das Paket 'gitignore-parser' wird benötigt.")
    print("Bitte installiere es mit: pip install gitignore-parser")
    print("(Am besten in einer aktivierten virtuellen Umgebung 'venv')")
    sys.exit(1)
import traceback # Für detailliertere Fehlermeldungen bei Bedarf

# --- Konfiguration ---
# Name der Ausgabedatei
output_filename = "verzeichnis_snapshot_mit_gitignore.txt"
# Verzeichnisse, die *immer* ignoriert werden sollen (zusätzlich zu .gitignore)
ignored_dirs_manual = {'.git', '.venv', 'venv', '__pycache__', 'node_modules', 'vendor'}
# Dateiendungen, die *immer* ignoriert werden sollen (zusätzlich zu .gitignore)
ignored_extensions_manual = {'.pyc', '.pyo', '.o', '.a', '.so', '.dll', '.exe', '.dylib',
                           '.class', '.jar', '.war', '.ear',
                           '.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff', '.ico',
                           '.mp3', '.wav', '.ogg', '.mp4', '.avi', '.mov', '.wmv',
                           '.zip', '.tar', '.gz', '.bz2', '.rar', '.7z',
                           '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
                           '.sqlite', '.db'}

# --- Hilfsfunktion zum Erkennen von Binärdateien (heuristisch) ---
def is_likely_binary(filepath, chunk_size=1024):
    """Versucht zu erraten, ob eine Datei binär ist."""
    _, ext = os.path.splitext(filepath)
    if ext.lower() in ignored_extensions_manual:
        return True
    try:
        with open(filepath, 'rb') as f:
            chunk = f.read(chunk_size)
            if not chunk: return False
            if b'\x00' in chunk: return True
            chunk.decode('utf-8', errors='strict')
    except UnicodeDecodeError: return True
    except IOError: return True
    except Exception: return True
    return False

# --- Hauptlogik ---
try:
    tree_lines = []
    text_files_to_process = [] # Speichert Tupel (voller_pfad, relativer_pfad)

    # .gitignore laden, falls vorhanden (angepasst für v0.1.11)
    matches_gitignore = None
    gitignore_path = os.path.join('.', '.gitignore') # Der Pfad zur .gitignore Datei
    gitignore_info = "Keine .gitignore gefunden oder verwendet."
    if os.path.exists(gitignore_path):
        try:
            # RUFE parse_gitignore MIT DEM PFAD AUF (korrekt für v0.1.11):
            matches_gitignore = gitignore_parser.parse_gitignore(gitignore_path)
            gitignore_info = f".gitignore Regeln aus '{gitignore_path}' werden angewendet."
        except Exception as e:
            gitignore_info = f"Warnung: Konnte '{gitignore_path}' nicht verarbeiten: {e}"
            # Bei Problemen hier die nächsten zwei Zeilen einkommentieren:
            # print("Detailfehler beim Parsen der .gitignore:")
            # traceback.print_exc()

    print(f"Starte Snapshot für: {os.getcwd()}")
    print(gitignore_info)
    print(f"Manuell ignorierte Ordner: {ignored_dirs_manual}")
    print(f"Manuell ignorierte Endungen: {ignored_extensions_manual}")

    # --- Verzeichnis einmal durchlaufen ---
    start_path = '.'
    for root, dirs, files in os.walk(start_path, topdown=True):
        root_rel_path = os.path.relpath(root, start_path)

        # Verzeichnisse filtern
        original_dirs = list(dirs)
        dirs[:] = [] # Leeren für os.walk
        valid_dirs_for_tree = []
        ignored_dirs_current = []

        for d in sorted(original_dirs):
            dir_full_path = os.path.join(root, d)
            # Wichtig: Pfad normalisieren für gitignore_parser und relative Pfade vermeiden
            dir_check_path = os.path.abspath(dir_full_path)

            is_ignored = False
            if d in ignored_dirs_manual:
                is_ignored = True
            elif matches_gitignore and matches_gitignore(dir_check_path):
                 is_ignored = True

            if is_ignored:
                 ignored_dirs_current.append(d)
            else:
                 dirs.append(d) # Weiter durchsuchen
                 valid_dirs_for_tree.append(d)

        # Baumstruktur für dieses Level
        if root == '.':
             level = 0
             current_dir_name = os.path.basename(os.getcwd()) + "/"
        else:
             level = root_rel_path.count(os.sep) + 1
             current_dir_name = os.path.basename(root) + "/"

        indent = "    " * level
        if level > 0 or root == '.':
            tree_lines.append(f"{indent} L {current_dir_name}")

        sub_indent = "    " * (level + 1)

        # Ignorierte Verzeichnisse im Baum markieren
        for d in ignored_dirs_current:
           tree_lines.append(f"{sub_indent} - {d}/ (Ignoriert)")

        # Dateien verarbeiten
        for f in sorted(files):
            file_full_path = os.path.join(root, f)
            file_rel_path = os.path.normpath(os.path.join(root_rel_path, f))
            # Wichtig: Pfad normalisieren für gitignore_parser
            file_check_path = os.path.abspath(file_full_path)

            is_file_ignored = False
            ignore_reason = ""

            _, ext = os.path.splitext(f)
            if ext.lower() in ignored_extensions_manual:
                is_file_ignored = True
                ignore_reason = "Endung"
            elif matches_gitignore and matches_gitignore(file_check_path):
                 is_file_ignored = True
                 ignore_reason = ".gitignore"

            if is_file_ignored:
                 tree_lines.append(f"{sub_indent} - {f} (Ignoriert: {ignore_reason})")
            else:
                 tree_lines.append(f"{sub_indent} - {f}")
                 if not is_likely_binary(file_full_path):
                     text_files_to_process.append((file_full_path, file_rel_path))

    # --- Ausgabe in Datei und Konsole ---
    print(f"\nSchreibe Snapshot nach: {output_filename}")
    with open(output_filename, "w", encoding="utf-8") as outfile:

        def print_and_write(text=""):
            print(text)
            outfile.write(text + "\n")

        print_and_write(f"--- Verzeichnis-Snapshot ---")
        print_and_write(f"Startverzeichnis: {os.getcwd()}")
        print_and_write(gitignore_info)
        print_and_write("-" * 30)

        print_and_write("\n--- Verzeichnisbaum ---")
        for line in tree_lines:
             print_and_write(line)

        print_and_write("\n\n" + "=" * 30)
        print_and_write("--- Dateiinhalte (nur Textdateien) ---")
        print_and_write("=" * 30 + "\n")

        if not text_files_to_process:
             print_and_write("[Keine Textdateien zum Anzeigen gefunden oder alle ignoriert.]")
        else:
            for full_path, rel_path in text_files_to_process:
                # Korrigiere den relativen Pfad für die Ausgabe, falls er mit '.' beginnt
                display_rel_path = rel_path if rel_path != '.' else os.path.basename(full_path)
                print_and_write(f"--- Datei: {display_rel_path} ---")
                try:
                    with open(full_path, "r", encoding="utf-8", errors="ignore") as infile:
                        content = infile.read()
                        print(content)
                        outfile.write(content + "\n")
                except Exception as e:
                    print_and_write(f"[Fehler beim Lesen der Datei {display_rel_path}: {e}]")
                print_and_write(f"--- Ende Datei: {display_rel_path} ---\n")

    print(f"\n-> Fertig! Ausgabe wurde in '{output_filename}' gespeichert und auf der Konsole angezeigt.")

except Exception as e:
    print(f"\nEin unerwarteter Fehler ist aufgetreten: {e}", file=sys.stderr)
    print("------------------------------------------")
    print("Traceback (für Fehlerdiagnose):")
    traceback.print_exc() # Zeigt detaillierten Fehlerverlauf
    print("------------------------------------------")
    sys.exit(1)