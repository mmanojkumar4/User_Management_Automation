#!/bin/bash


INPUT_FILE="$1"
# SECURE_DIR="C:/Users/hp/Desktop/UMA/SECURE_DIR"
# PASSWORD_FILE="$SECURE_DIR/user_passwords.txt"
# LOG_FILE="C:/Users/hp/Desktop/UMA/user_management.log"

SECURE_DIR="/var/secure"
PASSWORD_FILE="$SECURE_DIR/user_passwords.txt"
LOG_FILE="/var/log/user_management.log"





# Must run as root
if [[ $EUID -ne 0 ]]; then
  echo " Run as root: sudo $0 <file>"
  exit 1
fi


#Checking Validate input file

if [[ -z "$INPUT_FILE" || ! -f "$INPUT_FILE" ]]; then
  echo " Usage: $0 <input_file>"
  exit 1
fi


# Prepare secure files

mkdir -p "$SECURE_DIR"
touch "$PASSWORD_FILE" "$LOG_FILE"
chmod 600 "$PASSWORD_FILE" "$LOG_FILE"


# Logging function

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}


# Generate random password
generate_password() {
  tr -dc 'A-Za-z0-9@#$%&*' < /dev/urandom | head -c 12
}


# Process input file line by line

while IFS= read -r line || [[ -n "$line" ]]; do

  # Skip empty lines and comments
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  # Remove spaces
  line=$(echo "$line" | tr -d '[:space:]')

  # Split username and groups
  username=$(echo "$line" | cut -d';' -f1)
  groups=$(echo "$line" | cut -d';' -f2)

  # Validate username
  if [[ -z "$username" ]]; then
    log " Skipped invalid entry: $line"
    continue
  fi

  # Split groups into array
  IFS=',' read -r -a group_list <<< "$groups"

  # Create missing groups
  for grp in "${group_list[@]}"; do
    [[ -z "$grp" ]] && continue
    if ! getent group "$grp" >/dev/null 2>&1; then
      groupadd "$grp"
      log " Created group: $grp"
    fi
  done

  # Create or update user
  if id "$username" &>/dev/null; then
    log "ℹ User '$username' exists. Updating groups."
    usermod -a -G "$groups" "$username"
  else
    useradd -m -s /bin/bash -G "$groups" "$username"
    log " Created user: $username"
  fi

  # Home directory handling
  homedir="/home/$username"
  if [[ ! -d "$homedir" ]]; then
    mkdir -p "$homedir"
    log " Created home directory for $username"
  fi

  chown "$username:$username" "$homedir"
  chmod 700 "$homedir"

  # Password creation
  password=$(generate_password)
  echo "$username:$password" | chpasswd
  echo "$username:$password" >> "$PASSWORD_FILE"
  log " Password set for $username"

done < "$INPUT_FILE"

chmod 600 "$PASSWORD_FILE"
log " User creation process completed successfully."
exit 0
