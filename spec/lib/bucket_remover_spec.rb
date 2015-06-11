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
require File.dirname(__FILE__) + '/../rails_helper'

describe BucketRemover do
  before(:each) do
    AppConfig.stub(:pdf_expiration_days) { 14.days }
    @folder_name = Rails.root.join("tmp/pdf_#{$$}_#{Time.now.to_i}_#{Time.now.usec.to_i}")
    (21..30).each do |i|
      file_name = "#{@folder_name}/d.#{i}"
      create_dir_in_past(file_name, ((i*12).hours + 5.minutes))
    end

    @remover = BucketRemover.new
    @remover.stub(:pdf_root) { @folder_name }
  end

  def create_dir_in_past(path, ago)
    mtime = (Time.parse(`date`) - ago).strftime("%m%d%H%M")
    FileUtils.mkdir_p(path)
    `touch -t #{mtime} #{path}`
  end

  it "has 3 dirs more than 14.0 days old" do
    expired_buckets = @remover.expired_buckets
    assert_equal 3, expired_buckets.length
  end

  it "should delete expired directories" do
    assert_difference %Q(Dir["#{@folder_name}/*"].length), -3 do
      @remover.remove_buckets!
    end
  end
end
