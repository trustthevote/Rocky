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

describe ReminderMailer do
  let(:rm) { ReminderMailer.new }
  describe 'deliver_reminders(ids)' do
    it "finds registrants in batches based on ids and calls deliver_reminders" do
      a = double('registrant')
      expect(a).to receive(:deliver_reminder_email)
      expect(Registrant).to receive(:find_each).with({
        :batch_size=>500,
        :conditions=> ["id in (?)", [-1,-2]]
      }).and_yield(a)
      rm.deliver_reminders([-1,-2])
    end
  end
  
  describe 'reg_ids(n, time)' do
    it "finds reg ids with n reminders left updated before a certain time stamp" do
      where = double('where')
      expect(where).to receive(:pluck).with(:id)
      expect(Registrant).to receive(:where).with("reminders_left = ? AND updated_at < ?", "n", "time") { where }
      rm.reg_ids("n", "time")
    end
  end
  
  describe 'deliver_final_reminders' do
    it "finds registrants who haven't downloaded their PDF, haven't been sent a final reminder and have had the configured amount of time passed since the last reminder" do
      frt = double('final_reminder_time')
      expect(rm).to receive(:final_reminder_time) { frt }
      reg =  double('registrant')
      expect(reg).to receive(:deliver_final_reminder_email)
      expect(Registrant).to receive(:find_each).with({
        batch_size: 500,
        conditions: ["reminders_left=0 AND pdf_downloaded = ? AND updated_at < ? AND final_reminder_delivered = ?", false, frt, false ]
      }).and_yield(reg)
      rm.deliver_final_reminders
    end
  end
  
end