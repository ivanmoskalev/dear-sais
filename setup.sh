#!/usr/bin/env zsh

set -e

echo "Enter the name of the library to be created: "
read libname 

if [[ $libname =~ ^Dear[A-Z][a-z]*$ ]]; then
    echo "Library name is valid"
else
    echo "Library name is invalid, must start with Dear followed by a capital letter and then lowercase letters"
    exit 1
fi

echo "Moving files and renaming them..."

mkdir -p Sources/$libname
mkdir -p Tests/${libname}Unit
mkdir -p Tests/${libname}Performance

mv Sources/DearTemplate/DearTemplate.swift Sources/$libname/$libname.swift
mv Tests/DearTemplateUnit/DearTemplateUnit.swift Tests/${libname}Unit/${libname}Unit.swift
mv Tests/DearTemplatePerformance/DearTemplatePerformance.swift Tests/${libname}Performance/${libname}Performance.swift

rm -r Sources/DearTemplate
rm -r Tests/DearTemplateUnit
rm -r Tests/DearTemplatePerformance

echo "Renaming file contents..."

sed -i '' "s/DearTemplate/$libname/g" Package.swift
sed -i '' "s/DearTemplate/$libname/g" Sources/$libname/$libname.swift
sed -i '' "s/DearTemplate/$libname/g" Tests/${libname}Unit/${libname}Unit.swift
sed -i '' "s/DearTemplate/$libname/g" Tests/${libname}Performance/${libname}Performance.swift
sed -i '' "s/DearTemplate/$libname/g" README.md
sed -i '' "s/DearTemplate/$libname/g" .github/workflows/tests.yml

echo "Library setup complete. Self-destructing setup.sh..."

rm setup.sh
