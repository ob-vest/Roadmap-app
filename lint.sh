if [[ "$(uname -m)" == arm64 ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

if which swiftlint > /dev/null; then
    # This only lints changed files and autofixes it
  # https://github.com/realm/SwiftLint/issues/4015#issuecomment-1246105494
  git status --porcelain | grep -v '^ \?D' | cut -c 4- | sed 's/.* -> //' | tr -d '"' | while read file 
  do
    if [[ "$file" == *.swift ]]; then
      swiftlint "$file" --fix
      swiftlint
    fi
  done
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
