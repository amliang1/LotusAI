#!/bin/bash
# Remove duplicate struct declarations from AIModelConfigView.swift
grep -n "struct EditAIModelConfigView: View {" LotusAI/Views/AIModelConfigView.swift | while read -r line; do
  line_num=$(echo "$line" | cut -d':' -f1)
  if [ ! -z "$line_num" ]; then
    # Find the matching closing brace
    end_line=$(tail -n +$line_num LotusAI/Views/AIModelConfigView.swift | grep -n "^}" | head -1 | cut -d':' -f1)
    if [ ! -z "$end_line" ]; then
      end_line=$((line_num + end_line - 1))
      # Delete the struct declaration and its body
      sed -i '' "${line_num},${end_line}d" LotusAI/Views/AIModelConfigView.swift
    fi
  fi
done
