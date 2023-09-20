#!/usr/bin/env bash
declare -A COLORS=( [RESET]="\033[0m" [RED]="\033[0;31m" [GREEN]="\033[0;32m" [YELLOW]="\033[0;33m" [CYAN]="\033[0;36m" )

print_help() {
  echo "Usage: build-local.sh [options]
Options:
-m, --major <major>:    Major version of the image
-h, --help:             Print this help message
-i, --image:            Image to build (base, desktop, laptop)"
}

# Use this if you want to print a normal log message
print_msg() {
  local __msg=$1

  echo -e "${COLORS[GREEN]}[+]${COLORS[RESET]} ${__msg}"
}

# Use this if you want to print a warning (output will be yellow)
print_warn() {
  local __msg=$1

  echo -e "${COLORS[YELLOW]}[=] WARN: ${__msg}${COLORS[RESET]}"
}

# Use this if you want to print an error (output will be red)
print_error() {
  local __msg=$1

  echo -e "${COLORS[RED]}[-] ERROR: ${__msg}${COLORS[RESET]}" >&2
}

print_debug() {
  # Return if debugging is turned off
  if [ -z "$DEBUG" ]; then
    return
  fi

  local __msg=$1

  echo -e "${COLORS[CYAN]}[?] DEBUG:${COLORS[RESET]} ${__msg}"
}

main() {
  if [[ -z ${IMAGE} ]]; then
    print_warn "No image specified, defaulting to base"
  fi

  if [[ -z ${IMAGE_MAJOR} ]]; then
    print_warn "No major version specified, defaulting to 38"
  fi

  IMAGE=${IMAGE:-base}
  IMAGE_MAJOR=${IMAGE_MAJOR:-39}

  echo "----------------------------------------"
  print_msg "Building '${IMAGE}' image with major version ${IMAGE_MAJOR}..."
  echo "----------------------------------------"

  local __command="buildah bud -f ./"${IMAGE}"/Dockerfile --build-arg IMAGE_MAJOR="${IMAGE_MAJOR}" --format oci -t localhost/custom-silverblue-"${IMAGE}":"${IMAGE_MAJOR}" ./"${IMAGE}""

  print_debug "Running command: ${__command}"
  eval ${__command}
  
  local __exit_code=$?

  if [[ __exit_code -ne 0 ]]; then
    print_error "Buildah returned a non-zero exit code trying to build image '${IMAGE}' with major version '${IMAGE_MAJOR}'. Exit code was: ${__exit_code}"
    exit 1
  fi
}

# Args parsing
while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--major)
      shift
      IMAGE_MAJOR=$1
      shift
      ;;
    -i|--image)
      shift
      IMAGE=$1
      shift
      ;;
    -h|--help)
      exit 0
      print_help
      ;;
    *)
      print_error "Unknown option: $1"
      print_help
      exit 1
      ;;
  esac
done

main
