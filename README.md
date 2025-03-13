# 🔥 Linux Helper Scripts: aptman & devilbox.sh

This repository provides two handy Bash scripts:  
- **`aptman`** - Simulates `apt` commands using `pacman` for Arch-based Linux distributions.  
- **`devilbox.sh`** - A script to easily manage your **Devilbox** environment using Docker.  

---

## 🏗️ aptman: Pacman with APT-like Commands  

`aptman` is a simple wrapper for `pacman`, mimicking common `apt` commands.

### 📌 Usage  
```sh
aptman update       # 🔄 Updates package database  
aptman upgrade      # ⬆️ Upgrades all installed packages  
aptman install nano # 📦 Installs nano  
aptman remove nano  # 🗑️ Removes nano  
aptman search vim   # 🔍 Searches for vim  
aptman info firefox # ℹ️ Shows details about Firefox  
aptman list         # 📋 Lists installed packages  
aptman clean        # 🧽 Cleans old package cache  
```

---

## 🐳 devilbox.sh: Manage Your Devilbox Environment  

`devilbox.sh` is a Bash script designed to simplify the management of **Devilbox**, a powerful Docker-based LAMP/LEMP development stack.

### 📌 Features  
✅ **Start, stop, and restart Devilbox** easily  
✅ **Run shell commands inside the PHP container**  
✅ **Execute Composer commands within the project container**  
✅ **Check the current status of Devilbox services**  

### 📌 Usage  
```sh
devilbox.sh start       # 🚀 Start Devilbox  
devilbox.sh stop        # 🛑 Stop Devilbox  
devilbox.sh restart     # 🔄 Restart PHP container  
devilbox.sh status      # 📊 Check Devilbox status  
devilbox.sh shell       # 💻 Enter Devilbox shell  
devilbox.sh composer install <pkg>  # 📦 Run Composer inside the project  
devilbox.sh . ls        # 🔍 Run a shell command inside the project  
```

---

## 🚀 Installation  

Clone this repository to your local system:  
```sh
git clone https://github.com/YOUR-GITHUB-USERNAME/linux-helper-scripts.git
cd linux-helper-scripts
```

Then, follow the setup instructions for each script.

### 🏗️ Installing `aptman`
```sh
chmod +x aptman
mv aptman ~/.local/bin/
```

### 🐳 Installing `devilbox.sh`
```sh
chmod +x devilbox.sh
mv devilbox.sh ~/.local/bin/
```

---

## 📜 License  
This project is licensed under the **MIT License**. Feel free to use, modify, and distribute it.  

---

## 🛠️ Contributing  
Want to improve these scripts? Pull requests are welcome!  

1. **Fork** the repo  
2. **Clone** your fork  
3. **Create a new branch** (`git checkout -b feature-xyz`)  
4. **Make changes and commit** (`git commit -m "Add feature XYZ"`)  
5. **Push** to your branch (`git push origin feature-xyz`)  
6. **Open a Pull Request**  

---

## 📞 Contact  
For questions or suggestions, open an issue or reach out via GitHub.  
Happy scripting! 🚀🔥
