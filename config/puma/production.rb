#!/usr/bin/env puma

_load_from File.expand_path("../defaults.rb", __FILE__)

environment "production"

workers 16
threads 5, 16
