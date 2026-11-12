#!/bin/sh
dir="${1:-lib/week13}"
grep -rl "package:http" "$dir" | grep -v -e core/api -e _repository.dart
grep -rl "package:flutter/material" "$dir" | grep -e _model.dart -e _repository.dart -e core/api
exit 0
