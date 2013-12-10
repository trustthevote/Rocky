class AddGeneralSurveyQuestionsToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :survey_question_1, :text
    add_column :partners, :survey_question_2, :text
  end
end
