
# User Management Automation 

---

# **1. Introduction**

This project automates the onboarding process for new developers or employees in a Linux environment.
Instead of creating each user manually, assigning groups, generating passwords, and configuring home directories, this script performs all these tasks automatically based on a simple input file.

The automation ensures:

* Faster user provisioning
* Consistent configuration
* Secure password handling
* Complete logging for auditing
* Reduced manual errors



---

# **2. Purpose and Design of the Script**

The goal of `create_users.sh` is to read a list of usernames and their group memberships from a text file and automatically configure each user on the system.

### **Design Goals**

* Read each line in the input file and extract `username;group1,group2`.
* Skip blank or commented lines.
* Automatically create missing Linux groups.
* Create or update the user account.
* Set up a home directory with correct permissions.
* Generate a strong random password for each user.
* Save credentials securely in `/var/secure/user_passwords.txt`.
* Log every action to `/var/log/user_management.log`.



---

# **3. Project Structure**

Your project folder should contain the following files:

```
project-folder/
│
├── create_users.sh
├── README.md
├── employees.txt             # Your input file 
│
└── Output Files Created After Running Script:
    ├── /var/secure/user_passwords.txt
    └── /var/log/user_management.log
```

### **Explanation**

* **create_users.sh** → Main automation script
* **README.md** → Documentation
* **users.txt** → Input file with usernames and groups
* **user_passwords.txt** → Contains generated usernames & passwords (after execution)
* **user_management.log** → Contains all logs (after execution)

---

# **4. Step-by-Step Explanation (How the Script Works)**

The script performs the following steps:

### **Step 1 – Validate Input**

Confirms the script is run as `root` and the input file exists.

### **Step 2 – Prepare Secure Directories**

Creates:

```
/var/secure/user_passwords.txt
/var/log/user_management.log
```

Permissions are set to `600`.

### **Step 3 – Read Input File**

Ignores:

* Blank lines
* Lines starting with `#`

Cleans whitespace and splits into:

* `username`
* group list (comma-separated)

### **Step 4 – Create Groups**

For each group listed:

* Check if group exists
* If not, create it using `groupadd`

### **Step 5 – Create or Update User**

If user exists:

* Add missing groups

If new user:

* Create with `/home/username`
* Assign Bash shell
* Assign all supplementary groups

### **Step 6 – Home Directory Setup**

Ensures:

```
/home/username
```

exists and has:

* owner = username
* permissions = 700

### **Step 7 – Password Generation**

* Creates a 12-character password using `/dev/urandom`
* Applies it with `chpasswd`
* Saves username:password to `/var/secure/user_passwords.txt`

### **Step 8 – Logging**

Every event is logged with a timestamp in:

```
/var/log/user_management.log
```

### **Step 9 – Completion**

Re-checks permissions and prints a completion message.

---

# **5. Example Usage**

### **Input File (`users.txt`)**

```
# New Employees
light; sudo,dev,www-data
siyoni; sudo
manoj; dev,www-data
```

### **Make Script Executable**

```bash
chmod +x create_users.sh
```

### **Run Script as Root**

```bash
sudo ./create_users.sh users.txt
```

### **Check Log File**

```bash
sudo cat /var/log/user_management.log
```

### **Check Generated Passwords**

```bash
sudo cat /var/secure/user_passwords.txt
```

---

# **6. Security Considerations**

###  Password File Security

The password file:

```
/var/secure/user_passwords.txt
```

contains plaintext passwords, so it is protected using:

```
chmod 600
```

Only root can access it.

###  Logging Privacy

Log file also has:

```
chmod 600
```

to prevent unauthorized access to sensitive actions.

###  Password Strength

Passwords are:

* 12 characters
* Generated from `/dev/urandom`
* Contain letters, numbers, and special characters

###  Recommended Enhancements

For real production:

* Store passwords in an encrypted vault
* Delete the plaintext file after distribution
* Force password reset at first login with:





