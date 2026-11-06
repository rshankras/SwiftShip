#!/bin/bash
# check-frontmatter.sh <file.md>...
# Parse each file's YAML frontmatter with a real YAML parser (Ruby's Psych,
# present on macOS and GitHub's Ubuntu runners). Prints one line per problem;
# exit 1 if any. Catches what `claude plugin validate` rejects: a frontmatter
# block that doesn't parse loads with ALL fields silently dropped (#108, #109).
# Exit 2 = no ruby (the caller should warn and skip).
command -v ruby >/dev/null || { echo "check-frontmatter: ruby not found" >&2; exit 2; }
ruby -ryaml -e '
bad = 0
ARGV.each do |f|
  text = File.read(f)
  m = text.match(/\A---\n(.*?)\n---\n/m)
  unless m then puts "#{f} — no frontmatter block"; bad += 1; next end
  begin
    fm = YAML.safe_load(m[1])
  rescue Psych::SyntaxError => e
    puts "#{f} — frontmatter is not valid YAML (#{e.problem} at line #{e.line}); quote values that contain [ ] | : #"
    bad += 1; next
  end
  unless fm.is_a?(Hash) then puts "#{f} — frontmatter is not a key/value block"; bad += 1; next end
  unless fm["description"].is_a?(String) then puts "#{f} — description must be text"; bad += 1 end
  if fm.key?("argument-hint") && !fm["argument-hint"].is_a?(String)
    puts "#{f} — argument-hint parses as #{fm["argument-hint"].class}, not text; wrap it in quotes"
    bad += 1
  end
end
exit(bad > 0 ? 1 : 0)
' "$@"
