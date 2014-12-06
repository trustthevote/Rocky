class PriorityPdfGeneration < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :registrant
  validates_presence_of :registrant_id
  
  extend PdfQueueBase


  def self.sleep_timeout
    0
  end
  

end
