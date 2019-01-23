#!/bin/bash
# Import bulk data for DEVICE > CUSTOM FIELDs from CSV.

# Clean exit trap
trap 'funcEXIT' SIGINT SIGTERM EXIT
funcEXIT() {
	rm -vf "$fileCURL" "$fileNETRC" >&2
}

# Dependency check
dependencies=("awk" "curl" "grep" "mktemp" "bash")
for dependency in "${dependencies[@]}"; do
	which $dependency &> /dev/null || { printf "%s %s\n" "Missing dependency:" "$dependency" >&2; exit 1; }
done

umask 077
fileCURL="$(mktemp)"
exec 3<> "$fileCURL"

while read -r varLINE; do
	grep -Eq '^\s*#' <<<"$varLINE" && { printf 'Skipping commented line...\n' >&2; continue; }
	awk -F',' '{
	 if ( NF != 3 ) {
		printf "ERROR: Too many values (%d) in this line >>> %s <<<\n",NF,$0 > "/dev/stderr";
		exit 1;
	 } else { 
		printf "echo -n \"Trying %s...\"\n",$1 > "/dev/fd/3";
		printf "curl -s -X PUT -d \"name=%s&bulk_fields=Owner:%s, Application Contact:%s\" --netrc-file \"$fileNETRC\" \"https://ipam.optivmss.com/api/1.0/device/custom_field/\"\n",$1,$2,$3 > "/dev/fd/3";
	 }
	}' <<<"$varLINE" || { continue; }
	printf 'echo\n' >&3;
done < "${1:-/proc/self/fd/0}"

export fileNETRC="$(mktemp)"
read -r -s -p "Enter Device42 password: " varD42PASS; echo
printf 'machine ipam.optivmss.com login %s password %s\n' "$USER" "$varD42PASS"> "$fileNETRC"

bash <"$fileCURL" 
