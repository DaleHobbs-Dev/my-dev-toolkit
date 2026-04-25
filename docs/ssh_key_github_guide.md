# SSH Key Setup for GitHub on Windows

---

## Part 1: Adding an SSH Key to a Computer That Doesn't Have One

### 1. Check if You Already Have an SSH Key

Open PowerShell and run:

```powershell
ls C:\Users\YourUsername\.ssh
```

If you see files like `id_ed25519` and `id_ed25519.pub`, you already have a key. If the `.ssh` folder doesn't exist or is empty, proceed with the steps below.

---

### 2. Start the SSH Agent (Run PowerShell as Administrator)

Before adding any keys, make sure the SSH agent service is running. Open PowerShell **as Administrator** and run:

```powershell
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service -Name ssh-agent
```

Verify it is running:

```powershell
Get-Service ssh-agent
```

You should see `Running` in the status column.

---

### 3. Generate a New SSH Key

In PowerShell (does not need to be Admin), run:

```powershell
ssh-keygen -t ed25519 -C "your_email@example.com"
```

When prompted for a file location, you can press **Enter** to accept the default:

```bash
C:\Users\YourUsername\.ssh\id_ed25519
```

---

### 4. Add the Key to the SSH Agent

```powershell
ssh-add C:\Users\YourUsername\.ssh\id_ed25519
```

---

### 5. Verify the Key is Valid

```powershell
ssh-keygen -l -f C:\Users\YourUsername\.ssh\id_ed25519
```

This prints the key's fingerprint, confirming it is a legitimate key file.

---

### 6. Add the Public Key to GitHub

Print your public key with:

```powershell
cat C:\Users\YourUsername\.ssh\id_ed25519.pub
```

Copy the entire output (starts with `ssh-ed25519 AAAA...`), then:

1. Go to GitHub.com and log in
2. Profile picture → **Settings**
3. Left sidebar → **SSH and GPG keys**
4. Click **New SSH key**
5. Give it a title (e.g. "Windows PC")
6. Paste the key and click **Add SSH key**

---

### 7. Test the SSH Connection

```bash
ssh -T git@github.com
```

A successful response looks like:

```bash
Hi YourUsername! You've successfully authenticated, but GitHub does not provide shell access.
```

---

### 8. Config File (Single Account)

For a single GitHub account, a config file is optional, but if you create one make sure it is saved without a `.txt` extension (see note below). A basic config looks like:

```text
# GitHub account
Host github.com
  HostName github.com
  User git
  IdentityFile C:\Users\YourUsername\.ssh\id_ed25519
```

Open or create the config file with:

```powershell
notepad C:\Users\YourUsername\.ssh\config
```

When saving in Notepad, set **Save as type** to **All Files (*.*)** to prevent it from being saved as `config.txt`.

---

---

## Part 2: Adding a Second SSH Key to a Computer That Already Has One

### 1. Check Your Existing Key

```powershell
ls C:\Users\YourUsername\.ssh
```

Confirm you see your existing key (e.g. `id_ed25519` and `id_ed25519.pub`) before proceeding.

---

### 2. Start the SSH Agent (Run PowerShell as Administrator)

Same as Part 1 — make sure the SSH agent is running:

```powershell
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service -Name ssh-agent
Get-Service ssh-agent
```

---

### 3. Generate a New SSH Key With a Different Name

When prompted for a file location, **do not press Enter** — give it a unique name so it doesn't overwrite your existing key:

```powershell
ssh-keygen -t ed25519 -C "your_new_email@example.com"
```

At the prompt:

```
Enter file in which to save the key: C:\Users\YourUsername\.ssh\id_ed25519_second_account
```

---

### 4. Add the New Key to the SSH Agent

```powershell
ssh-add C:\Users\YourUsername\.ssh\id_ed25519_second_account
```

---

### 5. Verify the New Key is Valid

```powershell
ssh-keygen -l -f C:\Users\YourUsername\.ssh\id_ed25519_second_account
```

---

### 6. Add the New Public Key to GitHub

```powershell
cat C:\Users\YourUsername\.ssh\id_ed25519_second_account.pub
```

Copy the output and add it to your second GitHub account following the same steps as Part 1, Step 6.

---

### 7. Create or Edit the SSH Config File

This is the critical step for multiple accounts. The config file tells SSH which key to use for which account.

Open the config file:

```powershell
notepad C:\Users\YourUsername\.ssh\config
```

Add an entry for each account using a unique **Host alias**:

```text
# First GitHub account
Host github-personal
  HostName github.com
  User git
  IdentityFile C:\Users\YourUsername\.ssh\id_ed25519

# Second GitHub account
Host github-work
  HostName github.com
  User git
  IdentityFile C:\Users\YourUsername\.ssh\id_ed25519_second_account
```

> **Note:** `HostName` and `User` stay the same for all GitHub accounts. The `Host` alias is what you invent yourself, and `IdentityFile` is what differentiates the accounts.

---

### 8. Check the Config File Doesn't Have a .txt Extension

Windows Notepad often sneaks a `.txt` extension onto files. Verify with:

```powershell
ls C:\Users\YourUsername\.ssh
```

If you see `config.txt` instead of `config`, rename it:

```powershell
Rename-Item C:\Users\YourUsername\.ssh\config.txt C:\Users\YourUsername\.ssh\config
```

---

### 9. Test Both SSH Connections

```bash
ssh -T git@github-personal
ssh -T git@github-work
```

Each should respond with the corresponding GitHub username confirming successful authentication.

---

### 10. Using the Host Alias When Cloning

When GitHub gives you an SSH clone URL it will look like:

```
git@github.com:username/repo.git
```

You need to **manually swap `github.com` with your Host alias** before running the command:

```bash
git clone git@github-work:username/repo.git
```

This is a small but important step — without it SSH won't know which key to use. For repos you have already cloned, update the remote URL with:

```bash
git remote set-url origin git@github-work:username/repo.git
```

Check what a repo's current remote is set to at any time with:

```bash
git remote -v
```
