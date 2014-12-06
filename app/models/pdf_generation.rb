class PdfGeneration < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :registrant
  validates_presence_of :registrant_id
  
  extend PdfQueueBase
  
end