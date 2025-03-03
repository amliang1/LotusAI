#!/bin/bash
# Remove duplicate struct declarations from AIModelConfigView.swift
sed -i '' '/^struct AIModelConfigRow: View {$/,/^}$/d' LotusAI/Views/AIModelConfigView.swift
sed -i '' '/^struct NewAIModelConfigView: View {$/,/^}$/d' LotusAI/Views/AIModelConfigView.swift
