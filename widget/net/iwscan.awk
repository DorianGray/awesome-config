# Based off this answer http://stackoverflow.com/a/17880517/1172409 
# Ideally one wouldn't parse the output of iw scan (it may be subject to change), 
# but dealing with learning libnl which iw uses seems overly complicated - more so than updating this in case iw does change.

# A few things that could be improved:
# Better padding solution for prettier pretty printing.
# Sort APs based off signal strength from best to worst.

# Usage - iw must be run as root (suggestion: add as an alias in bashrc):
# iw wlp8s0 scan | awk -f scan.awk

function hColor(s) {
  return "\033[1;31m" s "\033[0m "
}

function empColor(s) {
  return "\033[0;35m" s "\033[0m "
}

function strip(s) {
  gsub(/^[ \t]+/,"",s)
  gsub(/[ \t]+$/,"",s)
  return s
}

# Parse input and collect info

BEGIN {
  FS=":" # Everything except BSS is : separated.
}

substr($1, 0, 3) == "BSS" {
    MAC = $2
    # Default assumptions:
    wifi[MAC]["enc"] = "Open?"
    wifi[MAC]["SSID"] = empColor("Hidden") # Assume hidden
}

$1 == "\tSSID" {
    wifi[MAC]["SSID"] = strip($2)
}
$1 == "\t\t * primary channel" {
    wifi[MAC]["channel"] = strip($2)
}
$1 == "\tsignal" {
    # Strip dBm from the output
    input = strip($2)
    split(input,res , " ")
    wifi[MAC]["sig"] = res[1]
}
$1 == "\tWPA" {
    wifi[MAC]["enc"] = "WPA"
}
$1 == "\tRSN" {
    wifi[MAC]["enc"] = "WPA2"
}
$1 == "\tWPS" {
    wifi[MAC]["wps"] = "Yes"
}

# Print collected info
END {

    fmt = "%-35s\t%s\t%s\t%-10s\t%s\n"

    # printf fmt, hColor("SSID"), hColor("Channel"), hColor("Signal"), hColor("Encryption"), hColor("WPS?")

    for (w in wifi) {
      printf fmt, wifi[w]["SSID"], wifi[w]["channel"], wifi[w]["sig"], wifi[w]["enc"], wifi[w]["wps"]
    }
}
