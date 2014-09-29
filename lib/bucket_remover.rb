#!/usr/bin/env ruby

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
require 'time'
require 'fileutils'
class BucketRemover
  def pdf_root
    File.expand_path(File.join(File.dirname(__FILE__), "../public/pdfs"))
  end

  def expired_buckets
    Dir["#{pdf_root}/*"].select { |dir| File.directory?(dir) && File.mtime(dir) < expired_time && can_delete?(dir) }
  end
  
  def can_delete?(dir)
    !(dir =~ /\/(pdfs|partner_csv)$/)
  end

  def expiration_period
    AppConfig.pdf_expiration_days.to_i
  end

  def expired_time
    Time.at(Time.parse(`date`).to_i - expiration_period)
  end

  def remove_buckets!
    expired_buckets.each { |bucket| FileUtils.rm_rf(bucket) }
  end
end

#BucketRemover.new.remove_buckets! if $0 == __FILE__
