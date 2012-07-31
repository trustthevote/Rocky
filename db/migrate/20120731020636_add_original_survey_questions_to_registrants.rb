class AddOriginalSurveyQuestionsToRegistrants < ActiveRecord::Migration
  def self.up
    add_column :registrants, :original_survey_question_1, :string
    add_column :registrants, :original_survey_question_2, :string
  end

  def self.down
    remove_column :registrants, :original_survey_question_2
    remove_column :registrants, :original_survey_question_1
  end
end
