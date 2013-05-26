#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
class Translation
  
  def self.base_directory
    Rails.root.join('config','locales')
  end
  
  def self.types
    ['core', 'states', 'txt', 'email']
  end
  
  def self.directories
     types.collect{|t| directory(t) }
  end
  
  def self.file_names
    I18n.available_locales.collect{|l| "#{l}.yml"}
  end
  
  def self.find(type)
    self.new(type)
  end
  
  def self.directory(type)
    type == 'base' ? base_directory : base_directory.join(type)
  end
  
  attr_reader :directory
  attr_reader :type
  
  def initialize(type)
    raise "Not Found" if !self.class.types.include?(type)
    @type = type
    @directory = self.class.directory(type)
  end
  
  def file_path(fn)
    File.join(directory, fn)
  end
  
  def language(fn)
    fn.gsub(".yml", '')
  end
  
  def contents
    @contents ||= {}
    if @contents.empty?
      self.class.file_names.each do |fn|
        File.open(file_path(fn)) do |file|
          h = YAML.load(file)
          @contents[language(fn)] = h[h.keys.first] || {}
        end
      end
    end
    @contents
  end
  
  
end