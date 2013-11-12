# -*- coding: utf-8 -*-

Given(/^the current example directory is "(.*?)"$/) do |name|
  dir = File.join('src', 'examples', name)
  in_current_dir do
    FileUtils.cp_r Dir.glob(File.join('..', '..', dir, '*')), '.'
  end
end
